# Session Handoff - 2026-04-22

## Trang thai hien tai

Da hoan thanh:

- P0:
  - Chuan hoa dieu huong noi bo ve `navigationProvider`
  - Them route detail cho `vocab`, `grammar`, `conversation`
  - Luu `screen + arg` trong history
  - Sua bug `HanzifyCardVariant.glass`
  - Sua filter HSK o `grammar` va `conversation`
  - `await` lai mot so side effect quan trong trong flow hoc

- P1:
  - Tach DI khoi `presentation` sang `data/di`
  - Them `domain/usecases` cho cac hanh vi nghiep vu chinh
  - Chuyen presentation providers sang dung use case / repository contract
  - Regenerate codegen voi `build_runner`
  - `flutter analyze lib` sach

- P2 (da lam tiep trong phien nay):
  - Dua session state cua `flashcard` ve `flashcardSessionControllerProvider`
  - Tach practice session state cua `conversation detail` ve provider family theo `conversation.id`
  - Them primitive UI dung chung cho full-screen `loading/error`: `HanzifyAsyncStateView`
  - Them primitive UI dung chung cho inline async nho: `HanzifyAsyncInlineState`
  - Chuan hoa `loading/error` o `flashcard`, `vocab list`, `conversation list`
  - Chuan hoa them `loading/error` o `progress_screen` sang `HanzifyAsyncStateView`
  - Chuan hoa async inline trong `vocab_detail_screen.dart` cho preview stroke card
  - Ra soat lifecycle provider: giu `keepAlive` cho cac list/global cache, doi `profileStatsProvider` sang `autoDispose`
  - Ra soat `keepAlive`: doi `flashcardSessionControllerProvider` sang `autoDispose`; giu cache cho cac list providers dung xuyen nhieu man
  - Them test cho flashcard session provider, conversation practice provider, async state widget, profile stats provider

- P3/P4 (da lam tiep):
  - `vocab_detail_screen.dart`: doi hero ve `Card.filled`, dung lai badge/typography semantic hon, gom translation callout ve helper rieng, giam hardcode style o examples/related conversation/character preview
  - `auth_screen.dart`: doi toggle login/signup sang `SegmentedButton`, dua form vao `Card.filled`, CTA chinh dung `FilledButton`, loading state khong con shell gradient custom
  - `flashcard_study_view.dart`: giu visual study dac thu nhung da polish peripheral shell, meaning/example groups va grade button ve semantic/card pattern hon
  - `home_screen.dart`: them mot pass nho cho hero badge va card shell con sot
  - Bat dau P4:
    - tach navigation metadata dung chung cho bottom bar / rail / quick actions
    - them responsive shell: mobile dung bottom nav, tablet/web (`>= 840`) dung `NavigationRail`
    - thay speed dial custom bang quick action flow M3 hon:
      - mobile: FAB mo bottom sheet action menu
      - rail shell: `MenuAnchor` action menu gan rail
    - them widget test o muc `AppRoot` cho:
      - mobile tab shell
      - rail shell tren man hinh rong
      - route non-tab khong hien primary nav
      - quick action mobile cap nhat `navigationProvider` dung
    - them mot pass polish cho shell:
      - mobile shell ton trong bottom safe area cho FAB va bottom nav
      - them golden test cho `AppNavigationShell` o ca mobile va rail shell
  - Cleanup tiep:
    - `conversation_screen.dart`: hero carousel bo `shuffle()` moi build, giam `Colors.white/TextStyle` hardcode, dua label/title/CTA gan `textTheme` + `colorScheme` hon
    - `home_screen.dart`: bo state/scroll listener cu con sot tu speed dial extension; screen gọn hon sau khi quick action FAB da ra shell chung
    - `home_screen.dart`: doi `Study Now` CTA ve `Card.filled`, bo them custom gradient card; them content frame toi da cho tablet/web de canh layout on dinh hon trong rail shell

## Cac file quan trong da thay doi

- Dieu huong:
  - `lib/core/navigation/app_routes.dart`
  - `lib/core/navigation/navigation_actions.dart`
  - `lib/core/providers/navigation_provider.dart`
  - `lib/main.dart`

