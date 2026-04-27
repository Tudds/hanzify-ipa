import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/widgets/app_navigation_shell.dart';
import 'package:hanzify/core/widgets/app_navigation_rail.dart';
import 'package:hanzify/core/widgets/bottom_tab_bar.dart';

import '../../test_helpers.dart';

void main() {
  setUpAll(disableGoogleFonts);

  Widget buildBody() {
    return ColoredBox(
      color: const Color(0xFFF4EFE6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Session preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('3 the den han va 2 loi giai gan day.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShell({
    required ProviderContainer container,
    required bool useRail,
    required bool showPrimaryNav,
    String currentScreen = AppRoutes.home,
    int dueCount = 3,
    ValueChanged<String>? onNavigate,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: testTheme(),
        home: AppNavigationShell(
          currentScreen: currentScreen,
          onNavigate: onNavigate ?? (_) {},
          useRail: useRail,
          showPrimaryNav: showPrimaryNav,
          isNavVisible: true,
          dueCount: dueCount,
          child: buildBody(),
        ),
      ),
    );
  }

  Future<void> setSurfaceSize(WidgetTester tester, Size logicalSize) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logicalSize;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('mobile shell shows bottom bar and quick action FAB', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildShell(
        container: container,
        useRail: false,
        showPrimaryNav: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BottomTabBarWidget), findsOneWidget);
    expect(find.byKey(const ValueKey('quick_actions_fab')), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
  });

  testWidgets('mobile quick action FAB opens sheet and navigates', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildShell(
        container: container,
        useRail: false,
        showPrimaryNav: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quick_actions_fab')));
    await tester.pumpAndSettle();

    expect(find.text('Truy cập nhanh'), findsOneWidget);
    expect(find.text('Ngữ pháp'), findsOneWidget);

    await tester.tap(find.text('Kiểm tra'));
    await tester.pumpAndSettle();

    expect(container.read(navigationProvider).screen, AppRoutes.quiz);
  });

  testWidgets('rail shell shows navigation rail and quick action menu', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildShell(
        container: container,
        useRail: true,
        showPrimaryNav: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(BottomTabBarWidget), findsNothing);
    expect(find.byKey(const ValueKey('rail_quick_actions_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rail_quick_actions_button')));
    await tester.pumpAndSettle();

    expect(find.text('Tra từ'), findsOneWidget);

    await tester.tap(find.text('Tra từ'));
    await tester.pumpAndSettle();

    expect(container.read(navigationProvider).screen, AppRoutes.vocabList);
  });

  testWidgets('bottom bar uses navigation callback', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    String? navigatedRoute;

    await tester.pumpWidget(
      buildShell(
        container: container,
        useRail: false,
        showPrimaryNav: true,
        onNavigate: (route) => navigatedRoute = route,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();

    expect(navigatedRoute, AppRoutes.profile);
  });

  testWidgets('golden - mobile shell', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await setSurfaceSize(tester, const Size(390, 844));

    await tester.pumpWidget(
      buildShell(
        container: container,
        useRail: false,
        showPrimaryNav: true,
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AppNavigationShell),
      matchesGoldenFile('../../goldens/app_navigation_shell_mobile.png'),
    );
  });

  testWidgets('golden - rail shell', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await setSurfaceSize(tester, const Size(1100, 900));

    await tester.pumpWidget(
      buildShell(
        container: container,
        useRail: true,
        showPrimaryNav: true,
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AppNavigationShell),
      matchesGoldenFile('../../goldens/app_navigation_shell_rail.png'),
    );
  });
}
