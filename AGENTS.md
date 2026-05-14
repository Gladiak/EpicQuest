# AGENTS.md

This document defines practical engineering guidelines for sustainable development of **EpicQuest**.

## 1. Core Principles

- Keep gameplay deterministic where intentionally designed (for balance reproducibility).
- Prefer small, reversible changes over large rewrites.
- Separate **game logic** from **UI rendering**.
- Preserve save compatibility whenever possible.
- Optimize for readability first, micro-optimization second.

## 2. Architecture Boundaries

- `Game/`: authoritative gameplay logic.
- `Models/`: data structures and serialization contracts.
- `GameData/`: static pools and content tables.
- `Views/`: rendering and interaction only (no business logic).
- `UI/`: constants and presentation-level helpers.

Rules:
- Do not move game rules into SwiftUI views.
- Do not duplicate progression formulas across files.
- Keep side effects (save/load, timers) centralized in `GameState` extensions.

## 3. State Management

- `GameState` is the single source of truth.
- Add new state fields with explicit default values.
- When introducing new persisted fields:
  1. add them to snapshot model,
  2. add them to `snapshot()`,
  3. add them to `apply(snapshot:)`,
  4. ensure reset/start flows initialize them.
- Never leave transient flags in inconsistent combinations.

## 4. Persistence and Compatibility

- Treat save schema changes as high-risk.
- Prefer additive changes over destructive renames.
- If semantics change significantly, provide safe fallback behavior on load.
- Avoid storing derived values unless needed for migration/performance.

## 5. Gameplay and Balance

- Keep progression curves gradual and explainable.
- Use deterministic seeds when behavior must be reproducible (race/class growth, etc.).
- Keep randomness bounded and auditable.
- Add balancing constants in a visible place; avoid magic numbers spread across methods.
- When adding systems (spells, merchant, boss drops), define how they interact with:
  - XP pacing
  - gold economy
  - kill speed
  - inventory pressure

## 6. UI and UX Consistency

- Reuse shared row/panel components before creating new variants.
- Keep alignment and spacing constants centralized.
- Preserve readability first (contrast, text clarity, progress visibility).
- Prefer incremental visual changes over wholesale style flips.
- macOS-specific window changes must not regress discoverability/usability.

## 7. Performance Guidelines

- Keep `tick()` lightweight and predictable.
- Avoid expensive work every frame/tick if it can be cached or deferred.
- Bound collection growth (logs/history) when needed.
- Use simple data structures unless profiling indicates otherwise.

## 8. Testing and Verification

For each non-trivial change:
- Build project successfully.
- Verify affected views compile with no diagnostics.
- Manually validate gameplay loop scenarios:
  - character creation roll/unroll
  - battle progression
  - inventory full -> return to town -> sell -> buy -> resume
  - spell drop/leveling/MP consumption-regen
  - save/load continuity

Recommended future additions:
- deterministic simulation tests for progression/economy.
- snapshot tests for critical UI panels.

## 9. Git and Change Hygiene

- One concern per change set.
- Avoid unrelated formatting churn.
- Document behavior changes in commit messages and PR notes.
- If a change affects balancing, include before/after rationale.

## 10. Documentation Discipline

When features evolve, update:
- `README.md` (player-facing features and setup)
- `AGENTS.md` (engineering practices)
- Inline comments only where logic is non-obvious

## 11. Safe Extension Checklist

Before merging a new feature, confirm:
- [ ] logic is in the correct layer
- [ ] persistence is wired end-to-end
- [ ] reset/new game paths are coherent
- [ ] no contradictory state flags
- [ ] UI remains readable
- [ ] build succeeds
- [ ] gameplay loop still feels coherent

---

If a proposed change conflicts with these guidelines, prioritize long-term maintainability and predictability over short-term speed.
