#!/usr/bin/env python3
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets' / 'data'
GENERATED = DATA / 'generated'
REPORT = ROOT / 'docs' / 'progress' / 'production_content_qa_2026-04-27.md'

CHINESE_RE = re.compile(r'[\u4e00-\u9fff]')
PINYIN_RE = re.compile(r'[A-Za-zāáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜüÜńňǹḿ]')
LEFTOVER_RE = re.compile(r'[{}]|VVO|VN2?|VADJ|VV')

EXPECTED_CONV_KEYS = {
    'id', 'title', 'titleZh', 'titlePinyin', 'description', 'level', 'category', 'icon',
    'lines', 'vocabulary', 'speakers', 'relatedGrammar', 'cultureTip', 'isBookmarked', 'isMastered'
}


def load(path):
    return json.loads(path.read_text(encoding='utf-8'))


def issue(issues, severity, code, path, detail):
    issues.append({'severity': severity, 'code': code, 'path': path, 'detail': detail})


def audit_vocab(issues):
    seen_ids = set()
    canonical = defaultdict(list)
    for level in (1, 2, 3):
        rows = load(DATA / f'hsk{level}.json')
        for index, row in enumerate(rows):
            path = f'assets/data/hsk{level}.json[{index}]'
            row_id = row.get('id')
            if not row_id:
                issue(issues, 'error', 'vocab_missing_id', path, 'missing id')
            elif row_id in seen_ids:
                issue(issues, 'error', 'vocab_duplicate_id', path, row_id)
            seen_ids.add(row_id)
            for key in ['hanzi', 'pinyin', 'meanings', 'exampleSentences', 'level', 'wordType']:
                if key not in row or row[key] in (None, '', []):
                    issue(issues, 'error', 'vocab_missing_field', path, key)
            if row.get('level') != level:
                issue(issues, 'error', 'vocab_wrong_level', path, f"expected {level}, got {row.get('level')}")
            if row.get('hanzi') and not CHINESE_RE.search(row['hanzi']):
                issue(issues, 'warning', 'vocab_hanzi_no_chinese', path, row['hanzi'])
            for ex_index, ex in enumerate(row.get('exampleSentences') or []):
                ex_path = f'{path}.exampleSentences[{ex_index}]'
                for key in ['cn', 'pinyin', 'vi']:
                    if not ex.get(key):
                        issue(issues, 'error', 'vocab_example_missing_field', ex_path, key)
                if ex.get('cn') and not CHINESE_RE.search(ex['cn']):
                    issue(issues, 'error', 'vocab_example_no_chinese', ex_path, ex.get('cn'))
            canonical[f"{row.get('hanzi')}_{row.get('pinyin')}"] .append(row_id)
    for key, ids in canonical.items():
        if len(ids) > 1:
            issue(issues, 'info', 'canonical_duplicate_tracked', 'assets/data/hsk*.json', f'{key}: {ids[:6]}')


def audit_grammar(issues):
    grammar_ids = set()
    for level in (1, 2, 3, 4):
        rows = load(DATA / f'grammar_hsk{level}.json')
        for index, row in enumerate(rows):
            path = f'assets/data/grammar_hsk{level}.json[{index}]'
            row_id = row.get('id')
            if not row_id:
                issue(issues, 'error', 'grammar_missing_id', path, 'missing id')
            elif row_id in grammar_ids:
                issue(issues, 'error', 'grammar_duplicate_id', path, row_id)
            grammar_ids.add(row_id)
            for key in ['title', 'structure', 'explanation', 'level', 'examples']:
                if key not in row or row[key] in (None, '', []):
                    issue(issues, 'error', 'grammar_missing_field', path, key)
            if row.get('level') != level:
                issue(issues, 'error', 'grammar_wrong_level', path, f"expected {level}, got {row.get('level')}")
            for ex_index, ex in enumerate(row.get('examples') or []):
                ex_path = f'{path}.examples[{ex_index}]'
                for key in ['zh', 'pinyin', 'vi']:
                    if not ex.get(key):
                        issue(issues, 'error', 'grammar_example_missing_field', ex_path, key)
                if ex.get('zh') and not CHINESE_RE.search(ex['zh']):
                    issue(issues, 'error', 'grammar_example_no_chinese', ex_path, ex.get('zh'))
    return grammar_ids


