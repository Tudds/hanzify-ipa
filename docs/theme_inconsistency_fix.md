# Theme Inconsistency Fix — Dark/Light/Sepia

## Vấn đề

Một số screen dùng màu hardcoded (`Colors.grey`, `Colors.white`) thay vì dùng theme token từ `AppThemeColors`, khiến giao diện không đồng nhất giữa các chế độ sáng/tối/sepia.

---

## Danh sách lỗi cần sửa

### 1. `lib/features/conversation/presentation/screens/conversation_detail_screen.dart`

#### Lỗi 1 — Icon "Hội thoại" section header (khoảng dòng 262)

```dart
// ❌ TRƯỚC — không thay đổi theo theme
const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.grey),

// ✅ SAU — dùng theme token
Icon(Icons.chat_bubble_outline_rounded, size: 18, color: c.onSurfaceVariant),
```

> Lưu ý: xóa `const` vì giờ dùng biến `c`.

---

#### Lỗi 2 — `_ModeTab` widget: text màu của tab chưa chọn (khoảng dòng 1111)

```dart
// ❌ TRƯỚC
color: selected ? Colors.white : Colors.grey,

// ✅ SAU
color: selected ? Colors.white : c.onSurfaceVariant,
```

> Trong `_ModeTab.build()`, cần nhận thêm `AppThemeColors c` hoặc đọc từ `BuildContext`.  
> Hiện tại `_ModeTab` nhận `Color color` (primary color) nhưng không nhận `AppThemeColors`.

**Cách sửa đúng cho `_ModeTab`:**

```dart
class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;          // primary color khi selected
  final Color unselectedColor; // ← thêm param này
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.color,
    required this.unselectedColor, // ← thêm
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.label(
              fontSize: AppFontSizes.labelMd,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : unselectedColor, // ← dùng param
            ),
          ),
        ),
      ),
    );
  }
}
```

**Cập nhật chỗ gọi `_ModeTab` trong `_buildModeToggle()`:**

```dart
_ModeTab(
  label: 'Đọc hội thoại',
  selected: !_isPracticeMode,
  color: c.primary,
  unselectedColor: c.onSurfaceVariant, // ← thêm
  onTap: () => setState(() { ... }),
),
_ModeTab(
  label: 'Luyện tập',
  selected: _isPracticeMode,
  color: c.primary,
  unselectedColor: c.onSurfaceVariant, // ← thêm
  onTap: () => setState(() { ... }),
),
```

---

## Các screen khác — KHÔNG có lỗi

| Screen | Kết luận |
|---|---|
| `grammar_screen.dart` | Dùng đúng theme tokens ✓ |
| `grammar_detail_screen.dart` | Dùng đúng theme tokens ✓ |
| `vocab_detail_screen.dart` | Dùng đúng theme tokens ✓ |
| `conversation_screen.dart` | Dùng đúng theme tokens ✓ |

---

## Lưu ý về `Colors.white` trong gradient cards

Các chỗ dùng `Colors.white` trong hero card (background là `c.primaryGradient`) là **cố ý đúng** — không phải lỗi.  
Lý do: `c.onPrimary` trong dark mode là `Color(0xFF0D1B2E)` (navy rất tối), không đọc được trên nền gradient sáng.
