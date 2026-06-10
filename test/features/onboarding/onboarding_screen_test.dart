import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hanzify/app/app_router.dart';
import 'package:hanzify/core/profile/user_profile.dart';
import 'package:hanzify/core/providers/user_profile_provider.dart';
import 'package:hanzify/features/onboarding/presentation/onboarding_screen.dart';

import '../../support/profile_overrides.dart';

void main() {
  testWidgets('onboarding flow saves level, daily time and priority', (
    tester,
  ) async {
    final overrides = await profileTestOverrides();
    final router = GoRouter(
      initialLocation: OnboardingScreen.path,
      routes: [
        GoRoute(
          path: OnboardingScreen.path,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('home-after-onboarding')),
        ),
      ],
    );
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: Consumer(
          builder: (context, ref, child) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Bước 1: trình độ.
    expect(find.text('Bạn đang ở trình độ nào?'), findsOneWidget);
    await tester.tap(find.text('HSK 3'));
    await tester.pump();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Bước 2: thời lượng mỗi ngày.
    expect(find.text('Mỗi ngày bạn muốn học bao lâu?'), findsOneWidget);
    await tester.tap(find.text('5 phút'));
    await tester.pump();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    // Bước 3: ưu tiên.
    expect(find.text('Bạn muốn ưu tiên điều gì?'), findsOneWidget);
    await tester.tap(find.text('Nghe hiểu'));
    await tester.pump();
    await tester.tap(find.text('Bắt đầu học'));
    await tester.pumpAndSettle();

    expect(find.text('home-after-onboarding'), findsOneWidget);
    final profile = container.read(userProfileProvider);
    expect(profile.activeLevel, 3);
    expect(profile.dailyMinutes, 5);
    expect(profile.priority, LearningPriority.listening);
    expect(profile.onboardingComplete, isTrue);
  });

  testWidgets('app router redirects first run to onboarding', (tester) async {
    final overrides = await profileTestOverrides();

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: Consumer(
          builder: (context, ref, child) {
            return MaterialApp.router(
              routerConfig: ref.watch(appRouterProvider),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bạn đang ở trình độ nào?'), findsOneWidget);
  });
}