- P0 screens:
  - `lib/features/vocab/presentation/screens/vocab_list_screen.dart`
  - `lib/features/vocab/presentation/screens/vocab_detail_screen.dart`
  - `lib/features/conversation/presentation/screens/conversation_screen.dart`
  - `lib/features/conversation/presentation/screens/conversation_detail_screen.dart`
  - `lib/features/grammar/presentation/screens/grammar_screen.dart`
  - `lib/features/grammar/presentation/screens/grammar_detail_screen.dart`
  - `lib/features/character/presentation/screens/character_detail_screen.dart`
  - `lib/features/dashboard/presentation/screens/home_screen.dart`
  - `lib/features/vocab/presentation/screens/flashcard_screen.dart`

- DI moi:
  - `lib/features/vocab/data/di/`
  - `lib/features/grammar/data/di/`
  - `lib/features/conversation/data/di/`
  - `lib/features/character/data/di/`

- Use case moi:
  - `lib/features/vocab/domain/usecases/vocab_usecases.dart`
  - `lib/features/grammar/domain/usecases/grammar_usecases.dart`
  - `lib/features/conversation/domain/usecases/conversation_usecases.dart`
  - `lib/features/character/domain/usecases/character_usecases.dart`

- Presentation providers da doi sang use case:
  - `lib/features/vocab/presentation/providers/vocab_state.dart`
  - `lib/features/vocab/presentation/providers/vocab_filter_provider.dart`
  - `lib/features/vocab/presentation/providers/flashcard_state.dart`
  - `lib/features/vocab/presentation/providers/vocab_providers.dart`
  - `lib/features/grammar/presentation/providers/grammar_providers.dart`
  - `lib/features/conversation/presentation/providers/conversation_practice_state.dart`
  - `lib/features/conversation/presentation/providers/conversation_providers.dart`
  - `lib/features/character/presentation/providers/character_providers.dart`

- Wiring lien quan:
  - `lib/core/platform/platform_web.dart`
  - `lib/core/graph/graph_providers.dart`
  - `lib/core/widgets/hanzify_async_state_view.dart`
  - `lib/features/dashboard/presentation/screens/progress_screen.dart`
  - `lib/features/vocab/presentation/screens/vocab_detail_screen.dart`
  - `lib/features/profile/presentation/providers/profile_stats_provider.dart`

## Xac nhan da chay

- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze lib`
- `flutter test test/features/vocab/flashcard_state_test.dart test/features/vocab/flashcard_setup_view_test.dart test/features/vocab/flashcard_study_view_test.dart`
- `flutter test test/features/conversation/conversation_practice_state_test.dart`
- `flutter test test/core/widgets/hanzify_async_state_view_test.dart`
- `flutter test test/features/profile/profile_stats_provider_test.dart`
- `flutter analyze lib/core/widgets/hanzify_async_state_view.dart lib/features/vocab/presentation/screens/flashcard_screen.dart lib/features/vocab/presentation/screens/vocab_list_screen.dart lib/features/conversation/presentation/screens/conversation_screen.dart lib/features/conversation/presentation/providers/conversation_practice_state.dart lib/features/conversation/presentation/screens/conversation_detail_screen.dart`
- `flutter analyze`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze lib/features/conversation/presentation/screens/conversation_detail_screen.dart`
- `flutter analyze lib/features/grammar/presentation/screens/grammar_detail_screen.dart`
- `flutter analyze lib/features/grammar/presentation/screens/grammar_screen.dart lib/features/conversation/presentation/screens/conversation_screen.dart lib/features/vocab/presentation/screens/vocab_list_screen.dart`
- `flutter analyze lib/features/vocab/presentation/screens/quiz/widgets/quiz_mode_selection.dart lib/features/vocab/presentation/screens/flashcard/widgets/flashcard_setup_view.dart`
- `flutter analyze lib/main.dart lib/core/widgets/app_navigation_shell.dart lib/core/widgets/app_navigation_rail.dart lib/core/widgets/bottom_tab_bar.dart lib/features/dashboard/presentation/widgets/hanzify_speed_dial.dart lib/features/dashboard/presentation/screens/home_screen.dart lib/features/vocab/presentation/screens/vocab_detail_screen.dart lib/features/auth/presentation/screens/auth_screen.dart lib/features/vocab/presentation/screens/flashcard/widgets/flashcard_study_view.dart`
- `flutter analyze lib/features/conversation/presentation/screens/conversation_screen.dart lib/features/dashboard/presentation/screens/home_screen.dart`
- `flutter analyze test/core/widgets/app_navigation_shell_test.dart test/features/auth/auth_screen_test.dart test/features/vocab/vocab_detail_screen_test.dart lib/core/widgets/app_navigation_shell.dart lib/core/widgets/app_navigation_rail.dart lib/features/dashboard/presentation/widgets/hanzify_speed_dial.dart`
- `flutter test test/core/widgets/app_navigation_shell_test.dart test/features/auth/auth_screen_test.dart test/features/vocab/vocab_detail_screen_test.dart test/features/vocab/flashcard_study_view_test.dart`
- `flutter test test/app_root_responsive_test.dart`
- `flutter analyze lib/core/widgets/app_navigation_shell.dart lib/core/widgets/bottom_tab_bar.dart test/core/widgets/app_navigation_shell_test.dart test/app_root_responsive_test.dart`
- `flutter test test/core/widgets/app_navigation_shell_test.dart test/app_root_responsive_test.dart`
- `flutter analyze lib`

