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
