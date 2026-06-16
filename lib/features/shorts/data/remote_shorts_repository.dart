import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/short_feed_item.dart';

/// Nạp nội dung "rich" cho Shorts (hội thoại sub-sync, scene, truyện/thơ) từ một
/// manifest JSON host trên CDN (mặc định Cloudflare R2 — cùng bucket với audio,
/// đã chạy được dưới COEP).
///
/// Online-only theo thiết kế: lỗi mạng/timeout → trả `[]`, feed Shorts vẫn build
/// từ nội dung HSK offline (xem [ShortsFeedRepository]).
///
/// Manifest chấp nhận 2 dạng:
///   - `[ {ShortFeedItem...}, ... ]`
///   - `{ "items": [ {ShortFeedItem...}, ... ] }`
class RemoteShortsRepository {
  RemoteShortsRepository({http.Client? client, String? manifestUrl})
    : _client = client ?? http.Client(),
      _manifestUrl = manifestUrl ?? defaultManifestUrl;

  /// Override qua `--dart-define=SHORTS_CONTENT_URL=...`. Rỗng → tắt nguồn remote.
  static const String defaultManifestUrl = String.fromEnvironment(
    'SHORTS_CONTENT_URL',
    defaultValue:
        'https://pub-7d5fb452d3c14b469b1d630f885dfa87.r2.dev/shorts/manifest.json',
  );

  final http.Client _client;
  final String _manifestUrl;

  Future<List<ShortFeedItem>> fetchRemote({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (_manifestUrl.isEmpty) return const [];
    try {
      final response = await _client
          .get(Uri.parse(_manifestUrl))
          .timeout(timeout);
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final rawItems = switch (decoded) {
        List<dynamic> list => list,
        Map<String, dynamic> map => (map['items'] as List? ?? const []),
        _ => const [],
      };
      return rawItems
          .whereType<Map>()
          .map((entry) => _tryParse(entry.cast<String, dynamic>()))
          .whereType<ShortFeedItem>()
          .toList(growable: false);
    } catch (_) {
      // Offline / lỗi parse / nguồn chết → bỏ qua, không phá feed.
      return const [];
    }
  }

  ShortFeedItem? _tryParse(Map<String, dynamic> json) {
    try {
      return ShortFeedItem.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
