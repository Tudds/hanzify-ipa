# Hanzify

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge)](https://dart.dev)

**Hanzify** là ứng dụng học tiếng Trung web-first bằng Flutter. App hiện tại xoay quanh 5 tab chính: `Short`, `Từ điển`, `Quiz`, `Chat`, và `Ôn tập`, chạy offline-first với dữ liệu học local.

---

## Tính năng hiện tại

- **Shorts learning feed**: feed dọc với thẻ từ vựng, ngữ pháp, hội thoại, quiz nhanh, mini-test, và remediation sau câu sai.
- **Từ điển HSK**: tìm từ vựng và ngữ pháp theo Hanzi, pinyin, nghĩa, kèm bộ lọc HSK.
- **Chi tiết học liệu**: nghĩa tiếng Việt, pinyin, ví dụ, audio, công thức ngữ pháp, lỗi thường gặp, và stroke order khi có dữ liệu ký tự.
- **Quiz**: launcher cho các mode chọn từ, flashcard, điền từ, nối từ, và sắp xếp câu.
- **Chat GenUI local**: chat tương tác render block UI như bubble, vocab card, grammar card, quick quiz, sentence arrange, và suggestion actions. Hiện chưa gọi LLM thật.
- **Ôn tập FSRS**: thẻ đến hạn được chấm `Again`, `Hard`, `Good`, `Easy` và lưu lịch ôn local.
- **Offline-first**: local data và local study state là nguồn chính; Supabase chỉ dùng cho auth/sync khi được cấu hình.
- **Nội dung hiện có**: asset học liệu hiện chủ yếu bao phủ HSK1-HSK4.

---

## Công nghệ

- **Framework**: Flutter
- **State management**: Riverpod
- **Local persistence**: Drift, SQLite, SharedPreferences
- **Sync optional**: Supabase Flutter, chỉ khởi tạo khi có Dart defines
- **Audio/UI**: `just_audio`, `flutter_animate`, `flutter_svg`
- **Routing**: GoRouter

---

## Chạy dự án

### Cài dependencies

```bash
flutter pub get
```

### Chạy web app

```bash
flutter run -d chrome
```

### Chạy với Supabase

Supabase không tự bật nếu thiếu config. Truyền config bằng Dart defines:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Nếu không truyền hai giá trị này, app vẫn chạy ở chế độ local/offline-first và bỏ qua `Supabase.initialize`.

---

## Kiểm tra

```bash
flutter analyze
flutter test
```

Với thay đổi nhỏ, ưu tiên test tập trung theo feature trước khi chạy full suite.

---

## Ghi chú trạng thái

- App chính hiện có năm tab: `Short`, `Từ điển`, `Quiz`, `Chat`, `Ôn tập`.
- Legacy feature UI cũ như Home, Hub, Learning Path screen, Lesson Session, old Lookup, old Path tree, và Practice folder đã được gỡ khỏi `lib/features`.
- Không có runtime Claude/AI/LLM API đang được wire trong app chính ở trạng thái hiện tại; Chat dùng local responder và chừa interface để cắm remote responder sau.
