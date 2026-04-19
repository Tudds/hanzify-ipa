# UI/UX Redesign Plan v2

**Trạng thái:** Plan v2 — chưa bắt đầu
**Scope:** Rebuild UI/UX, giữ nguyên business logic (SRS, repo, DB, auth, providers).
**Ngày cập nhật:** 2026-04-19

---

## 🎯 Triết lý thiết kế

**Mục tiêu cao nhất: tối ưu trải nghiệm học và ôn tập nội dung.**

1. **Content-first hierarchy** — Hanzi, pinyin, nghĩa luôn là element visual chính. UI chrome (app bar, nav, card frame) lùi ra sau.
2. **Purposeful motion** — Animation phục vụ học (feedback, progression, memory cue), không phải decoration. Mỗi animation trả lời câu hỏi: *user học được gì từ chuyển động này?*
3. **Calm baseline, delightful peaks** — Browsing/reading: tĩnh, đọc dễ. Milestone (đúng câu, streak, level up): celebrate rõ ràng.
4. **Haptic + Visual + Audio** — 3 kênh feedback phải nhất quán ở mọi tương tác quan trọng (tap card, đáp đúng/sai, hoàn thành set).
5. **Progressive disclosure** — Screen chính cho overview, tap để xem sâu. Không nhồi nhét mọi info lên flat surface.
6. **Respect cognitive load** — Học ngôn ngữ đã nặng não. UI phải ra khỏi đường. Tối đa 1-2 animation đồng thời, không stagger toàn màn hình.

**Design tokens:**
- **Color:** Material 3 `ColorScheme.fromSeed` + 3 theme (light/dark/sepia). Semantic: primary, success, warning, error, info + containers tương ứng.
- **Typography:** Manrope (headline), Inter (body/pinyin), Noto Serif SC (Hanzi display), Noto Sans SC (Hanzi UI).
- **Spacing:** 4pt grid (`AppSpacing.xs=4` → `xxxl=48`).
- **Radii:** `sm=4`, `md=8`, `lg=12`, `xl=16`, `xxl=24`, `full=9999`.
- **Motion:** M3 motion spec — `micro=150`, `fast=200`, `normal=250`, `slow=300`, `modal=400`. Easing: `Curves.easeOutCubic` (enter), `Curves.easeInCubic` (exit), `Curves.easeInOutCubic` (transform).

---

## 📐 Information Architecture

Giữ nguyên 6 tab/flow chính:
- **Home** — overview, lesson of the day, streak, quick actions
- **Vocab** — list, detail, flashcard study, quiz
- **Character** — hanzi detail với stroke animation
- **Grammar** — list, detail with example drills
- **Conversation** — scenario list, dialog practice
- **Profile/Progress** — stats, streak, settings

### Đổi mới IA (3 touchpoints)

Không đổi tab structure. Chỉ bổ sung 3 điểm chạm để user luôn biết "hôm nay cần làm gì" và "còn bao nhiêu".

#### a) Study Hub — màn entry point mới trong Vocab tab
**Vấn đề hiện tại:** user vào Vocab chỉ thấy list từ; phải tự mò nút flashcard/quiz ở đâu.

**Đổi mới:** tab Vocab mở ra là Study Hub, list là sub-screen.
```
📚 Học hôm nay
  ├─ 🔄 Ôn tập: 24 thẻ due         → FlashcardStudyView(review)
  ├─ ✨ Từ mới: 10 thẻ chưa học    → FlashcardStudyView(new)
  ├─ 🎯 Quiz nhanh: 10 câu         → QuizModeSelection
  └─ 📖 Tất cả từ vựng             → VocabListScreen
```

**Impl:**
- Tạo screen mới `StudyHubScreen` (`lib/features/vocab/presentation/screens/study_hub_screen.dart`).
- Provider `studyHubStatsProvider` → đếm due count, new count từ existing repo.
- Route `/vocab` trỏ vào Study Hub; `VocabListScreen` chuyển thành `/vocab/list`.
- Mỗi entry = `HanzifyCard` với icon + count badge + CTA.

#### b) Daily goal ring — visualize progress hôm nay
**Vấn đề:** streak hiện là số chết; user không cảm giác "gần xong goal hôm nay".

**Đổi mới:** `HanzifyProgressRing` ở Home — vòng tròn `0/20 cards today`. Mỗi card học xong, ring fill. Đầy ring → confetti + streak +1.

