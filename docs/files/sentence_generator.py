"""
Combinatorial Sentence Generator.
Input: target_word, user_hsk_level, count
Output: List[GeneratedSentence] với metadata đầy đủ
"""
import json
import random
from collections import Counter

class SentenceGenerator:
    def __init__(self, collocations_path='collocations_db.json',
                 frames_path='frames_bank.json',
                 vocab_paths=None):
        with open(collocations_path) as f:
            self.colloc = json.load(f)
        with open(frames_path) as f:
            self.frames_data = json.load(f)
        self.frames = self.frames_data['frames']

        # Build vocab pools cho slot fill secondary (N, ADJ khi cần)
        self.all_vocab = {}
        if vocab_paths:
            for p in vocab_paths:
                with open(p) as f:
                    for w in json.load(f):
                        h = w['hanzi']
                        if h not in self.all_vocab:
                            self.all_vocab[h] = w

        # Indices
        self.vo_db = self.colloc['verb_object']
        self.an_db = self.colloc['adj_noun']

        # Noisy mined collocations to filter (auto-detected wrong matches)
        # Format: (head_verb_or_adj, partner_to_skip)
        self.noisy_blacklist = {
            ('考虑', '能不能'), ('解决', '就业'),
            ('反映', '社会'),  # too generic to be informative
            ('丰富', '日'), ('丰富', '分钟'), ('丰富', '日子'),
            ('看', '医生'),  # collocation đúng nhưng frame past_了 + medical = awkward
        }

        def filter_collocations(db):
            for head, entry in db.items():
                entry['collocations'] = [
                    c for c in entry['collocations']
                    if (head, c['object_hanzi']) not in self.noisy_blacklist
                    # Skip if partner length > 4 chars (likely garbage)
                    and len(c['object_hanzi']) <= 4
                    # Skip if partner is single very-common particle
                    and c['object_hanzi'] not in {'人', '事', '东西'}
                ]
            return db

        self.vo_db = filter_collocations(self.vo_db)
        self.an_db = filter_collocations(self.an_db)

        # Build common noun pool (HSK1-2) cho khi frame cần N độc lập
        self.common_nouns = [
            (h, v) for h, v in self.all_vocab.items()
            if v.get('wordType') == 'n' and v.get('level', 4) <= 2
        ][:50]
        # Common adj
        self.common_adjs = [
            (h, v) for h, v in self.all_vocab.items()
            if v.get('wordType') == 'adj' and v.get('level', 4) <= 2
        ][:30]

    def _get_vi(self, hanzi):
        """Get first clean Vietnamese gloss."""
        v = self.all_vocab.get(hanzi, {})
        if v.get('meanings'):
            raw = v['meanings'][0].get('vi', hanzi)
            # Take first segment before comma/slash
            for sep in [',', '/', '；', ';']:
                if sep in raw:
                    raw = raw.split(sep)[0]
            return raw.strip()
        return hanzi

    def _build_vo_chunk(self, verb_hanzi, obj_data):
        """Tạo chunk VO + Vietnamese gloss."""
        zh = verb_hanzi + obj_data['object_hanzi']
        verb_vi = self._get_vi(verb_hanzi)
        obj_vi = self._get_vi(obj_data['object_hanzi'])  # use clean getter
        vi = f"{verb_vi} {obj_vi}".strip()
        return zh, vi

    def _build_an_chunk(self, adj_hanzi, noun_data):
        """Adj+Noun không cần ghép trực tiếp; chunk = adj alone, noun riêng."""
        return adj_hanzi, self._get_vi(adj_hanzi), noun_data['object_hanzi'], noun_data['object_vi']

    def _frame_compatible(self, frame, target_pos, user_level):
        """Check frame có dùng được với target không."""
        if frame['hsk_level_min'] > user_level:
            return False
        # Frame yêu cầu VO slot → target phải là verb
        if 'VO' in frame['slot_types'] and target_pos == 'v':
            return True
        if 'V' in frame['slot_types'] and 'VO' not in frame['slot_types'] and target_pos == 'v':
            return True
        if 'ADJ' in frame['slot_types'] and target_pos == 'adj':
            return True
        if 'N' in frame['slot_types'] and target_pos == 'n' and 'VO' not in frame['slot_types']:
            return True
        return False

    def generate(self, target_word, user_hsk_level=4, count=10,
                 enforce_diversity=True, seed=None):
        """
        Generate diverse sentences containing target_word.
        Returns: list of dicts with zh/vi/metadata.
        """
        if seed is not None:
            random.seed(seed)

        if target_word not in self.all_vocab:
            return {'error': f'Word {target_word} not found in vocab'}

        target_pos = self.all_vocab[target_word].get('wordType', '')

        # Get collocations cho target
        collocations = []
        if target_pos == 'v' and target_word in self.vo_db:
            collocations = self.vo_db[target_word]['collocations']
        elif target_pos == 'adj' and target_word in self.an_db:
            collocations = self.an_db[target_word]['collocations']

        if not collocations and target_pos in ('v', 'adj'):
            return {'error': f'No collocations for {target_word}',
                    'suggestion': 'Add to curated DB'}

        # Filter compatible frames
        compatible_frames = [f for f in self.frames
                             if self._frame_compatible(f, target_pos, user_hsk_level)]

        if not compatible_frames:
            return {'error': f'No compatible frames for {target_pos} at HSK{user_hsk_level}'}

        # Generate
        output = []
        used_combinations = set()
        attempts = 0
        max_attempts = count * 8

        while len(output) < count and attempts < max_attempts:
            attempts += 1
            frame = random.choice(compatible_frames)

            # === Pick collocation ===
            obj = random.choice(collocations)

            # === Diversity check ===
            combo_key = (frame['id'], obj['scenario'], frame['time'], frame['mood'])
            if enforce_diversity and combo_key in used_combinations:
                continue
            used_combinations.add(combo_key)

            # === Build sentence ===
            zh = frame['zh']
            vi = frame['vi']
            metadata_extra = {}

            if target_pos == 'v':
                # Frame needs VO chunk
                if 'VO' in frame['slot_types']:
                    chunk_zh, chunk_vi = self._build_vo_chunk(target_word, obj)
                    zh = zh.replace('{VO}', chunk_zh)
                    vi = vi.replace('{VVO}', chunk_vi)
                # Frame needs V slot only (e.g., F-H4-03)
                elif 'V' in frame['slot_types']:
                    zh = zh.replace('{V}', target_word)
                    vi = vi.replace('{VV}', self._get_vi(target_word))
                    # Also fill {N} with object
                    if '{N}' in zh:
                        n_h = obj['object_hanzi']
                        zh = zh.replace('{N}', n_h)
                        vi = vi.replace('{VN}', self._get_vi(n_h))

            elif target_pos == 'adj':
                # ADJ frames: target = adj, paired with noun from collocations
                if 'N' in frame['slot_types'] and 'ADJ' in frame['slot_types']:
                    n_h = obj['object_hanzi']
                    zh = zh.replace('{N}', n_h, 1).replace('{ADJ}', target_word)
                    vi = vi.replace('{VN}', self._get_vi(n_h), 1).replace('{VADJ}', self._get_vi(target_word))
                    # If frame has N2 (comparison), fill with another random noun
                    if '{N2}' in zh:
                        n2_pool = [n for n, _ in self.common_nouns if n != n_h]
                        n2 = random.choice(n2_pool)
                        zh = zh.replace('{N2}', n2)
                        vi = vi.replace('{VN2}', self._get_vi(n2))
                elif 'ADJ' in frame['slot_types']:
                    zh = zh.replace('{ADJ}', target_word)
                    vi = vi.replace('{VADJ}', self._get_vi(target_word))

            # Validate: no leftover slots
            if '{' in zh or '{' in vi:
                continue  # something went wrong, skip

            output.append({
                'zh': zh,
                'vi': vi,
                'frame_id': frame['id'],
                'frame_grammar': frame['grammar_focus'],
                'time': frame['time'],
                'mood': frame['mood'],
                'scenario': obj['scenario'],
                'collocation': {
                    'head': target_word,
                    'partner': obj['object_hanzi'],
                    'partner_vi': obj['object_vi'],
                    'frequency': obj['frequency'],
                    'sources': obj['sources'],
                },
                'complexity': frame['complexity'],
                'hsk_level': frame['hsk_level_min'],
            })

        return output

    def diversity_report(self, sentences):
        """Compute diversity metrics."""
        if not sentences or isinstance(sentences, dict):
            return {}
        return {
            'count': len(sentences),
            'unique_frames': len(set(s['frame_id'] for s in sentences)),
            'unique_scenarios': len(set(s['scenario'] for s in sentences)),
            'unique_times': len(set(s['time'] for s in sentences)),
            'unique_moods': len(set(s['mood'] for s in sentences)),
            'unique_collocation_partners': len(set(s['collocation']['partner'] for s in sentences)),
            'avg_complexity': sum(s['complexity'] for s in sentences) / len(sentences),
        }


