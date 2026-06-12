---
name: klinik-vision-module
description: Use this skill for ALL camera, facial analysis, and visual AI features in Klinik-Scan. Covers MediaPipe Face Mesh integration in Flutter, pupil ratio detection, scleral pallor analysis, blink rate measurement, video capture and storage, and vision metrics integration into the risk score. Trigger whenever writing code related to the camera, face detection, image analysis, or visual patient assessment.
---

# Klinik-Vision-Module Skill

## Core Philosophy (Karpathy Method)

The vision module is a **clinical observation assistant**, not a diagnostic engine.
Its sole purpose is to help a community health agent observe and record visual signs
that a trained clinician would normally check. The AI surfaces data — the doctor decides.

**Three absolute rules for this module:**
1. The vision module NEVER produces a diagnosis. It produces metrics.
2. Every metric must be displayed with its confidence level and its clinical interpretation range.
3. The module works on low-end Android devices (2GB RAM) — no model over 20MB on-device.

---

## What the Vision Module Detects

### Metric 1 — Pupil Asymmetry Ratio
**What it measures:** Difference in diameter between left and right pupil.
**Clinical relevance:** Asymmetry > 20% (anisocoria) can indicate neurological involvement, head injury, or drug effect. Requires immediate medical attention.
**Technical method:** MediaPipe Iris landmarks (points 468–477) — measure iris width in normalized coordinates.
**Output:** Float 0.0–1.0 where 0.0 = perfect symmetry, 1.0 = complete asymmetry.
**Score contribution:** +2 points to risk score if asymmetry > 0.2.

### Metric 2 — Scleral Pallor Score
**What it measures:** Color saturation of the visible sclera (white of the eye).
**Clinical relevance:** Pale sclera (low saturation, high lightness) correlates with anemia and low hemoglobin. Yellow tinge (icterus) indicates possible jaundice/hepatic involvement.
**Technical method:** Extract HSL values from scleral region (MediaPipe landmarks 33, 133, 362, 263). Average S (saturation) and H (hue) values.
**Output:**
- `palleurScore`: Float 0.0–1.0 (1.0 = very pale)
- `ictereScore`: Float 0.0–1.0 (1.0 = very yellow)
**Score contribution:** +1 if palleur > 0.6, +2 if palleur > 0.8. +2 if ictere > 0.5.

### Metric 3 — Blink Rate & Eye Openness
**What it measures:** Frequency of blinking and degree of eye opening.
**Clinical relevance:** Reduced blink rate and heavy eyelids indicate lethargy, altered consciousness, or high fever effect.
**Technical method:** Eye Aspect Ratio (EAR) = vertical eye distance / horizontal eye distance using MediaPipe landmarks.
**Output:**
- `blinkRatePer60s`: Int (normal: 15–20/min. <10 = lethargic concern)
- `earScore`: Float (normal: 0.25–0.35. <0.15 = eyes nearly closed)
**Score contribution:** +1 if blinkRate < 10. +1 if earScore < 0.15.

---

## Technical Architecture

### Packages Required (pubspec.yaml)

```yaml
dependencies:
  camera: ^0.10.5
  google_mlkit_face_detection: ^0.9.0
  image: ^4.1.3
  path_provider: ^2.1.2
  video_compress: ^3.1.2
  flutter_tflite: ^2.0.0  # fallback if MLKit unavailable
```

### Module Structure (Flutter)

```
lib/features/scan/
├── vision/
│   ├── vision_module.dart          # Main entry point
│   ├── face_detector_service.dart  # MLKit face detection wrapper
│   ├── pupil_analyzer.dart         # Metric 1: pupil asymmetry
│   ├── scleral_analyzer.dart       # Metric 2: pallor/icterus
│   ├── blink_analyzer.dart         # Metric 3: blink/alertness
│   ├── vision_metrics.dart         # Data model for all metrics
│   └── vision_score_adapter.dart   # Converts metrics to risk score points
├── widgets/
│   ├── camera_preview_widget.dart  # Live camera preview
│   ├── face_overlay_widget.dart    # Real-time face landmark overlay
│   └── vision_results_card.dart   # Display metrics to agent
```

---

## VisionMetrics Data Model

```dart
class VisionMetrics {
  final double pupilAsymmetryRatio;   // 0.0 = symmetric, 1.0 = asymmetric
  final double palleurScore;          // 0.0 = normal, 1.0 = very pale
  final double ictereScore;           // 0.0 = normal, 1.0 = very yellow
  final int blinkRatePer60s;          // blinks per minute
  final double earScore;              // eye aspect ratio
  final double overallConfidence;     // 0.0–1.0 quality of detection
  final DateTime capturedAt;
  final String? videoPath;            // local path to 30s video

  const VisionMetrics({
    required this.pupilAsymmetryRatio,
    required this.palleurScore,
    required this.ictereScore,
    required this.blinkRatePer60s,
    required this.earScore,
    required this.overallConfidence,
    required this.capturedAt,
    this.videoPath,
  });

  // Risk score contribution (max +4 points)
  int get riskScoreContribution {
    int points = 0;
    if (pupilAsymmetryRatio > 0.2) points += 2;
    if (palleurScore > 0.8) points += 2;
    else if (palleurScore > 0.6) points += 1;
    if (ictereScore > 0.5) points += 2;
    if (blinkRatePer60s < 10) points += 1;
    if (earScore < 0.15) points += 1;
    return points.clamp(0, 4); // capped at 4 to keep human questionnaire dominant
  }

  Map<String, dynamic> toMap() => {
    'pupilAsymmetryRatio': pupilAsymmetryRatio,
    'palleurScore': palleurScore,
    'ictereScore': ictereScore,
    'blinkRatePer60s': blinkRatePer60s,
    'earScore': earScore,
    'overallConfidence': overallConfidence,
    'riskPoints': riskScoreContribution,
    'capturedAt': capturedAt.toIso8601String(),
  };
}
```

