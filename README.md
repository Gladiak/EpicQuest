# EpicQuest

EpicQuest is an idle/comedy RPG built with SwiftUI for macOS, inspired by the classic Progress Quest tone: your character advances automatically through quests, battles, loot, town selling, upgrades, and long-term progression.

## Highlights

- Character creation with race, class, and stat roll/unroll.
- Automatic progression through acts, quests, and battles.
- Automatic Arena runs every few encounters with escalating rounds and bonus rewards.
- Multi-slot equipment loot system with quality, bonuses, and procedural naming.
- Inventory load management with return-to-town phase, auto-selling, and merchant upgrades.
- Honor progression: Arena success increases Honor, unlocks merchant-quality boosts, and grants small permanent stat growth milestones.
- Spell Book with rare end-of-act boss scroll drops, spell levels, and MP costs.
- MP regeneration over time and spell usage that increases kill rate.
- Progression tuning constants centralized for easier balancing iterations.
- Combat vitality loop: HP loss per battle, emergency retreat at critical HP, and full town recovery.
- Automatic save/restore of full game state.

## Tech Stack

- Swift
- SwiftUI
- macOS app target (Xcode)

## Project Structure

```text
EpicQuest/
├─ EpicQuest/
│  ├─ Game/                  # State, progression, loot, persistence logic
│  ├─ GameData/              # Name pools (quests, monsters, equipment, spells, attributes)
│  ├─ Models/                # Domain models and save snapshots
│  ├─ Views/                 # SwiftUI UI (character creation + game screen)
│  ├─ UI/                    # UI constants/helpers
│  ├─ Assets.xcassets/       # Asset catalog (icons, colors)
│  ├─ ContentView.swift
│  └─ EpicQuestApp.swift
└─ Products/
```

## Gameplay Loop

1. Create a character (race + class).
2. Roll stats and start the adventure.
3. Fight automatically and complete quests/acts.
4. Gain loot, auto-equip upgrades, or store items in inventory.
5. When inventory is full:
   - return to town,
   - auto-sell loot,
   - buy merchant upgrades,
   - resume adventure.
6. End-of-act bosses: low chance to drop spell scrolls (scales with act/level).

## Requirements

- macOS
- Recent Xcode version with SwiftUI support

## Run Locally

1. Open the project in Xcode.
2. Select the `EpicQuest` scheme.
3. Build & Run (`⌘R`).

## Project Status

Active development. The core gameplay loop is already playable and includes:

- automatic progression,
- economy loop (loot/sell/buy),
- spell progression,
- persistent saves.

## Roadmap (Ideas)

- Advanced balancing for XP/loot/drop curves.
- Class talent tree or passive specialization.
- More random events and act content.
- Additional UI polish and richer visual feedback.

## License

Add your preferred license here (for example MIT) before publishing.
