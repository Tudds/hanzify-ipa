import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { shorts, dictionary, quiz, chat, review }

extension AppTabRoute on AppTab {
  String get path => switch (this) {
    AppTab.shorts => '/',
    AppTab.dictionary => '/dictionary',
    AppTab.quiz => '/quiz',
    AppTab.chat => '/chat',
    AppTab.review => '/review',
  };
}

class TabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.shorts;

  void set(AppTab tab) => state = tab;
}

final tabProvider = NotifierProvider<TabNotifier, AppTab>(TabNotifier.new);