**Impl:**
- Provider `dailyGoalProvider` (target + current count, persist qua `AsyncPrefsNotifier`).
- Target default 20, user chỉnh được ở Profile.
- Ring widget dùng `CustomPainter` + `TweenAnimationBuilder<double>` 800ms.
- Trigger confetti khi value chạm 1.0 (1 lần/ngày, guard bằng flag `todayCompleted`).

#### c) Review badge — due count trên bottom tab
**Vấn đề:** bottom tab icon tĩnh; user không biết có bao nhiêu card cần ôn nếu không mở Vocab.

**Đổi mới:** Vocab tab có badge đỏ hiển thị due count:
```
[Home] [Vocab•24] [Character] [Grammar] [Profile]
```

**Impl:**
- Provider `dueCountProvider` watch DB, return `int`.
- `BottomTabBarWidget` thêm optional `badgeCount` cho mỗi tab item.
- Badge: small red dot 18px với number `AppFontSizes.labelSm`.
- Hide badge khi count=0; auto-refresh khi user grade flashcard.

---

---

## 🧩 Phase 0 — Design tokens audit & motion system

**DoD:** tokens đủ dùng cho mọi screen, không ai cần hardcode.

- [ ] Verify `AppSpacing` — bỏ `md2=10`, `xxxs=2`, `xxs=5` (lẻ, không thuộc 4pt grid). Add `fabBottomSafe` = `scrollBottom + safeArea`.
- [ ] Verify `AppRadii` — dedupe `sm=4`/`xs=6` (giữ 1). Add `pill` alias cho `full`.
- [ ] Verify `AppFontSizes` — thêm `hanziStudy=120` (flashcard huge), `hanziCard=64` (vocab list item).
- [ ] `AppThemeColors` bổ sung semantic: `studyCorrect`, `studyWrong`, `studyDue`, `studyNew`, `studyMastered` (distinct từ success/error chung).
- [ ] `AppDurations` bổ sung: `flip=450`, `celebrate=800`, `streak=1200`, `stroke=2000` (character writing).
- [ ] Tạo `AppCurves`: `enter`, `exit`, `emphasis`, `spring` (cho swipe card).
- [ ] Tạo `AppElevation`: `flat=0`, `raised=1`, `floating=3`, `modal=8` → `BoxShadow` presets (max `blurRadius=16`, `alpha<=0.08`).

---

## 🧱 Phase 1 — Shared widget gap-fill

Audit cho thấy 80% widget đã có. Chỉ cần bổ sung những gap.

### Widget mới

- [ ] **`HanzifyIconBox`** (thay hardcoded 40/44/50 icon containers ngoài phạm vi `HanzifyIconAvatar`)
  - Variants: `size={sm:32, md:40, lg:48, xl:56}`, `shape={square, rounded, circle}`
- [ ] **`HanzifySettingsTile`** — leading icon + title + subtitle + trailing slot (Switch/chevron/badge). Tap scale micro-interaction.
- [ ] **`HanzifyHskBadge`** — wrapper `HanzifyBadge` auto-color bằng `c.hskColors[level-1]`.
- [ ] **`HanzifyStreakBadge`** — 🔥 icon + số, animated khi tăng.
- [ ] **`ShakeWidget`** — stateful wrapper cho shake animation (tách khỏi QuizQuestionView).
- [ ] **`HanzifyTextField`** — 1 InputDecoration chuẩn (focus/error/disabled/filled), dùng cho Auth + Search.
- [ ] **`HanzifyProgressRing`** — circular progress ring với number ở giữa (daily goal).
- [ ] **`HanzifyConfettiOverlay`** — wrap screen, trigger on milestone. Dùng package `confetti`.
- [ ] **`HanzifyPulseDot`** — small animated dot cho "live/due" indicator.
- [ ] **`HanzifyShimmerBox`** — loading skeleton với `LinearGradient` animated (tự implement, không dùng package).

### Refactor widget hiện có

- [ ] **`HanzifyAnimations`** (22 dòng hiện tại — mỏng) → mở rộng thành helper library:
  - `FadeSlideIn(child, delay)` — standard enter
  - `ScaleInOut(show, child)` — conditional visibility
  - `CountUp(from, to, duration)` — XP/số đếm
  - `AnimatedHanzi(char)` — scale+fade khi đổi character
- [ ] **`HanzifyCard`** — thêm variant `study` (bigger radius, softer shadow cho flashcard) + optional `onLongPress` (preview).
- [ ] **`HanzifyGradientFab`** → rename `HanzifyFab`, default solid primary, gradient là optional flag.
- [ ] **`HanzifyAppBar`** — thêm prop `progress` để render LinearProgressIndicator 2px dưới title (cho quiz/flashcard).

---

