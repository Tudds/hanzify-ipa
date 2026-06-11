# Design Tokens Reference — Premium Dark

> Color · Typography · Spacing · Dark/Light strategy
> Material 3 / Flutter 3.44

---

## 1. Color System

### Nguyên tắc
Material 3 sinh toàn bộ palette từ **1 seed color** qua thuật toán HCT. Không tự đặt màu lẻ — đặt seed rồi để Flutter generate, override chỉ khi thật cần.

### Seed color gợi ý (cho app học nghiêm túc / người đi làm)
```dart
// Indigo-violet — tập trung, tri thức (mặc định khuyến nghị)
const kSeed = Color(0xFF6B4EFF);

// Teal — khác biệt với Notion/Obsidian, tươi nhưng vẫn premium
// const kSeed = Color(0xFF00BFA5);

// Amber-gold — ấm, gợi truyền thống Á Đông (hợp tiếng Trung)
// const kSeed = Color(0xFFE0A52E);
```

### Tạo ColorScheme
```dart
ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kSeed,
  brightness: Brightness.dark,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
);
ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: kSeed,
  brightness: Brightness.light,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
);
```

**Các variant của `DynamicSchemeVariant`:**
| Variant | Cảm giác |
|---|---|
| `tonalSpot` (default) | Trung tính, cân bằng |
| `fidelity` | Giữ đúng tông seed nhất — khuyến nghị cho brand color |
| `vibrant` | Accent nổi, nhiều màu |
| `expressive` | Đa sắc, playful (KHÔNG hợp premium) |
| `neutral` | Gần như greyscale, accent rất nhẹ |
| `monochrome` | Đen trắng hoàn toàn |

### 4 tầng surface (dark) — tạo depth không cần shadow
| Token | Dùng cho | Tham khảo |
|---|---|---|
| `surface` | nền màn hình gốc | #0F0F14 |
| `surfaceContainerLowest` | vùng lõm hơn nền | #0A0A0E |
| `surfaceContainerLow` | nền phụ | #16161C |
| `surfaceContainer` | **card, panel** | #1C1C24 |
| `surfaceContainerHigh` | **modal, bottom sheet** | #252530 |
| `surfaceContainerHighest` | overlay, menu, dropdown | #2E2E3A |

> Quy tắc: element càng "nổi" lên gần user → tầng surface càng sáng. Đây là cách M3 thay thế shadow trên dark.

### Màu text
```dart
// KHÔNG dùng Colors.white / Colors.black
context.colorScheme.onSurface          // text chính (~#E8E8F0 dark)
context.colorScheme.onSurfaceVariant   // text phụ, caption (~#A8A8B8)
context.colorScheme.primary            // text/icon nhấn
context.colorScheme.outline            // border, divider (~#48485A)
```

### Semantic color (đúng/sai/cảnh báo cho app học)
M3 không có sẵn success/warning — định nghĩa thêm qua `ThemeExtension`:
```dart
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;   // đúng
  final Color warning;   // sắp tới hạn review
  final Color danger;    // sai

  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const dark = AppSemanticColors(
    success: Color(0xFF4ADE80),  // green, desaturate cho dark
    warning: Color(0xFFFBBF24),
    danger:  Color(0xFFF87171),
  );
  static const light = AppSemanticColors(
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger:  Color(0xFFDC2626),
  );

  @override
  AppSemanticColors copyWith({Color? success, Color? warning, Color? danger}) =>
      AppSemanticColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
      );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger:  Color.lerp(danger, other.danger, t)!,
    );
  }
}

// Đăng ký:
ThemeData(extensions: const [AppSemanticColors.dark]);
// Dùng:
final ok = Theme.of(context).extension<AppSemanticColors>()!.success;
```

> ⚠️ Không bao giờ truyền thông tin CHỈ bằng màu — luôn kèm icon/label (a11y, mù màu).

---

## 2. Typography

### Font
- **UI (Latin)**: **Inter** — variable font, render sắc nét trên dark, có sẵn trên `google_fonts`.
- **Chữ Hán**: **Noto Sans SC** (giản thể) / **Noto Sans TC** (phồn thể). Apply **cục bộ**, không global.
- Fallback chain quan trọng để không bị tofu (□):

```dart
TextStyle hanStyle(BuildContext context, {double size = 48}) =>
    GoogleFonts.notoSansSc(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

// Global text theme dùng Inter — KHÔNG áp cho character
TextTheme buildTextTheme(ColorScheme cs) {
  final base = GoogleFonts.interTextTheme();
  return base.apply(
    bodyColor: cs.onSurface,
    displayColor: cs.onSurface,
  );
}
```

### Type scale (ít size, tương phản rõ)
| Role | Size | Weight | Height | Dùng cho |
|---|---|---|---|---|
| displayLarge | 48 | w700 | 1.2 | Chữ Hán hiển thị lớn |
| headlineMedium | 24 | w600 | 1.3 | Tiêu đề màn hình |
| titleMedium | 16 | w500 | 1.4 | Label card, pinyin |
| bodyMedium | 14 | w400 | 1.6 | Body, nghĩa từ |
| labelSmall | 12 | w400 | 1.5 | Caption, metadata |

> Nguyên tắc: ≤ 5 cấp size. Tạo tương phản bằng **weight + size**, không bằng màu.

---

## 3. Spacing — thang 4pt

```dart
abstract class Gap {
  static const double xs = 4;    // icon ↔ label
  static const double sm = 8;    // padding trong nhỏ
  static const double md = 12;   // gap giữa elements
  static const double lg = 16;   // padding chuẩn / margin màn hình
  static const double xl = 24;   // gap giữa section
  static const double xxl = 32;  // block lớn
}
```
- Margin mép màn hình: `16`.
- Padding trong card: `16` (hoặc `12` nếu dày đặc).
- Gap giữa các card trong list: `12`.
- Corner radius: card `16`, sheet/modal `24`, button `12`, chip `8`.
- Dùng package `gap` (`Gap(16)`) thay `SizedBox(height: 16)` cho gọn.

---

## 4. Dark / Light Strategy

```dart
ThemeData _build(Brightness b) {
  final cs = ColorScheme.fromSeed(
    seedColor: kSeed,
    brightness: b,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: buildTextTheme(cs),
    scaffoldBackgroundColor: cs.surface,
    cardTheme: const CardThemeData(elevation: 0),  // 3.44: CardThemeData, không phải CardTheme
    extensions: [
      b == Brightness.dark ? AppSemanticColors.dark : AppSemanticColors.light,
    ],
  );
}

MaterialApp(
  themeMode: ThemeMode.system,   // tôn trọng OS — không ép dark
  theme: _build(Brightness.light),
  darkTheme: _build(Brightness.dark),
);
```

**Quy tắc dual theme:**
- Thiết kế dark trước, sau đó kiểm tra light — không invert cơ học.
- Mọi màu light có cặp dark; toggle liên tục để bắt lỗi.
- Accent trong dark nên desaturate ~15% so với light.
- Cho phép user override system (3 lựa chọn: System / Light / Dark) — lưu bằng `shared_preferences`.

---

## 5. BuildContext extension (tiện dùng token)
```dart
extension UITokens on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
// Dùng: context.colors.surfaceContainer, context.semantic.success
```
