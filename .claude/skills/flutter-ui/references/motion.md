# Motion Reference — Animation · Transition · Micro-interaction

> Premium dark, target người đi làm: nhanh, có mục đích, không lặp vô tận.
> Flutter 3.44 — Impeller mặc định (animation mượt hơn).

---

## Ngân sách thời lượng & curve

| Loại | Duration | Curve |
|---|---|---|
| Micro-interaction (tap, toggle) | 100–150ms | `Curves.easeOut` |
| Element transition (flip, expand) | 250–350ms | `Curves.easeInOutCubic` |
| Page transition | 300–400ms | `Curves.easeInOutQuart` |
| Physics (swipe, spring-back) | theo vận tốc | `SpringSimulation` |

**Tránh:** `Curves.linear` (như bug), `Curves.elasticOut` mạnh (trẻ con), bất kỳ interaction thường nào > 500ms, nhiều animation chạy song song (chọn 1 focal point).

**A11y:** tôn trọng `MediaQuery.of(context).disableAnimations` — tắt/rút gọn animation khi user bật reduce-motion.

---

## 1. Micro-interactions — `flutter_animate`

Chain effect không cần controller. Hợp feedback nhanh.

```dart
// Tap feedback — scale nhẹ
final controller = AnimationController(vsync: this, duration: 100.ms);
GestureDetector(
  onTapDown: (_) => controller.forward(),
  onTapUp: (_) => controller.reverse(),
  onTapCancel: () => controller.reverse(),
  child: card.animate(controller: controller, autoPlay: false)
      .scaleXY(begin: 1, end: 0.97, curve: Curves.easeOut),
)

// Đánh dấu đúng — flash màu success rồi trượt ra
wordCard.animate()
    .tint(color: context.semantic.success, duration: 150.ms)
    .then(delay: 50.ms)
    .fadeOut(duration: 200.ms)
    .slideY(end: -0.3);

// Staggered list — item hiện lần lượt
ListView.builder(
  itemBuilder: (ctx, i) => VocabCard(...)
      .animate(delay: (i * 40).ms)
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.1, curve: Curves.easeOutCubic),
);
```

---

## 2. Flashcard Flip — tự implement (không dùng package flip_card)

Kiểm soát tốt hơn, hợp dark theme.

```dart
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  const FlipCard({required this.front, required this.back, super.key});
  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _anim = CurvedAnimation(
    parent: _ctrl, curve: Curves.easeInOutCubic,
  );
  bool _showFront = true;

  void flip() {
    _showFront ? _ctrl.forward() : _ctrl.reverse();
    setState(() => _showFront = !_showFront);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final showFront = _anim.value < 0.5;
          final angle = showFront
              ? _anim.value * math.pi
              : (_anim.value - 1) * math.pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)   // perspective
              ..rotateY(angle),
            child: showFront
                ? widget.front
                // mặt sau phải lật lại để chữ không bị mirror
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
```
> ⚠️ Mặt sau phải `rotateY(pi)` thêm lần nữa, nếu không text sẽ bị lật ngược.

---

## 3. Swipe Card (review session) — physics-based

```dart
// State: Offset _dragOffset; AnimationController _ctrl;

void _onPanUpdate(DragUpdateDetails d) {
  setState(() => _dragOffset += d.delta);
}

void _onPanEnd(DragEndDetails details) {
  final velocity = details.velocity.pixelsPerSecond.dx;
  final offset = _dragOffset.dx;
  const threshold = 120.0;
  const velocityThreshold = 800.0;

  if (offset.abs() > threshold || velocity.abs() > velocityThreshold) {
    final dir = (offset > 0 || velocity > 0) ? 1.0 : -1.0;
    _flyOut(dir);
    _onAnswer(correct: dir > 0);   // phải = đúng, trái = sai (tuỳ design)
  } else {
    _springBack();
  }
}

void _springBack() {
  const spring = SpringDescription(mass: 1, stiffness: 400, damping: 28);
  final sim = SpringSimulation(spring, _dragOffset.dx, 0, 0);
  _ctrl.animateWith(sim)..whenComplete(() => setState(() => _dragOffset = Offset.zero));
}
```
> Import `package:flutter/physics.dart` cho `SpringDescription` / `SpringSimulation`.

