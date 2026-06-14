# Generated Learning Data

Generated/support data for the offline learning engine.

## Runtime assets

- `collocations_db.json`: curated/mined collocation heads and partners.
- `frames_bank.json`: validated sentence frames for on-demand generation.
- `learning_metadata_hsk1_3.json`: production metadata for HSK1-HSK3 vocab.
- `hsk3_bridge_modules.json`: temporary HSK3 bridge modules from grammar examples + conversation context.

## QA and curation assets

- `vi_short_overrides_curated_hsk1_3.json`: curated Vietnamese short gloss overrides.
- `slot_compatibility_curated_hsk1_3.json`: curated slot compatibility overrides.
- `vi_short_overrides_seed_hsk1_3.json`: generated curation seed.
- `slot_compatibility_seed_hsk1_3.json`: generated curation seed.
- `collocation_gap_candidates_hsk1_3.json`: prioritized verb/adj candidates for future collocation expansion.

## Legacy/static asset

- `collocation_pool_hsk1_4.json`: legacy static pool kept for compatibility/tests. Runtime learning now uses `collocations_db.json` + `frames_bank.json` on demand.

## Tooling

Learning content scripts live in `tool/learning_content/`. Root `tool/*.py` wrappers are kept for backwards-compatible commands.
