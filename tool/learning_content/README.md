# Learning Content Tools

Production content pipeline scripts.

Run in order when content changes:

```bash
python3 tool/apply_learning_content_curations.py
python3 tool/fix_production_content.py
python3 tool/build_learning_metadata.py
python3 tool/qa_learning_content.py
```

- `apply_learning_content_curations.py`: applies curated `vi_short`, slot overrides, and HSK3 conversations idempotently.
- `fix_production_content.py`: normalizes production data and known translation/metadata fixes.
- `build_learning_metadata.py`: regenerates HSK1-HSK3 learning metadata and missing-data report.
- `qa_learning_content.py`: production content gate; fails on errors.
