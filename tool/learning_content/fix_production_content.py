#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets' / 'data'
GENERATED = DATA / 'generated'
CONVERSATION_FILE = DATA / 'conversation.json'
VI_CURATED_FILE = GENERATED / 'vi_short_overrides_curated_hsk1_3.json'

VI_FIXES = {
    'Đúng vậy,据说 Trường Thành có hơn hai nghìn năm lịch sử.': 'Đúng vậy, nghe nói Trường Thành có hơn hai nghìn năm lịch sử.',
    'Cụ thể而言, bạn có đề xuất gì?': 'Cụ thể thì bạn có đề xuất gì?',
}

EXTRA_VI_OVERRIDES = {
    'hsk2_比如': 'ví dụ',
}


def load(path):
    return json.loads(path.read_text(encoding='utf-8'))


def write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def normalize_conversations():
    conversations = load(CONVERSATION_FILE)
    changed = 0
    for conv in conversations:
        for line in conv.get('lines') or []:
            vi = line.get('vi')
            if vi in VI_FIXES:
                line['vi'] = VI_FIXES[vi]
                changed += 1
        if 'speakers' not in conv:
            conv['speakers'] = [
                {'code': 'A', 'nameVi': 'An', 'role': 'Người nói A', 'avatarColor': '#3F51B5'},
                {'code': 'B', 'nameVi': 'Bình', 'role': 'Người nói B', 'avatarColor': '#009688'},
            ]
            changed += 1
        if 'cultureTip' not in conv:
            conv['cultureTip'] = 'Nội dung hội thoại được dùng để luyện giao tiếp theo cấp độ HSK tương ứng.'
            changed += 1
        if 'isBookmarked' not in conv:
            conv['isBookmarked'] = False
            changed += 1
        if 'isMastered' not in conv:
            conv['isMastered'] = False
            changed += 1
    write(CONVERSATION_FILE, conversations)
    return changed


def apply_extra_vi_overrides():
    data = load(VI_CURATED_FILE)
    items = data.get('items', [])
    by_id = {item['id']: item for item in items}
    changed = 0
    for item_id, override in EXTRA_VI_OVERRIDES.items():
        if item_id in by_id:
            if by_id[item_id].get('override_vi_short') != override:
                by_id[item_id]['override_vi_short'] = override
                changed += 1
        else:
            items.append({
                'id': item_id,
                'hanzi': item_id.split('_', 1)[1],
                'level': int(item_id[3]),
                'current_vi_short': '',
                'override_vi_short': override,
            })
            changed += 1
    data['items'] = items
    write(VI_CURATED_FILE, data)
    return changed


def main():
    conversation_changes = normalize_conversations()
    vi_changes = apply_extra_vi_overrides()
    print(f'conversation changes: {conversation_changes}')
    print(f'vi override changes: {vi_changes}')


if __name__ == '__main__':
    main()