Ket qua cuoi cung: khong con issue.

## Viec tiep theo de lam

Uu tien tiep theo sau P2.4:

1. Neu muon di tiep P2.4:
   - Ghi chu ly do `keepAlive` ngay trong source cho cac provider con lai de nguoi sau khong doan
   - Neu doi tiep lifecycle, uu tien provider derived/screen-scoped truoc, khong dong vao list cache dung da man hinh
2. Chuan bi sang P3:
   - Rasoat nhung screen con hardcode `Container + BoxDecoration + Colors.*`
   - Xac dinh 1-2 screen nen dua ve Material 3 component truoc

## Task backlog cho cac phien sau

### Session tiep theo gan nhat

- [x] P2.4-C: Bo sung comment rationale trong source cho cac provider con `keepAlive`
  - `allVocabProvider`: dung o dashboard, profile, vocab list/detail, quiz
  - `dueVocabProvider`: dung o home, progress, flashcard/quiz flow
  - `conversationListProvider`: dung o home, conversation screen, grammar/conversation detail fallback
  - `grammarListProvider`: dung o home, grammar screen, conversation/grammar detail fallback
  - `graphRepositoryProvider`: asset graph cache, load ton chi phi
- [ ] P2.4-D: Can nhac `autoDispose` cho derived provider screen-scoped khac neu xuat hien
  - Hien tai da doi `profileStatsProvider` sang `autoDispose`

### Session sau nua

- [x] P3-A: Chon 1 screen de lam mau Material 3
  - Da chon: `progress_screen.dart`
- [~] P3-B: Giam hardcode style mau/khoang cach o screen duoc chon
  - Da lam mot pass o `progress_screen.dart`: doi mot so mau hardcode sang semantic color (`success`/`warning`), dung `textTheme` cho label/title nho, them type an toan cho chart data
  - Da lam tiep pass thu hai: doi outer shell cua hero/action card/stat icon sang `Card`/`Card.filled` + `Ink`, giam them `Container + BoxDecoration`
  - Da lam them pass cuoi: tach `progress_screen.dart` thanh cac section widget nho (`_ProgressHeroCard`, `_ActionRow`, `_ReviewAlertCard`) de giam do lon cua screen
  - Da bat dau screen thu hai: `conversation_detail_screen.dart`
  - Da doi mode toggle sang `SegmentedButton`, doi hero sang `Card`/`Ink`, doi culture tip icon box sang `Card.filled`
  - Da lam tiep mot pass nua o `conversation_detail_screen.dart`: doi `PlayButton` sang `OutlinedButton`, doi `PracticeCard` outer shell sang `Card.filled`, doi avatar/icon tron sang `CircleAvatar`, them `InkWell` cho vung translation
  - Da lam tiep pass tach section: hero/mode toggle/dialogue/practice/culture tip da duoc tach thanh widget private rieng
  - Da lam tiep pass don widget con: `_ConversationBubble` va `_PracticeCard` duoc tach thanh cac phan con nho; vocab/grammar inline cards duoc gom ve tile base chung
  - Da lam them mot pass nho: fallback `related grammar` dung lai `_GrammarCard` chung, CTA/nav button label dung typography helper thay vi hardcode `TextStyle`
  - Da bat dau screen thu ba: `grammar_detail_screen.dart`
  - Da doi hero sang `Card`/`Ink`, gom formula parts ve helper chip, gom translation accent bar ve helper dung chung
  - Da lam tiep pass P3-B: `usage` va `related grammar` duoc gom ve helper tile chung, giam them markup lap o `conv sentences`/CTA
  - Da lam them mot pass cleanup: tach `example` card va `conversation sentence` card thanh helper rieng, gom translation copy dung chung, doi hardcode `TextStyle/Colors.white` con sot sang typography/theme color
  - P3-B cho `grammar_detail_screen.dart` co the xem la da xong; buoc tiep theo hop ly la P3-C

