# Audio Setup — TTS pipeline

Hanzify dùng **pre-generated MP3** cho mọi nội dung phát âm để đảm bảo chất lượng đồng nhất giữa Web/iOS/Android.

## Kiến trúc

```
[edge-tts (MS Azure free)] ──generate──▶ audio_out/v1/*.mp3
                                              │
                                              ▼
[boto3 upload]  ──▶  Cloudflare R2 bucket ──▶  CDN public URL
                                              │
                                              ▼
                         Flutter app (just_audio + browser cache)
```

## URL convention

Base: `https://<r2-public-domain>/audio/v1/`

| Loại | Pattern | Ví dụ |
|---|---|---|
| Vocab pinyin | `vocab/{vocab_id}.mp3` | `vocab/hsk1_你好.mp3` |
| Vocab example | `vocab/{vocab_id}_E{idx}.mp3` | `vocab/hsk1_好_E1.mp3` |
| Grammar example | `grammar/{grammar_id}_E{idx}.mp3` | `grammar/g_svo_E0.mp3` |
| Conversation line | `conv/{conv_id}_L{idx}.mp3` | `conv/conv_greeting_01_L0.mp3` |

URL được tự dựng từ ID bởi `lib/core/audio/audio_urls.dart` — KHÔNG lưu URL trong JSON data.

## Generate audio

```bash
# Setup venv (1 lần)
uv venv tool/.venv --python 3.12
uv pip install --python tool/.venv/bin/python edge-tts boto3 tqdm

# Generate (~14-30 phút, có resume)
tool/.venv/bin/python tool/generate_audio.py --scope all --concurrency 5

# Hoặc chỉ 1 phần
tool/.venv/bin/python tool/generate_audio.py --scope vocab --levels 1
```

**Notes:**
- MS Azure rate-limit khi concurrency cao → giảm xuống 2-3 nếu thấy fail
- Script có **resume** — re-run sẽ skip file đã có

## Upload lên R2

### Setup credentials (1 lần)

1. Tạo bucket trên Cloudflare R2 dashboard: `hanzify-audio`
2. Settings → Public Access → bật **R2.dev subdomain** (hoặc custom domain)
3. Manage R2 API Tokens → tạo token quyền **Object Read & Write**
4. Tạo file `tool/.r2.env` (đã được .gitignore):

```env
R2_ACCOUNT_ID=your_account_id
R2_ACCESS_KEY=xxx
R2_SECRET_KEY=xxx
R2_BUCKET=hanzify-audio
R2_PUBLIC_BASE=https://pub-xxx.r2.dev
```

### Upload

```bash
tool/.venv/bin/python tool/upload_r2.py            # full sync
tool/.venv/bin/python tool/upload_r2.py --dry-run  # xem trước những gì sẽ upload
```

Script tự skip những file đã có trên R2 (so sánh size).

## Flutter integration

### Build với env config

```bash
flutter run --dart-define=AUDIO_BASE_URL=https://pub-xxx.r2.dev/audio/v1
flutter build web --wasm \
  --dart-define=AUDIO_BASE_URL=https://pub-xxx.r2.dev/audio/v1
```

### Code usage

```dart
import 'package:hanzify/core/audio/audio_urls.dart';
import 'package:hanzify/core/audio/audio_player_service.dart';

// Trong widget:
final player = ref.read(audioPlayerProvider);

// Phát phát âm 1 từ
player.play(AudioUrls.forVocab(vocab.id));

// Phát ví dụ câu
player.play(AudioUrls.forVocabExample(vocab.id, 0));

// Phát dòng hội thoại
player.play(AudioUrls.forConversationLine(conv.id, lineIndex));
```

## Re-generate khi thêm content mới

Khi thêm vocab/grammar/conversation mới:

```bash
# 1. Generate audio cho content mới (script tự skip cái đã có)
tool/.venv/bin/python tool/generate_audio.py --scope all

# 2. Upload lên R2 (cũng tự skip cái đã có)
tool/.venv/bin/python tool/upload_r2.py
```

Không cần update JSON — URL được dựng tự động từ ID.

## Versioning audio

Khi đổi voice/quality (vd: `XiaoxiaoNeural` → `XiaohanNeural`):

1. Update `VOICE` trong `tool/generate_audio.py`
2. Update path trong script: `audio_out/v1/` → `audio_out/v2/`
3. Update `_base` trong `audio_urls.dart`: `audio/v1` → `audio/v2`
4. Generate + upload lại
5. Bản cũ vẫn còn trên R2 cho rollback nếu cần