# ============ DEMO ============
if __name__ == '__main__':
    gen = SentenceGenerator(
        vocab_paths=[f'hsk{i}.json' for i in [1, 2, 3, 4]]
    )

    test_words = [
        ('考虑', 4, '4'),       # HSK4 verb
        ('解决', 4, '4'),       # HSK3 verb but useful
        ('戴', 4, '4'),         # HSK4 verb
        ('参加', 4, '4'),       # common verb
        ('看', 2, '2'),         # HSK1 verb at HSK2 user
        ('严肃', 4, '4'),       # HSK4 adj
        ('丰富', 4, '4'),       # HSK4 adj
        ('反映', 4, '4'),       # HSK4 verb
    ]

    for target, user_lvl, lvl_label in test_words:
        print(f"\n{'='*72}")
        print(f"  TARGET: {target} | User HSK{lvl_label}")
        print('='*72)
        sentences = gen.generate(target, user_hsk_level=user_lvl, count=8, seed=42)
        if isinstance(sentences, dict):
            print(f"  ⚠ {sentences}")
            continue
        for i, s in enumerate(sentences, 1):
            print(f"  {i}. {s['zh']:<25} — {s['vi']}")
            print(f"     [{s['frame_id']} | {s['frame_grammar']:<22} | {s['scenario']:<8} | {s['mood']}]")
        report = gen.diversity_report(sentences)
        print(f"\n  Diversity: {report['unique_frames']} frames | "
              f"{report['unique_scenarios']} scenarios | "
              f"{report['unique_moods']} moods | "
              f"{report['unique_collocation_partners']} partners")