### Session P3 mo dau

- [~] P3-C: Doi cac filter/mode hoc hop ly sang component M3
  - Da doi filter HSK o `grammar_screen.dart` sang `SegmentedButton`
  - Da doi filter HSK o `conversation_screen.dart` sang `SegmentedButton`
  - Da tach filter `vocab_list_screen.dart` thanh 2 lop: HSK dung `SegmentedButton`, POS giu `FilterChip`
  - Da doi `quiz_mode_selection.dart` sang flow `SegmentedButton` + preview card + CTA
  - Da doi mode/limit trong `flashcard_setup_view.dart` sang `SegmentedButton`; mode card custom duoc thay bang preview card M3 gon hon
  - Da dua search header o `vocab_list_screen.dart`, `grammar_screen.dart`, `conversation_screen.dart` ve `SearchAnchor` dung chung (`HanzifySearchAnchor`) voi search view + suggestion list
  - Con lai neu muon day tiep: can nhac search facet/filter nang cao hon neu can, nhung phan doi component M3 co the xem la co ban da xong

## Ghi chu

- `presentation` khong con tao datasource/repository impl truc tiep
- `vocab_providers.dart` hien tai chi `export` DI moi de giam ripple voi import cu
- `conversation_detail_screen.dart` van giu local state cho autoplay va toggle dich tung bubble; chi practice session da duoc tach ra
- `conversationPracticeSessionProvider` da la `autoDispose` do dung `@riverpod` family mac dinh
- `flashcardSessionControllerProvider` da doi sang `autoDispose`; test da cover reset state sau dispose
- `allVocabProvider`, `dueVocabProvider`, `conversationListProvider`, `grammarListProvider` tam thoi giu `keepAlive` vi duoc dashboard/profile/home/detail dung chung
- `profileStatsProvider` da doi sang `autoDispose` vi chi la derived provider cua `allVocabProvider` va chi dung trong `profile_screen`
- `progress_screen.dart` da duoc doi sang `HanzifyAsyncStateView` cho top-level `allVocabAsync`; `dueVocabAsync` van dang fail-soft qua `asData`
- `progress_screen.dart` da bat dau pass P3: giam mau/style hardcode, uu tien `textTheme` va semantic color
- `conversation_detail_screen.dart` da co pass P3 dau tien: bo `_ModeTab` custom de dung `SegmentedButton`, giam them `Container + BoxDecoration` o hero/culture tip
- `conversation_detail_screen.dart` da co them mot pass P3-B: giam them `Container + BoxDecoration` o play button, practice card, avatar/icon tron
- `conversation_detail_screen.dart` da duoc tach them thanh cac section widget private, nen `State` gọn hon va de doc hon
- `conversation_detail_screen.dart` da duoc don sau hon: bubble/practice/tile cards duoc chia thanh widget con nho hon, giam lap markup
- `conversation_detail_screen.dart` da co them pass cleanup nho: fallback related grammar khong con 1 card markup rieng; CTA va nav button label dung helper typography chung
- `grammar_detail_screen.dart` da co pass P3 dau tien: hero/formula/example accents duoc dua gan Material 3 hon
- `grammar_detail_screen.dart` da co them pass P3-B: usage/related grammar cards duoc gom ve helper tile chung
- `grammar_detail_screen.dart` da co them pass cleanup nua: example/conversation sentence cards va translation copy da duoc tach helper rieng; hardcode style con sot da giam tiep
- `grammar_detail_screen.dart` da duoc ra soat lai; cac async section hien dang theo `HanzifyAsyncSectionState`, chua can sua them
- `grammar_screen.dart` da doi bo chon HSK tu card ngang custom sang `SegmentedButton`
- `conversation_screen.dart` da doi bo loc HSK ngang sang `SegmentedButton`
- `vocab_list_screen.dart` da tach filter theo semantics M3 hon: HSK la `SegmentedButton`, POS la `FilterChip`; khong con 1 day chip tron chung cho ca level va word type
- `vocab_list_screen.dart`, `grammar_screen.dart`, `conversation_screen.dart` da doi tu `SearchBar` thuần sang `SearchAnchor` dung chung; search view hien suggestion theo du lieu hien co thay vi chi co 1 thanh search tĩnh
- `quiz_mode_selection.dart` da doi tu danh sach card click truc tiep sang `SegmentedButton` + preview + nut bat dau, gan Material 3 hon
- `flashcard_setup_view.dart` da doi mode hoc va gioi han the sang `SegmentedButton`; HSK 0-6 tam thoi giu `ChoiceChip` vi segmented 7 muc de tran layout tren mobile