---

## Vision Module Main Flow

```dart
class VisionModule {
  final FaceDetectorService _detector;
  final PupilAnalyzer _pupilAnalyzer;
  final ScleralAnalyzer _scleralAnalyzer;
  final BlinkAnalyzer _blinkAnalyzer;

  // Run a 10-second analysis session
  Future<VisionMetrics> analyzePatient({
    required CameraController camera,
    required String sessionId,
  }) async {
    final frames = <InputImage>[];
    final timer = Stopwatch()..start();

    // Capture frames for 10 seconds
    while (timer.elapsed.inSeconds < 10) {
      final frame = await _captureFrame(camera);
      if (frame != null) frames.add(frame);
      await Future.delayed(const Duration(milliseconds: 200)); // 5 fps
    }

    if (frames.isEmpty) {
      return VisionMetrics.empty(); // no face detected — no score contribution
    }

    // Analyze all frames
    final pupilRatio = await _pupilAnalyzer.analyze(frames);
    final scleralData = await _scleralAnalyzer.analyze(frames);
    final blinkData = await _blinkAnalyzer.analyze(frames);

    return VisionMetrics(
      pupilAsymmetryRatio: pupilRatio,
      palleurScore: scleralData.palleur,
      ictereScore: scleralData.ictere,
      blinkRatePer60s: blinkData.blinkRate,
      earScore: blinkData.averageEar,
      overallConfidence: _calculateConfidence(frames.length),
      capturedAt: DateTime.now(),
    );
  }
}
```

---

## Video Capture & Storage Pattern

```dart
class PatientVideoService {
  static const int maxDurationSeconds = 30;
  static const int maxFileSizeMB = 10;

  Future<String?> capturePatientVideo(
    CameraController controller,
    String patientId,
    String entityId,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/videos/${entityId}_${patientId}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await controller.startVideoRecording();
    await Future.delayed(const Duration(seconds: maxDurationSeconds));
    final file = await controller.stopVideoRecording();

    // Compress before storage
    final compressed = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
    );

    if (compressed?.file != null) {
      await File(compressed!.file!.path).copy(path);
      return path; // Returns local path — uploaded when online
    }
    return null;
  }
}
```

---

## UI — Vision Results Display

The agent sees a simple, color-coded card with 3 indicators. No medical jargon.
The médecin sees the full metrics with clinical reference ranges.

```dart
// Agent view — simplified
Widget buildAgentVisionCard(VisionMetrics metrics) {
  return Column(children: [
    VisionIndicator(
      label: 'Yeux — Symétrie',
      status: metrics.pupilAsymmetryRatio > 0.2 ? IndicatorStatus.alert : IndicatorStatus.normal,
      value: metrics.pupilAsymmetryRatio > 0.2 ? 'Asymétrie détectée' : 'Normal',
    ),
    VisionIndicator(
      label: 'Pâleur',
      status: _palleurStatus(metrics.palleurScore),
      value: _palleurLabel(metrics.palleurScore),
    ),
    VisionIndicator(
      label: 'Niveau d\'éveil',
      status: metrics.blinkRatePer60s < 10 ? IndicatorStatus.warning : IndicatorStatus.normal,
      value: '${metrics.blinkRatePer60s} clignements/min',
    ),
    // Confidence disclaimer — always visible
    Text(
      'Analyse visuelle indicative — Confiance: ${(metrics.overallConfidence * 100).toInt()}%. '
      'Ces indicateurs ne remplacent pas l\'examen clinique du médecin.',
      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
    ),
  ]);
}
```

---

## Legal & Medical Compliance Rules

These rules must be respected in EVERY piece of UI and code in this module:

1. **Never say "diagnostic"** — always say "indicateur" or "observation visuelle".
2. **Always show confidence level** — low confidence (< 0.5) means metrics are hidden, not shown as zeros.
3. **Always display the disclaimer**: "Ces indicateurs sont une aide à l'observation. Ils ne constituent pas un diagnostic médical."
4. **If no face detected**, show: "Positionnez le visage du patient face à la caméra, dans une bonne lumière."
5. **Vision metrics contribute max 40% of risk score** — questionnaire + temperature always dominate.
6. **The doctor always sees the raw metrics** alongside the computed score to make their own judgment.

---

## Performance Constraints (Low-End Android)

- Maximum model size: 20MB (MediaPipe Face Mesh Lite = 1.1MB ✓)
- Target: 5 fps analysis (200ms per frame)
- Memory ceiling: 150MB for the entire vision module
- Thermal protection: stop analysis if device reports overheating
- Battery: analysis session max 30 seconds to limit drain
