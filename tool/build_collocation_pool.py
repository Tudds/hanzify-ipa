#!/usr/bin/env python3
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'assets' / 'data'
OUT = DATA / 'generated' / 'collocation_pool_hsk1_4.json'

CJK_RE = re.compile(r'[\u4e00-\u9fff]+')


def load_json(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def stable_id(text):
    digest = hashlib.sha1(text.encode('utf-8')).hexdigest()[:12]
    return f'col_{digest}'


def normalize_text(text):
    return re.sub(r'\s+', '', (text or '').strip())


def uniq(values):
    return sorted({v for v in values if v})


def difficulty(level, text):
    chars = len(CJK_RE.findall(text))
    cjk_len = sum(len(x) for x in CJK_RE.findall(text))
    return round(float(level) + min(1.5, cjk_len / 20.0), 2)


def merge_item(items, candidate):
    key = candidate['textCn']
    if key not in items:
        items[key] = candidate
        return
    current = items[key]
    current['level'] = min(current['level'], candidate['level'])
    if not current.get('pinyin') and candidate.get('pinyin'):
        current['pinyin'] = candidate['pinyin']
    if not current.get('textVi') and candidate.get('textVi'):
        current['textVi'] = candidate['textVi']
    current['targetVocabIds'] = uniq(current['targetVocabIds'] + candidate['targetVocabIds'])
    current['targetGrammarIds'] = uniq(current['targetGrammarIds'] + candidate['targetGrammarIds'])
    current['conversationIds'] = uniq(current['conversationIds'] + candidate['conversationIds'])
    current['tags'] = uniq(current['tags'] + candidate['tags'])
    sources = set(current['source'].split('+')) | set(candidate['source'].split('+'))
    current['source'] = '+'.join(sorted(sources))
    current['difficulty'] = difficulty(current['level'], current['textCn'])


def make_item(source, level, text_cn, pinyin='', text_vi='', vocab_ids=None, grammar_ids=None, conversation_ids=None, tags=None):
    text_cn = normalize_text(text_cn)
    return {
        'id': stable_id(text_cn),
        'level': int(level or 1),
        'source': source,
        'textCn': text_cn,
        'pinyin': (pinyin or '').strip(),
        'textVi': (text_vi or '').strip(),
        'targetVocabIds': uniq(vocab_ids or []),
        'targetGrammarIds': uniq(grammar_ids or []),
        'conversationIds': uniq(conversation_ids or []),
        'tags': uniq(tags or []),
        'difficulty': difficulty(int(level or 1), text_cn),
    }


def main():
    vocab_by_hanzi = {}
    vocab_by_id = {}
    grammar_by_id = {}
    conv_vocab = {}
    conv_grammar = {}

    for level in range(1, 5):
        for item in load_json(DATA / f'hsk{level}.json'):
            vocab_by_id[item['id']] = item
            vocab_by_hanzi.setdefault(item['hanzi'], []).append(item)

    for level in range(1, 5):
        for item in load_json(DATA / f'grammar_hsk{level}.json'):
            grammar_by_id[item['id']] = item

    for edge in load_json(DATA / 'graph' / 'edges.json'):
        if edge.get('type') == 'vocab_in_conv':
            conv_vocab.setdefault(edge['to'], set()).add(edge['from'])
        elif edge.get('type') in ('grammar_in_conv', 'conv_uses_grammar'):
            conv_grammar.setdefault(edge['to'], set()).add(edge['from'])

    items = {}

    for vocab_id, vocab in vocab_by_id.items():
        for sentence in vocab.get('exampleSentences') or []:
            text = sentence.get('cn') or sentence.get('zh') or ''
            if not text:
                continue
            merge_item(items, make_item(
                'vocab_example', vocab.get('level', 1), text,
                sentence.get('pinyin', ''), sentence.get('vi', ''),
                vocab_ids=[vocab_id], tags=vocab.get('tags') or []))

    for grammar_id, grammar in grammar_by_id.items():
        for example in grammar.get('examples') or []:
            text = example.get('zh') or example.get('cn') or ''
            if not text:
                continue
            merge_item(items, make_item(
                'grammar_example', grammar.get('level', 1), text,
                example.get('pinyin', ''), example.get('vi', ''),
                grammar_ids=[grammar_id], tags=[grammar.get('category', '')] + (grammar.get('exampleTags') or [])))

    for conv in load_json(DATA / 'conversation.json'):
        conv_id = conv['id']
        related_grammar = set(conv.get('relatedGrammar') or []) | conv_grammar.get(conv_id, set())
        related_vocab = set(conv_vocab.get(conv_id, set()))
        for entry in conv.get('vocabulary') or []:
            for vocab in vocab_by_hanzi.get(entry.get('zh'), []):
                related_vocab.add(vocab['id'])
        for line in conv.get('lines') or []:
            text = line.get('zh') or ''
            if not text:
                continue
            line_vocab = set()
            for hanzi, matches in vocab_by_hanzi.items():
                if hanzi and hanzi in text:
                    line_vocab.update(v['id'] for v in matches)
            if not line_vocab:
                line_vocab = set(related_vocab)
            merge_item(items, make_item(
                'conversation_line', conv.get('level', 1), text,
                line.get('pinyin', ''), line.get('vi', ''),
                vocab_ids=line_vocab, grammar_ids=related_grammar,
                conversation_ids=[conv_id], tags=[conv.get('category', '')]))

    output = sorted(items.values(), key=lambda x: (x['level'], x['id']))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'wrote {OUT.relative_to(ROOT)} ({len(output)} items)')


if __name__ == '__main__':
    main()
