# MediaPipe Face Mesh Landmarks — Klinik-Scan Reference

## Landmarks utilisés par le module vision

### Iris (pupilles)
- Iris gauche : points 468, 469, 470, 471, 472
- Iris droit : points 473, 474, 475, 476, 477
- Centre iris gauche : 468
- Centre iris droit : 473

### Sclère (blanc des yeux)
- Coin interne oeil gauche : 133
- Coin externe oeil gauche : 33
- Coin interne oeil droit : 362
- Coin externe oeil droit : 263
- Bord supérieur oeil gauche : 159
- Bord inférieur oeil gauche : 145
- Bord supérieur oeil droit : 386
- Bord inférieur oeil droit : 374

### Eye Aspect Ratio (EAR) — clignement
```
EAR = (||p2-p6|| + ||p3-p5||) / (2 * ||p1-p4||)
Points oeil gauche : p1=33, p2=160, p3=158, p4=133, p5=153, p6=144
Points oeil droit  : p1=362, p2=385, p3=387, p4=263, p5=373, p6=380
Seuil fermeture : EAR < 0.20
```

## Calcul du ratio pupillaire

```dart
double calculatePupilRatio(List<NormalizedLandmark> landmarks) {
  // Iris gauche — diamètre horizontal
  final leftLeft = landmarks[469];   // point gauche iris gauche
  final leftRight = landmarks[471];  // point droit iris gauche
  final leftDiameter = _distance(leftLeft, leftRight);

  // Iris droit — diamètre horizontal
  final rightLeft = landmarks[474];  // point gauche iris droit
  final rightRight = landmarks[476]; // point droit iris droit
  final rightDiameter = _distance(rightLeft, rightRight);

  if (leftDiameter == 0 || rightDiameter == 0) return 0.0;

  final larger = max(leftDiameter, rightDiameter);
  final smaller = min(leftDiameter, rightDiameter);
  return 1.0 - (smaller / larger); // 0 = perfect symmetry
}
```

## Zones de couleur pour analyse sclérale

Extraire les pixels dans les rectangles suivants (coordonnées normalisées) :
- Zone sclérale interne gauche : entre landmarks 133 et 468 (centre iris)
- Zone sclérale externe gauche : entre landmarks 468 (centre iris) et 33
- Idem pour oeil droit avec 362, 473, 263

Convertir chaque pixel RGB → HSL et faire la moyenne des canaux H et S.
