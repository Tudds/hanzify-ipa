# Component Patterns Reference — Premium Dark

> Card · Button · Sheet · Nav · Progress · States
> Tất cả dùng token từ `design_tokens.md` — không hardcode màu.

---

## Nguyên tắc chung
- Element nổi lên (card → sheet → menu) tăng dần tầng `surfaceContainer*`.
- Border thay vì shadow trên dark: `outline` mảnh (0.5–1px) ở opacity thấp.
- Corner radius nhất quán: card 16, sheet 24, button 12, chip 8.
- Tap target tối thiểu 48×48.

---

## 1. Card (vocabulary / list item)
```dart
class VocabCard extends StatelessWidget {
  final String character;
  final String pinyin;
  final String meaning;
  final VoidCallback onTap;
  const VocabCard({
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Chữ Hán — font CJK riêng, kích thước lớn
              Text(character, style: GoogleFonts.notoSansSc(
                fontSize: 32, fontWeight: FontWeight.w600, color: cs.onSurface,
              )),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pinyin, style: context.text.titleMedium
                        ?.copyWith(color: cs.primary)),
                    const Gap(4),
                    Text(meaning, style: context.text.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
> Dùng `Material + InkWell` (không `Container + GestureDetector`) để có ripple + clip đúng.

---

## 2. Buttons
```dart
// Primary action — filled, accent
FilledButton(
  onPressed: onPressed,
  style: FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: const Text('Bắt đầu học'),
)

// Secondary — tonal (nền surfaceContainerHighest)
FilledButton.tonal(onPressed: onPressed, child: const Text('Để sau'))

// Tertiary — text only
TextButton(onPressed: onPressed, child: const Text('Bỏ qua'))
```
> Premium dark: tránh `OutlinedButton` viền dày. Ưu tiên filled/tonal cho phân cấp rõ.

---

## 3. Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: context.colors.surfaceContainerHigh,
  showDragHandle: true,             // M3 drag handle
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  isScrollControlled: true,         // cho sheet cao / có TextField
  builder: (ctx) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(ctx).viewInsets.bottom,  // tránh bàn phím che
    ),
    child: const VocabDetailSheet(),
  ),
);
```

---

## 4. Bottom Navigation (M3)
```dart
NavigationBar(
  selectedIndex: index,
  onDestinationSelected: onSelect,
  backgroundColor: context.colors.surfaceContainer,
  // Premium: ẩn label nếu icon đủ rõ
  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
  destinations: const [
    NavigationDestination(icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school), label: 'Học'),
    NavigationDestination(icon: Icon(Icons.style_outlined),
        selectedIcon: Icon(Icons.style), label: 'Thẻ'),
    NavigationDestination(icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart), label: 'Tiến độ'),
  ],
)
```

---

## 5. Progress Bar (mảnh, accent)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(99),
  child: LinearProgressIndicator(
    value: progress,                 // 0.0 → 1.0
    minHeight: 6,
    backgroundColor: context.colors.surfaceContainerHighest,
    valueColor: AlwaysStoppedAnimation(context.colors.primary),
  ),
)
```

---

## 6. Stat / Streak (floating, không card)
```dart
Column(
  children: [
    Text('$streak', style: context.text.displayLarge
        ?.copyWith(color: context.colors.primary)),
    Text('ngày streak', style: context.text.labelSmall
        ?.copyWith(color: context.colors.onSurfaceVariant)),
  ],
)
```
> Số to + label nhỏ, đặt thẳng trên nền — không bọc card. Tạo cảm giác thoáng, premium.

---

## 7. States (đừng quên!)

```dart
// Loading — dùng shimmer skeleton thay spinner cho premium feel
// package: shimmer
Shimmer.fromColors(
  baseColor: context.colors.surfaceContainer,
  highlightColor: context.colors.surfaceContainerHighest,
  child: const _SkeletonCardList(),
)

// Empty
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.inbox_outlined, size: 48,
          color: context.colors.onSurfaceVariant),
      const Gap(12),
      Text('Chưa có thẻ nào', style: context.text.titleMedium),
      const Gap(4),
      Text('Thêm từ vựng để bắt đầu',
          style: context.text.bodyMedium
              ?.copyWith(color: context.colors.onSurfaceVariant)),
    ],
  ),
)

// Error + retry
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.error_outline, size: 48, color: context.semantic.danger),
      const Gap(12),
      Text('Có lỗi xảy ra', style: context.text.titleMedium),
      const Gap(16),
      FilledButton.tonal(onPressed: onRetry, child: const Text('Thử lại')),
    ],
  ),
)
```

> Mọi màn hình fetch data phải style đủ 4 trạng thái: loading / data / empty / error. `AsyncValue.when()` của Riverpod map thẳng vào đây.
