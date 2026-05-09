# PLAN_gene Quality Gate Progress

Source plan: `docs/PLAN_gene.md`

## Checklist

- [x] B1 - Schema mới, T12, analyze
- [x] B2 - Loader, wiring, empty assets
- [x] B3 - Validator pipeline, generateWithStats, T1-T11
- [x] B4 - Patch both frames_bank mirrors
- [ ] B5 - Curate semantic JSON, pause for review
- [ ] B6 - Fill sentence_quality_rules.json
- [ ] B7 - Smoke audit and ignore temporary audit script
- [ ] B8 - Cleanup README, final tests, analyze

## Notes

- Vault assumption: this repository tracks progress notes under `docs/progress/`.
- `pubspec.yaml` already includes `assets/data/generated/`, so new generated
  assets are covered by the existing glob.
