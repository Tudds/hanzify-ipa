---
name: flutter-ui
description: >
  UI/UX design system guidance for Flutter apps with a Premium Dark aesthetic (kiểu Spotify,
  Obsidian, Linear) targeting professional/working-adult users. Use this skill whenever the user
  works on Flutter visual design, theming, design tokens, color schemes, typography, spacing,
  component styling, dark/light mode, Material 3 ColorScheme, surface elevation, micro-interactions,
  animations, page transitions, or asks to make a Flutter screen look polished/premium/consistent.
  Trigger for requests like "style this screen", "set up app theme", "make it look premium",
  "dark mode strategy", "design token", "animate this card", "page transition", or "thiết kế UI
  cho app Flutter". Load alongside the `flutter` skill (which covers architecture, state, widgets)
  — this skill owns the *look and feel* layer. Built for a Chinese-learning app for working adults.
---

# Flutter UI/UX Skill — Premium Dark

> 🗓️ Cập nhật 6/2026 — Flutter 3.44 / Dart 3.12 / Material 3
> 🎯 **Định hướng**: Premium dark theme (Spotify/Obsidian/Linear), target người đi làm — hiệu quả, ít distraction. Dark-first, light là secondary.
> 🤝 Dùng kèm skill `flutter` (kiến trúc, state, widget). Skill này lo phần **look & feel**.

## 📍 Khi nào đọc file nào

| Task | File |
|------|------|
| Color token, ColorScheme, surface elevation, dark/light strategy | `references/design_tokens.md` |
| Typography scale, font (Latin + CJK), spacing system | `references/design_tokens.md` |
| Component patterns (card, button, sheet, nav, progress, empty state) | `references/components.md` |
| Animation, micro-interaction, page transition, flip/swipe card | `references/motion.md` |

> 💡 **Đọc file phù hợp TRƯỚC khi style code.** Hầu hết task UI cần `design_tokens.md` làm nền.

---

## Triết lý thiết kế

**"Less but felt"** — người đi làm không muốn bị phân tâm. Mọi quyết định thị giác phải có lý do.

1. **Dark-first, không invert.** Thiết kế cho dark trước, light là bản phái sinh được tinh chỉnh — không phải đảo màu cơ học.
2. **Depth bằng surface, không bằng shadow.** Material 3 dark dùng nhiều tầng `surfaceContainer*` để tạo chiều sâu. Shadow gần như vô hình trên nền tối.
3. **Không pure black/white.** Nền `#0F0F14`, text `#E8E8F0`. Pure black gây OLED smearing khi scroll; pure white gây halation.
4. **Accent tiết chế.** 1 màu nhấn chủ đạo, desaturate ~15% so với light mode. Màu neon trên nền tối "cháy" hơn trên nền sáng.
5. **Content is king.** Chữ Hán / nội dung học là focal point — UI chrome lùi về sau.
6. **Animation nhanh & có mục đích.** Xem ngân sách thời lượng trong `motion.md`. Không loop vô tận ở màn hình chính.

---

## Quy tắc vàng (đọc trước khi code)

- ❌ **Không bao giờ hardcode màu** trong widget. Luôn `context.colorScheme.xxx` / `Theme.of(context)`. Lý do: dual theme + đổi seed một chỗ.
- ❌ **Không hardcode `Colors.white` / `Colors.black`** — dùng `onSurface`, `onPrimary`, v.v.
- ✅ **Spacing theo thang 4pt** (4/8/12/16/24/32). Không có số lẻ (13, 17, 21).
- ✅ **Chữ Hán dùng font CJK riêng** (`Noto Sans SC/TC`), apply cục bộ cho widget character — không global.
- ✅ **Mọi màu light phải có cặp dark.** Test bằng cách toggle theme liên tục.
- ✅ **Icon/illustration cần adapt theme** (2 phiên bản hoặc `ColorFiltered`).
- ❌ **Tránh** `Curves.linear` (như bug), `Curves.elasticOut` mạnh (trẻ con, không premium), animation > 500ms cho interaction thường, nhiều animation song song.

---

## Material 3 ColorScheme — nền tảng

Material 3 sinh **toàn bộ** palette từ 1 seed color. Đừng tự đặt từng màu lẻ.

```dart
const kSeed = Color(0xFF6B4EFF);  // indigo-violet (xem design_tokens.md cho lựa chọn khác)

ColorScheme.fromSeed(
  seedColor: kSeed,
  brightness: Brightness.dark,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity, // giữ đúng tông seed
)
```

4 tầng surface quan trọng nhất (dark):
| Token | Dùng cho | Giá trị tham khảo |
|---|---|---|
| `surface` | nền màn hình | ~#0F0F14 |
| `surfaceContainer` | card, panel | ~#1C1C24 |
| `surfaceContainerHigh` | modal, bottom sheet | ~#252530 |
| `surfaceContainerHighest` | overlay, menu nổi | ~#2E2E3A |

Chi tiết đầy đủ (typography, spacing, full token list, light counterpart) → `references/design_tokens.md`.

---

## Checklist UI trước khi ship

- [ ] Không có màu/spacing hardcode — tất cả qua token
- [ ] Toggle dark ↔ light: không chỗ nào "vỡ" (text vô hình, contrast kém)
- [ ] Contrast text/nền đạt WCAG AA (4.5:1 body, 3:1 large)
- [ ] Chữ Hán render đúng font CJK, không bị tofu (□)
- [ ] Animation < 400ms cho interaction thường; có thể tắt theo `MediaQuery.disableAnimations`
- [ ] Haptic feedback cho action quan trọng (`HapticFeedback.lightImpact()`)
- [ ] `RepaintBoundary` quanh animation nặng
- [ ] Empty / loading / error state đều được style (không chỉ happy path)
- [ ] Test với `TextScaler` lớn (accessibility) — layout không tràn

---

## Nguồn tham khảo
- Material 3 design: https://m3.material.io/
- Material 3 color system: https://m3.material.io/styles/color/system/overview
- Flutter theming: https://docs.flutter.dev/cookbook/design/themes
- Material motion: https://m3.material.io/styles/motion/overview
- animations package: https://pub.dev/packages/animations
- flutter_animate: https://pub.dev/packages/flutter_animate