## 🎬 Phase 2 — Motion & interaction patterns (core)

Thiết kế **motion language** thống nhất, dùng cho mọi screen học.

### A. Enter/exit transitions
- **Screen → screen:** `CupertinoPageTransitionsBuilder` (slide + fade, 350ms).
- **Modal/bottom sheet:** `DraggableScrollableSheet` với snap points.
- **Card list → detail:** `Hero` cho Hanzi char + pinyin, 400ms `easeInOutCubic`.

### B. Feedback motion
- **Tap:** `scale 0.96` + haptic `selectionClick` (100ms).
- **Correct answer:** border pulse `c.success` (2 pulses, 200ms each) + confetti burst + haptic `mediumImpact` + TTS play.
- **Wrong answer:** `ShakeWidget` (3 oscillations, 400ms total) + border flash `c.error` + haptic `heavyImpact` + sau đó reveal đáp án đúng fade in 300ms.
- **Streak increment:** streak badge scale 1→1.3→1 (spring) + particle burst quanh badge.

### C. Study-specific motion
- **Flashcard flip:** `AnimatedSwitcher` với `FadeTransition` + scale 0.95→1 (450ms, không 3D Y-rotate nặng).
- **Flashcard swipe (Tinder-style):** GestureDetector + `SpringSimulation`, drag threshold 30% width → commit, else snap back. Label "Easy/Hard/Again" fade in theo drag direction.
- **Character stroke animation:** CustomPainter vẽ path theo `AnimationController`, play on detail open + replay button. Duration `AppDurations.stroke`.
- **Pinyin highlight:** khi TTS đang đọc, character tương ứng highlight với `AnimatedDefaultTextStyle` (color + weight).
- **Progress ring:** `TweenAnimationBuilder<double>` 800ms `easeOutCubic` khi value đổi.
- **XP/Level up:** `CountUp` number + full-screen `HanzifyConfettiOverlay` + Lottie mascot (optional).

### D. List interactions
- **Due card pulse:** dot ở góc card, pulse loop nhẹ (1.0 → 1.3 scale, 1.5s infinite) — chỉ khi `performanceProvider == false`.
- **Slidable actions:** Flutter `Dismissible` với `DragStartBehavior.start`, confirm dialog trước khi delete.
- **Filter chip select:** `AnimatedContainer` color + bg, 200ms.

### E. Empty/loading states
- **Loading:** shimmer skeleton (package `shimmer` hoặc custom `LinearGradient` animated), **không** `CircularProgressIndicator` cho list.
- **Empty:** `HanzifyEmptyState` + subtle float animation (Y±4px sine, 2s loop).
- **Error:** static illustration + retry button.

**Performance guard:** mọi motion nặng (confetti, stroke replay, particle burst) check `performanceProvider` và fallback về version đơn giản (color change only) nếu disabled.

---

## 🖼 Phase 3 — Screen-by-screen rebuild

Thứ tự ưu tiên theo impact on learning UX:

### 1. `FlashcardStudyView` ⭐⭐⭐ (nặng nhất)
- **Layout:** full-screen card, minimal chrome. Top: progress bar + back. Bottom: 4 grade buttons.
- **Card:** Hanzi `hanziStudy=120` center, pinyin dưới, nghĩa ẩn. Tap/swipe up để reveal nghĩa.
- **Flip:** `AnimatedSwitcher` với `FadeTransition + ScaleTransition` (0.95→1, 450ms).
- **Grade buttons:** 4 `HanzifyCard` outlined: Again/Hard/Good/Easy với color semantic (red/orange/blue/green).
- **TTS:** auto-play pinyin khi reveal, replay button.
- **Swipe gesture:** left=Again, down=Hard, right=Good, up=Easy (optional).
- **Progress:** `HanzifyAppBar(progress: currentIdx/total)`.
- **Milestone:** khi xong deck → confetti + summary screen (correct/total + XP gained + streak).

### 2. `ConversationDetailScreen` ⭐⭐⭐
- **Layout:** chat-like bubbles. Speaker A (left): `c.primaryContainer`, bottomLeft=4. Speaker B (right): `c.surfaceContainerHigh`, bottomRight=4.
- **Bubble content:** Hanzi lớn + pinyin + nghĩa toggle.
- **Practice mode:** tap bubble → record voice, compare pronunciation với TTS (nếu mic permission ok). Visual waveform.
- **Auto-play:** sequence play mode, bubble tương ứng highlight.
- **Extract** `_ConversationBubble(isA, vocab, isPlaying)`.

