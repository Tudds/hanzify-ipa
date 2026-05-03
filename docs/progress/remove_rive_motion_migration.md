# Remove Rive / Motion Migration Progress

## Goal

Replace Rive runtime usage with lightweight Flutter-native motion: built-in animations, `flutter_animate`, `CustomPainter` where needed, and existing `confetti` for rewards.

## Progress

- [x] Audit Rive usage in app code.
- [x] Replace `GameWorldScreen` Rive scene with a Flutter placeholder scene.
- [x] Remove direct Rive controller calls from quiz feedback.
- [x] Remove `rive` from Flutter dependencies.
- [x] Add shared motion tokens for durations and curves.
- [x] Add animated answer feedback beyond SnackBar.
- [x] Add lesson unlock/path node motion.
- [ ] Decide whether historical Rive docs/assets should be archived or deleted.

## Notes

- Rive usage was limited to `lib/rive/` and `GameWorldScreen`.
- Current replacement keeps the existing visual placeholder and feedback flow to minimize risk.