---

## 4. Page Transitions — `animations` package (Material Motion)

4 pattern Material Motion: **Container Transform**, **Shared Axis**, **Fade Through**, **Fade**.

```dart
// pubspec: animations: ^2.1.1

// Shared Axis — màn hình có quan hệ điều hướng (quiz → result)
PageTransitionSwitcher(
  transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
    animation: primary,
    secondaryAnimation: secondary,
    transitionType: SharedAxisTransitionType.horizontal,
    child: child,
  ),
  child: _currentScreen,
)

// Fade Through — màn hình không liên quan (home → settings, tab switch)
PageTransitionSwitcher(
  transitionBuilder: (child, primary, secondary) => FadeThroughTransition(
    animation: primary, secondaryAnimation: secondary, child: child,
  ),
  child: _currentTab,
)

// Container Transform — card → detail (có container chung), tự animate expand
OpenContainer(
  closedElevation: 0,
  closedColor: context.colors.surfaceContainer,
  openColor: context.colors.surface,
  closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  closedBuilder: (_, open) => VocabCard(onTap: open, ...),
  openBuilder: (_, __) => const VocabDetailScreen(),
)
```

> Áp cho toàn app qua `PageTransitionsTheme` + `SharedAxisPageTransitionsBuilder` nếu muốn mọi route đều dùng cùng motion.

---

## 5. Chọn đúng widget

| Nhu cầu | Widget |
|---|---|
| Property đổi từ từ | `AnimatedContainer` / `AnimatedOpacity` |
| Kiểm soát chi tiết | `AnimationController` + `TweenAnimationBuilder` |
| Chain nhiều effect | `flutter_animate` |
| Shared element giữa route | `Hero` |
| Card expand → detail | `OpenContainer` |
| Tab / page switch | `PageTransitionSwitcher` + `AnimatedSwitcher` |
| Skeleton loading | `shimmer` |
| Số đếm lên (XP, streak) | `TweenAnimationBuilder<int>` |
| Header co khi scroll | `SliverAppBar` + `CustomScrollView` |
| Drag + physics | `GestureDetector` + `SpringSimulation` |
| Confetti ăn mừng | `confetti` |

---

## 6. Performance & polish
- Bọc widget animation nặng trong `RepaintBoundary`.
- `const` constructor mọi nơi có thể.
- Truyền `child` vào `AnimatedBuilder` để cache subtree không đổi:
  ```dart
  AnimatedBuilder(
    animation: _anim,
    child: const ExpensiveStaticChild(),  // build 1 lần
    builder: (_, child) => Transform.scale(scale: _anim.value, child: child),
  )
  ```
- Test slow-motion trước khi ship: `timeDilation = 5.0;` (từ `package:flutter/scheduler.dart`).
- Haptic kèm animation quan trọng: `HapticFeedback.lightImpact()` (đúng), `.mediumImpact()` (hoàn thành session).

---

## Version package (verified 6/2026)
```yaml
flutter_animate: ^4.5.2   # verified — micro-interactions, chain effects
animations: ^2.1.1        # verified — Material motion: SharedAxis, FadeThrough, OpenContainer
google_fonts: ^8.1.0      # verified — Inter + Noto Sans SC/TC
shimmer: ^3.0.0           # check pub.dev — skeleton loading
confetti: ^0.8.0          # check pub.dev — celebration
```
> 💡 Ba dòng đầu verified pub.dev 6/2026. Hai dòng cuối là giá trị tham khảo — chạy `flutter pub outdated` để chốt. Flutter ecosystem đổi version nhanh.