### 3. `QuizQuestionView` ⭐⭐
- **Layout:** question top, 4 options vertical, progress top, streak top-right.
- **Options:** `HanzifyQuizOption` (đã có) — verify: đúng fade green bg + icon check, sai → `ShakeWidget` + red border + auto-reveal đáp án đúng (highlight green).
- **Streak:** `HanzifyStreakBadge` + scale animation khi +1.
- **Feedback delay:** `AppDurations.quizFeedback=1400` trước khi next.
- **Between questions:** `AnimatedSwitcher` fade+slide từ phải sang.

### 4. `HomeScreen` ⭐⭐
- **Hero zone:** greeting + daily goal `HanzifyProgressRing` + streak badge.
- **"Học hôm nay" card:** số card due + CTA "Bắt đầu" (deep link vào FlashcardStudyView).
- **Section: Lesson of the day** — 1 HSK level cards carousel.
- **Section: Quick review** — 3-5 due vocab preview.
- **Bỏ `.animate()` chain.** Chỉ fade-in toàn screen 200ms on first mount.

### 5. `ProgressScreen` ⭐⭐
- **Top:** streak + total learned (`CountUp`).
- **Heatmap:** 30-day activity grid (custom widget).
- **BarChart:** weekly/monthly toggle (SegmentedButton).
- **Achievements:** grid `HanzifyBadge` earned/locked.
- **Mastery by HSK:** 6 progress bars, color = `hskColors[i]`.

### 6. `VocabListScreen` ⭐
- **Search:** sticky top, `HanzifyTextField` variant search.
- **Filter chips:** horizontal scroll, `HanzifyFilterChip` — HSK level, due status, mastery.
- **List item:** `HanzifyCard` solid, trái = level stripe (3px `hskColors[i]`), Hanzi `hanziCard=64`, pinyin nhỏ, nghĩa Vietnamese. Trailing: `HanzifyPulseDot` nếu due.
- **Hero:** Hanzi char → detail.
- **Slidable:** delete với confirm.

### 7. `VocabDetailScreen` ⭐
- **Hero Hanzi:** `hanziDisplay=120` center top, không ShaderMask.
- **Pinyin:** dưới Hanzi, tap → TTS play.
- **Nghĩa:** list meanings với POS badge (dùng `posColors`).
- **Examples:** collapsible section, mỗi example có TTS button.
- **Stroke order:** button → mở dialog với `CustomPainter` stroke animation.
- **Study controls:** "Add to deck" / "Mark as learned" bottom sheet.

### 8. `CharacterDetailScreen` ⭐
- **Hero char:** `hanziDisplay=160`.
- **Stroke animation:** `CustomPainter` auto-play on mount + replay button.
- **Stats:** stroke count, radical, HSK level (chips).
- **Related vocab:** list chip grid các vocab chứa char này.
- **Etymology:** collapsible if có.

### 9. `GrammarScreen`
- **Featured card:** "Bài hôm nay" — 1 grammar point nổi bật, `HanzifyCard` solid.
- **List:** grouped by HSK level, section headers sticky.
- **Item:** `HanzifyCard` outlined với formula ngắn + nghĩa.

### 10. `GrammarDetailScreen`
- **Hero:** grammar title + formula badge.
- **Formula parts:** mỗi phần 1 `HanzifyCard` outlined, highlight khi tap.
- **Examples:** 3-5 examples với TTS + highlight từ vựng tương ứng.
- **Usage tips:** tips list với icon.

### 11. `ConversationScreen`
- **Bỏ glow orbs carousel.** Thay bằng `HanzifyScreenHeader` variant primary + welcome text.
- **TabBar:** M3 default, indicator `c.primary`.
- **Category cards:** `HanzifyCard` solid + `HanzifyIconBox` lg.

### 12. `FlashcardSetupView` + `QuizModeSelection`
- Mode tiles: `HanzifyCard` outlined, active border `c.primary` + bg `c.primaryContainer`.
- Deck size slider: M3 Slider.
- Start FAB: `HanzifyFab` solid.

### 13. `ProfileScreen`
- **User card:** `HanzifyCard` solid + avatar + display name + join date.
- **Stats row:** streak / total learned / level (`CountUp`).
- **Settings:** `HanzifySettingsTile` cho Theme / Performance / Language / Notifications.
- **Achievements preview:** horizontal scroll badges.
- **Logout:** bottom, `OutlinedButton`.

### 14. `AuthScreen`
- **Padding:** `AppSpacing.xl` horizontal.
- **Tab:** `SegmentedButton` M3 (Đăng nhập / Đăng ký).
- **Fields:** `HanzifyTextField`.
- **Submit:** `FilledButton` + loading state in-place.
- **Keep:** guest mode CTA bottom.

