# Shorts — nội dung "rich" (hội thoại sub-sync / scene / truyện-thơ)

Nội dung rich cho tab Shorts được **biên soạn** rồi host trên CDN (Cloudflare R2 — cùng
bucket với audio TTS, đã chạy được dưới COEP của web app). App tải **live** một file
`manifest.json` rồi parse thành `ShortFeedItem`.

- Schema mẫu: [`sample_manifest.json`](sample_manifest.json).
- Parser app: `lib/features/shorts/data/remote_shorts_repository.dart`.
- Models: `lib/features/shorts/domain/short_feed_item.dart`
  (`ShortDialogue` + timing, `ShortScene`, `ShortReader`).

## Quy trình đưa nội dung lên

1. Soạn nội dung song ngữ Trung–Việt (LLM hỗ trợ → review tay). Với card có audio đồng bộ,
   gắn `startMs`/`endMs` cho từng dòng (mốc thời gian trong track audio liền mạch).
2. Chuẩn bị thư mục nguồn `tool/shorts_content/upload/` MIRROR đúng đường dẫn trong manifest:

   ```
   upload/
     manifest.json            # copy & chỉnh từ sample_manifest.json
     audio/dialogue_cafe.mp3  # → shorts/audio/dialogue_cafe.mp3
     images/scene_market.webp # → shorts/images/scene_market.webp
   ```

   URL trong `manifest.json` phải trỏ tới `<R2_PUBLIC_BASE>/shorts/audio/...`,
   `<R2_PUBLIC_BASE>/shorts/images/...`.
3. Tạo `tool/.r2.env` (credentials R2, xem docstring `tool/upload_r2.py`) rồi upload:

   ```bash
   tool/.venv/bin/python tool/upload_shorts_r2.py --src tool/shorts_content/upload --dry-run  # xem trước
   tool/.venv/bin/python tool/upload_shorts_r2.py --src tool/shorts_content/upload            # upload thật
   ```

   Script đặt `ContentType` đúng theo đuôi file; media cache 1 năm (bỏ qua nếu đã có cùng size);
   `manifest.json` luôn upload đè với `must-revalidate` để bản mới hiển thị ngay.
4. App tự kéo `shorts/manifest.json` ở lần hydrate đầy đủ (`includeRemote: true`). Offline →
   feed dùng vocab HSK. Đổi nguồn khi build: `--dart-define=SHORTS_CONTENT_URL=<...>/shorts/manifest.json`.

## Cấu hình URL

Mặc định: `https://<r2>/shorts/manifest.json`. Override khi build:

```bash
flutter build web --wasm --dart-define=SHORTS_CONTENT_URL=https://.../shorts/manifest.json
```

Để rỗng (`--dart-define=SHORTS_CONTENT_URL=`) sẽ tắt nguồn remote.

## Loại card

| `type` | payload | ghi chú |
|---|---|---|
| `dialogue` | `title`, `context`, `audioUrl?`, `lines[]{speaker,hanzi,pinyin,vi,startMs?,endMs?}` | có `audioUrl` + `startMs/endMs` → phụ đề chạy theo audio |
| `scene` | `imageUrl`, `caption{hanzi,pinyin,vi}`, `labels[]{hanzi,pinyin,vi,targetVocabId?}`, `audioUrl?` | nhãn có `targetVocabId` → tap mở chi tiết từ |
| `reader` | `kind`(`story\|article\|poem`), `titleZh`, `title`, `paragraphs[]{zh,pinyin,vi,startMs?,endMs?}`, `glossary[]`, `audioUrl?`, `sourceName?`, `sourceUrl?` | timing tùy chọn → sub sync khi đọc |

> Bản quyền: chỉ host nội dung được phép. Podcast/tin tức bên thứ ba (cần Worker proxy) là phase sau.
