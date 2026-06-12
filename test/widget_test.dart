import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:Klinik/core/router/route_names.dart';
import 'package:Klinik/features/onboarding/onboarding_provider.dart';

void main() {
  late Directory tempDir;
  late Box box;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('klinik_hive_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox(OnboardingRepository.boxName);
  });

  tearDown(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('OnboardingRepository', () {
    test('démarre non complété, puis persiste après markCompleted', () async {
      final repo = OnboardingRepository(box);

      expect(repo.isCompleted, isFalse);

      await repo.markCompleted();

      expect(repo.isCompleted, isTrue);
    });
  });

  group('resolveSplashRoute (sans token Firebase)', () {
    test('onboarding jamais vu → /onboarding', () {
      final repo = OnboardingRepository(box);

      expect(resolveSplashRoute(repo), RouteNames.onboarding);
    });

    test('onboarding déjà complété → /auth', () async {
      final repo = OnboardingRepository(box);
      await repo.markCompleted();

      expect(resolveSplashRoute(repo), RouteNames.authChoice);
    });
  });
}