### 15. `main.dart` (App Shell)
- Background: solid `c.background`, bỏ `heroMesh`.
- Tab switch: `AnimatedSwitcher` với `FadeTransition` 150ms (thay custom slide).
- Tab bar: giữ `BottomTabBarWidget` hiện tại, add badge cho Vocab tab (số due).

---

## ♿ Phase 4 — Accessibility & polish

- [ ] **Semantics:** Hanzi → `Semantics(label: '$char, pronounced $pinyin, meaning $meaning')`.
- [ ] **TextScaler:** test 130%, 200%. Không overflow, không ellipsis quan trọng.
- [ ] **Contrast:** WCAG AA tối thiểu (4.5:1 body, 3:1 large). Dark/sepia đều check.
- [ ] **Reduced motion:** khi `performanceProvider == true` hoặc `MediaQuery.disableAnimations` → disable confetti/pulse/stroke auto-play.
- [ ] **Screen reader order:** verify focus traversal đúng ở mọi screen.
- [ ] **Touch target:** min 44×44 cho mọi interactive.
- [ ] **Keyboard nav:** Tab/Enter hoạt động trên web build.

---

## 🧪 Phase 5 — Testing & QA

- [ ] **Golden tests** cho shared widgets chính (`HanzifyCard`, `HanzifyBadge`, `HanzifyFilterChip`, `HanzifyStreakBadge`, `HanzifyProgressRing`).
- [ ] **Widget tests** cho `FlashcardStudyView` flow (reveal → grade → next).
- [ ] **Widget tests** cho `QuizQuestionView` flow (select → feedback → next).
- [ ] **Integration test** golden path: login → browse vocab → study flashcard → quiz → logout.
- [ ] **Visual QA checklist:**
  - Light theme mọi screen
  - Dark theme mọi screen
  - Sepia theme mọi screen
  - Landscape orientation (mobile)
  - Web build responsive (600/900/1200px)
  - `performanceProvider=true` variant
- [ ] **Manual perf check:** DevTools timeline, không frame drop >16ms trên scroll vocab list 500+ items.

---

## 📦 Dependencies

### Thêm mới
| Package | Mục đích | Version |
|---|---|---|
| `confetti` | Celebration burst cho milestone (deck complete, streak, level up) | ^0.7.0 |

### Giữ nguyên (đã có)
| Package | Mục đích |
|---|---|
| `flutter_animate` | Enter animation đơn giản (fadeIn, slideY). **Không dùng** cho stagger chain. |

### Skip (tự implement)
- **`shimmer`** — tự làm loading skeleton bằng `LinearGradient` animated (~30 dòng), dùng ở ≤4 chỗ. Tạo widget `HanzifyShimmerBox` trong Phase 1.
- **`rive`** — skip ở rebuild này. Chỉ cân nhắc sau khi core xong và có designer tạo `.riv` file. Stroke animation dùng `CustomPainter` thuần.

---

## 🗓 Roadmap & tiến độ

| Phase | Mô tả | Trạng thái |
|---|---|---|
| 0 | Tokens audit | ✅ |
| 1 | Shared widgets gap-fill | ✅ |
| 2 | Motion patterns core | ⬜ |
| 3.1 | FlashcardStudyView | ⬜ |
| 3.2 | ConversationDetailScreen | ⬜ |
| 3.3 | QuizQuestionView | ⬜ |
| 3.4 | HomeScreen | ⬜ |
| 3.5 | ProgressScreen | ⬜ |
| 3.6 | VocabListScreen + Detail | ⬜ |
| 3.7 | CharacterDetailScreen | ⬜ |
| 3.8 | GrammarScreen + Detail | ⬜ |
| 3.9 | ConversationScreen | ⬜ |
| 3.10 | Setup/Mode selection | ⬜ |
| 3.11 | ProfileScreen | ⬜ |
| 3.12 | AuthScreen + Shell | ⬜ |
| 4 | A11y & polish | ⬜ |
| 5 | Testing & QA | ⬜ |

*Legend: ⬜ Chưa bắt đầu · 🔄 Đang làm · ✅ Hoàn thành · ⏸ Tạm dừng*

---

## 📝 Nguyên tắc commit

- 1 phase = 1 branch: `redesign/phase-{n}-{slug}`.
- Mỗi screen trong Phase 3 = 1 commit atomic với before/after screenshot trong PR description.
- Không mix refactor logic và UI change trong cùng commit.
- Commit message: `refactor(ui): <screen> — <summary>`.
