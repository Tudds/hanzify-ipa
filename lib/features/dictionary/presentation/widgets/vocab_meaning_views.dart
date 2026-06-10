import 'package:flutter/material.dart';

import '../../../../core/audio/audio_play_button.dart';
import '../../../../core/utils/pos_label.dart';
import '../../domain/vocab_item.dart';

/// Meanings of a single part of speech, kept in original order.
class PosMeaningGroup {
  const PosMeaningGroup({required this.pos, required this.items});

  final String pos;
  final List<VocabMeaning> items;
}

/// Groups a flat meaning list by part of speech, preserving first-seen order.
/// Empty `pos` is bucketed under `other`. Shared by the dictionary detail sheet
/// and the flashcard drill so both render meanings identically.
List<PosMeaningGroup> groupMeaningsByPos(List<VocabMeaning> meanings) {
  final order = <String>[];
  final buckets = <String, List<VocabMeaning>>{};
  for (final m in meanings) {
    final key = m.pos.isEmpty ? 'other' : m.pos;
    if (!buckets.containsKey(key)) {
      order.add(key);
      buckets[key] = <VocabMeaning>[];
    }
    buckets[key]!.add(m);
  }
  return [for (final k in order) PosMeaningGroup(pos: k, items: buckets[k]!)];
}

/// A tinted card showing one part of speech label (e.g. "Động từ") and its
/// meanings as a bulleted list.
class MeaningPosGroupView extends StatelessWidget {
  const MeaningPosGroupView({super.key, required this.pos, required this.items});

  final String pos;
  final List<VocabMeaning> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = PosLabel.color(pos, colors);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              PosLabel.vietnamese(pos),
              style: TextStyle(
                color: tint,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[i].vi.isNotEmpty ? items[i].vi : items[i].en,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One example sentence (Hanzi + pinyin + Vietnamese) with an audio button.
class VocabExampleTile extends StatelessWidget {
  const VocabExampleTile({
    super.key,
    required this.example,
    required this.audioUrl,
  });

  final VocabExample example;
  final String audioUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  example.cn,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                if (example.pinyin.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    example.pinyin,
                    style: TextStyle(color: colors.primary, fontSize: 13),
                  ),
                ],
                if (example.vi.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    example.vi,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AudioPlayButton(url: audioUrl, size: 22),
        ],
      ),
    );
  }
}
