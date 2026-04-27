import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hanzify/core/navigation/app_routes.dart';
import 'package:hanzify/core/providers/auth_provider.dart';
import 'package:hanzify/core/providers/guest_mode_provider.dart';
import 'package:hanzify/core/providers/navigation_provider.dart';
import 'package:hanzify/core/providers/sync_provider.dart';
import 'package:hanzify/core/providers/user_preferences_provider.dart';
import 'package:hanzify/core/widgets/app_navigation_rail.dart';
import 'package:hanzify/core/widgets/bottom_tab_bar.dart';
import 'package:hanzify/features/conversation/domain/entities/conversation_context.dart';
import 'package:hanzify/features/conversation/presentation/screens/conversation_screen.dart';
import 'package:hanzify/features/conversation/presentation/providers/conversation_providers.dart';
import 'package:hanzify/features/grammar/domain/entities/grammar_point.dart';
import 'package:hanzify/features/grammar/presentation/providers/grammar_providers.dart';
import 'package:hanzify/features/vocab/domain/entities/vocab.dart';
import 'package:hanzify/features/vocab/presentation/providers/vocab_state.dart';
import 'package:hanzify/main.dart' show AppRoot;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'test_helpers.dart';

class _FakeNavigationNotifier extends NavigationNotifier {
  _FakeNavigationNotifier(this._initialState);

  final NavState _initialState;

  @override
  NavState build() => _initialState;
}

class _FakeSyncNotifier extends SyncNotifier {
  @override
  void build() {}
}

class _FakeAllVocabNotifier extends AllVocabNotifier {
  _FakeAllVocabNotifier(this.items);

  final List<Vocab> items;

  @override
  Future<List<Vocab>> build() async => items;
}

class _FakeDueVocabNotifier extends DueVocabNotifier {
  _FakeDueVocabNotifier(this.items);

  final List<Vocab> items;

  @override
  Future<List<Vocab>> build() async => items;
}

class _FakeGrammarList extends GrammarList {
  _FakeGrammarList(this.items);

  final List<GrammarPoint> items;

  @override
  Future<List<GrammarPoint>> build() async => items;
}

class _FakeConversationList extends ConversationList {
  _FakeConversationList(this.items);

  final List<ConversationContext> items;

  @override
  Future<List<ConversationContext>> build() async => items;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    disableGoogleFonts();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJpc3MiOiJzdXBhYmFzZS10ZXN0Iiwicm9sZSI6ImFub24iLCJleHAiOjQ3NjUxMzI4MDB9.'
          'signature',
    );
  });

  final sampleVocabs = [
    makeVocab(
      id: 'v1',
      hanzi: '你好',
      level: 1,
      meanings: const [Meaning(pos: 'v', vi: 'xin chào')],
      isMastered: true,
      interval: 1,
    ),
    makeVocab(
      id: 'v2',
      hanzi: '谢谢',
      level: 2,
      meanings: const [Meaning(pos: 'v', vi: 'cảm ơn')],
    ),
  ];

  final sampleGrammar = [
    const GrammarPoint(
      id: 'g1',
      title: 'Cấu trúc cơ bản',
      structure: 'S + 是 + N',
      explanation: 'Dùng để giới thiệu',
      level: 1,
      category: 'basic',
      examples: [],
    ),
  ];

  final sampleConversations = [
    const ConversationContext(
      id: 'c1',
      title: 'Chào hỏi',
      titleZh: '打招呼',
      titlePinyin: 'dǎ zhāo hū',
      description: 'Mẫu câu cơ bản khi gặp nhau',
      level: 1,
      category: 'greeting',
      icon: '💬',
      lines: [],
    ),
  ];

  AuthState signedOutState() => AuthState(AuthChangeEvent.signedOut, null);

  Future<void> pumpAppRoot(
    WidgetTester tester, {
    required ProviderContainer container,
    required Size logicalSize,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logicalSize;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: testTheme(),
          home: const AppRoot(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer buildContainer({required NavState navState}) {
    return ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith(
          (ref) => Stream<AuthState>.value(signedOutState()),
        ),
        guestModeProvider.overrideWithValue(true),
        showOnboardingProvider.overrideWithValue(false),
        showPinyinProvider.overrideWithValue(true),
        syncProvider.overrideWith(_FakeSyncNotifier.new),
        navigationProvider.overrideWith(
          () => _FakeNavigationNotifier(navState),
        ),
        allVocabProvider.overrideWith(
          () => _FakeAllVocabNotifier(sampleVocabs),
        ),
        dueVocabProvider.overrideWith(
          () => _FakeDueVocabNotifier(sampleVocabs.take(1).toList()),
        ),
        grammarListProvider.overrideWith(
          () => _FakeGrammarList(sampleGrammar),
        ),
        conversationListProvider.overrideWith(
          () => _FakeConversationList(sampleConversations),
        ),
      ],
    );
  }

  testWidgets('AppRoot shows mobile shell on tab screen', (tester) async {
    final container = buildContainer(navState: const NavState(AppRoutes.home));
    addTearDown(container.dispose);

    await pumpAppRoot(
      tester,
      container: container,
      logicalSize: const Size(390, 844),
    );

    expect(find.byType(BottomTabBarWidget), findsOneWidget);
    expect(find.byKey(const ValueKey('quick_actions_fab')), findsOneWidget);
    expect(find.byType(AppNavigationRail), findsNothing);
  });

  testWidgets('AppRoot shows rail shell on wide tab screen', (tester) async {
    final container = buildContainer(navState: const NavState(AppRoutes.home));
    addTearDown(container.dispose);

    await pumpAppRoot(
      tester,
      container: container,
      logicalSize: const Size(1100, 900),
    );

    expect(find.byType(AppNavigationRail), findsOneWidget);
    expect(find.byType(BottomTabBarWidget), findsNothing);
    expect(find.byKey(const ValueKey('rail_quick_actions_button')), findsOneWidget);
  });

  testWidgets('AppRoot hides primary nav on non-tab route', (tester) async {
    final container = buildContainer(
      navState: const NavState(AppRoutes.conversation),
    );
    addTearDown(container.dispose);

    await pumpAppRoot(
      tester,
      container: container,
      logicalSize: const Size(390, 844),
    );

    expect(find.byType(BottomTabBarWidget), findsNothing);
    expect(find.byType(AppNavigationRail), findsNothing);
    expect(find.byKey(const ValueKey('quick_actions_fab')), findsNothing);
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(container.read(navigationProvider).screen, AppRoutes.conversation);
  });

  testWidgets('AppRoot mobile quick action updates navigation state', (
    tester,
  ) async {
    final container = buildContainer(navState: const NavState(AppRoutes.home));
    addTearDown(container.dispose);

    await pumpAppRoot(
      tester,
      container: container,
      logicalSize: const Size(390, 844),
    );

    await tester.tap(find.byKey(const ValueKey('quick_actions_fab')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ngữ pháp'));
    await tester.pumpAndSettle();

    expect(container.read(navigationProvider).screen, AppRoutes.grammar);
  });
}
