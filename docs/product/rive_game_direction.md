# Hanzify Rive Game Direction

Hanzify is being rebuilt as a web-first Flutter learning game powered by Rive and Supabase.

## Product Direction

- Rive owns character animation, scene feedback, and state-machine driven interactions.
- Flutter owns routing, layout, learning logic, data loading, and Supabase integration.
- Supabase owns user identity, progress, rewards, and learning content sync.

## First Vertical Slice

1. Replace the placeholder world scene with a `.riv` world map.
2. Bind the Rive state machine inputs: `correct`, `wrong`, `walk`, `talk`, `reward`.
3. Load review challenges from Supabase instead of hardcoded sample data.
4. Persist answer events, XP, streak, and unlocked locations.

## Web-First Constraint

Keep all new code compatible with Flutter web before adding native-only storage or platform APIs.