def audit_conversation(issues, grammar_ids):
    rows = load(DATA / 'conversation.json')
    ids = set()
    line_texts = Counter()
    by_level = Counter()
    for index, row in enumerate(rows):
        path = f'assets/data/conversation.json[{index}]'
        row_id = row.get('id')
        if not row_id:
            issue(issues, 'error', 'conversation_missing_id', path, 'missing id')
        elif row_id in ids:
            issue(issues, 'error', 'conversation_duplicate_id', path, row_id)
        ids.add(row_id)
        missing_keys = EXPECTED_CONV_KEYS - set(row)
        for key in sorted(missing_keys):
            issue(issues, 'error', 'conversation_missing_field', path, key)
        level = row.get('level') or row.get('hskLevel')
        by_level[level] += 1
        if level not in {1, 2, 3, 4}:
            issue(issues, 'error', 'conversation_bad_level', path, str(level))
        lines = row.get('lines') or []
        if len(lines) < 4:
            issue(issues, 'error', 'conversation_too_short', path, f'{len(lines)} lines')
        for line_index, line in enumerate(lines):
            line_path = f'{path}.lines[{line_index}]'
            for key in ['speaker', 'zh', 'pinyin', 'vi']:
                if not line.get(key):
                    issue(issues, 'error', 'conversation_line_missing_field', line_path, key)
            zh = line.get('zh', '')
            vi = line.get('vi', '')
            pinyin = line.get('pinyin', '')
            if zh and not CHINESE_RE.search(zh):
                issue(issues, 'error', 'conversation_line_no_chinese', line_path, zh)
            if pinyin and not PINYIN_RE.search(pinyin):
                issue(issues, 'error', 'conversation_line_bad_pinyin', line_path, pinyin)
            if vi and CHINESE_RE.search(vi):
                issue(issues, 'error', 'conversation_vi_contains_chinese', line_path, vi)
            if zh:
                line_texts[zh] += 1
        for grammar_id in row.get('relatedGrammar') or []:
            if grammar_id not in grammar_ids:
                issue(issues, 'error', 'conversation_unknown_grammar', path, grammar_id)
    for text, count in line_texts.items():
        if count > 1:
            issue(issues, 'warning', 'conversation_duplicate_line', 'assets/data/conversation.json', f'{text} x{count}')
    return by_level


def audit_generated(issues):
    metadata = load(GENERATED / 'learning_metadata_hsk1_3.json')
    ids = set()
    for index, row in enumerate(metadata.get('vocab') or []):
        path = f'assets/data/generated/learning_metadata_hsk1_3.json.vocab[{index}]'
        row_id = row.get('id')
        if not row_id:
            issue(issues, 'error', 'metadata_missing_id', path, 'missing id')
        elif row_id in ids:
            issue(issues, 'error', 'metadata_duplicate_id', path, row_id)
        ids.add(row_id)
        for key in ['canonical_key', 'frequency_count', 'frequency_rank', 'slot_compatibility', 'vi_short', 'vocab_grammar_links', 'has_collocations']:
            if key not in row:
                issue(issues, 'error', 'metadata_missing_field', path, key)
        if row.get('vi_short') and CHINESE_RE.search(row['vi_short']):
            issue(issues, 'error', 'metadata_vi_short_contains_chinese', path, row['vi_short'])
    frames = load(GENERATED / 'frames_bank.json')
    frame_ids = set()
    for index, frame in enumerate(frames.get('frames') or []):
        path = f'assets/data/generated/frames_bank.json.frames[{index}]'
        frame_id = frame.get('id')
        if frame_id in frame_ids:
            issue(issues, 'error', 'frame_duplicate_id', path, frame_id)
        frame_ids.add(frame_id)
        for key in ['zh', 'vi', 'slot_types', 'grammar_focus', 'hsk_level_min', 'complexity']:
            if key not in frame or frame[key] in (None, '', []):
                issue(issues, 'error', 'frame_missing_field', path, key)
        if LEFTOVER_RE.search(frame.get('zh', '').replace('{VO}', '').replace('{V}', '').replace('{N}', '').replace('{N2}', '').replace('{ADJ}', '')):
            issue(issues, 'warning', 'frame_unexpected_token', path, frame.get('zh'))


def write_report(issues, by_level):
    counts = Counter((item['severity'], item['code']) for item in issues)
    lines = [
        '# Production content QA — HSK1-HSK3',
        '',
        'Ngày audit: 2026-04-27',
        '',
        '## Summary',
        '',
        f'- Errors: {sum(1 for item in issues if item["severity"] == "error")}',
        f'- Warnings: {sum(1 for item in issues if item["severity"] == "warning")}',
        f'- Info: {sum(1 for item in issues if item["severity"] == "info")}',
        f'- Conversation by level: {dict(sorted(by_level.items()))}',
        '',
        '## Issue counts',
        '',
        '| Severity | Code | Count |',
        '|---|---|---:|',
    ]
    for (severity, code), count in sorted(counts.items()):
        lines.append(f'| {severity} | `{code}` | {count} |')
    lines += ['', '## Error details', '']
    errors = [item for item in issues if item['severity'] == 'error']
    if not errors:
        lines.append('Không có error.')
    else:
        for item in errors[:200]:
            lines.append(f'- `{item["code"]}` at `{item["path"]}`: {item["detail"]}')
    lines += ['', '## Warning samples', '']
    warnings = [item for item in issues if item['severity'] == 'warning']
    if not warnings:
        lines.append('Không có warning.')
    else:
        for item in warnings[:100]:
            lines.append(f'- `{item["code"]}` at `{item["path"]}`: {item["detail"]}')
    lines += ['', '## Info samples', '']
    infos = [item for item in issues if item['severity'] == 'info']
    if not infos:
        lines.append('Không có info.')
    else:
        for item in infos[:100]:
            lines.append(f'- `{item["code"]}` at `{item["path"]}`: {item["detail"]}')
    REPORT.write_text('\n'.join(lines) + '\n', encoding='utf-8')


def main():
    issues = []
    audit_vocab(issues)
    grammar_ids = audit_grammar(issues)
    by_level = audit_conversation(issues, grammar_ids)
    audit_generated(issues)
    write_report(issues, by_level)
    errors = sum(1 for item in issues if item['severity'] == 'error')
    warnings = sum(1 for item in issues if item['severity'] == 'warning')
    print(f'wrote {REPORT.relative_to(ROOT)}')
    print(f'errors={errors} warnings={warnings}')
    if errors:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