## Rasoat P3 con lai

Sau khi quet lai `presentation screens` va cac widget lien quan, P3 khong con backlog lon o filter/mode. Phan con lai tap trung o vai screen co mat do style custom cao:

### Uu tien cao neu muon them 1 pass P3 nua

- `lib/features/dashboard/presentation/screens/home_screen.dart`
  - Da co them mot pass cleanup: study CTA, HSK cards, due vocab rows va conversation preview da duoc dua gan `Card`/`CircleAvatar`/semantic text color hon
  - Da co them pass responsive content frame cho tablet/web va doi CTA hoc nhanh sang `Card.filled`
  - Van con mot hero accent custom nho, nhung mat do style cu da giam dang ke
- `lib/features/vocab/presentation/screens/vocab_detail_screen.dart`
  - Da co them pass cleanup lon; co the xem la dat muc dong P3 o screen-level
- `lib/features/vocab/presentation/screens/flashcard/widgets/flashcard_study_view.dart`
  - Da co pass polish vua du; van giu visual study dac thu co chu dich, khong can ep ve M3 thuan trong P3

### Uu tien trung binh

- `lib/features/auth/presentation/screens/auth_screen.dart`
  - Da co pass cleanup lon; co the xem la dat muc dong P3 o screen-level
- `lib/features/conversation/presentation/screens/conversation_screen.dart`
  - Filter/search da len M3; hero carousel da duoc don them mot pass va khong con `shuffle()` moi build
  - Van con mot it visual custom o hero/card ngang, nhung khong con la diem lech lon neu dong P3
- `lib/features/grammar/presentation/screens/grammar_detail_screen.dart`
  - Da sach hon nhieu; con mot it accent container nho, khong gap

### Khong can uu tien trong P3 screen pass

- Nhieu `core/widgets/*` van co `Container/BoxDecoration/Colors.*`, nhung day la widget nen/co chu y do hoa rieng (`hanzify_card`, `swipeable_flashcard`, `hanzify_streak_badge`, ...)
  - Chi nen sua neu muon lam them mot pass rieng o design system/widget foundation

### Ket luan tam thoi

- Co the xem `P3-B` va `P3-C` la da xong o muc screen-level / component migration co ban
- P3 co the xem la da dong duoc neu chap nhan:
  - `home_screen.dart` con mot hero accent custom nho
  - `conversation_screen.dart` con mot it hero/card custom nho
  - `core/widgets/*` van con custom foundation nhung da duoc de ngoai P3
- P4 da duoc kick off o muc dau tien:
  1. responsive nav shell (`NavigationRail` cho width `>= 840`)
  2. quick action menu thay cho speed dial custom
  3. nav metadata dung chung giua bottom nav / rail / quick actions
  4. `AppRoot` da co test responsive/root-level co ban; da them pass polish layout + golden cho shell moi
  5. Buoc tiep theo neu muon day tiep P4 la smoke test UI tren tablet/web hoac mo rong golden o muc root/screen thuc te
