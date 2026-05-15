# EpicQuest ⚔️🤣

Welcome to **EpicQuest**, the idle RPG for macOS where your hero does the work while you enjoy the show.  
Inspiration: *Progress Quest* vibes.  
Result: brawls, loot, spells, arena fights, upgrades, and a healthy amount of controlled chaos. 🍻

## Why It's So Addictive 🎯

- Create your character with race, class, and stat roll/unroll.
- Character sheet avatar generated from race/class.
- Automatic progression through acts, quests, and battles.
- Automatic arena every few encounters, with tougher and tougher rounds plus juicier rewards.
- Dynamic Arena modifiers: each run can change the rules to raise the stakes and the prize.
- Automatic town projects: surplus gold is invested into permanent upgrades.
- Multi-slot loot equipment with quality tiers, bonuses, and procedural naming.
- Smart inventory flow: full bag -> back to town -> auto-sell -> upgrades -> back on the road.
- Honor progression: the more you dominate the arena, the more bonuses and permanent mini-stat growth you unlock.
- Spell Book with rare scroll drops from end-of-act bosses, spell levels, and MP cost.
- MP regeneration over time plus spells that speed up kill pace.
- Centralized balance constants for quick, clean tweaking.
- Survival loop: lose HP in battle, emergency retreat at critical HP, full recovery in town.
- Automatic save/restore of the full game state. Always. 🛟

## Tech Stack 🛠️

- Swift
- SwiftUI
- macOS target (Xcode)

## Project Structure 🗂️

```text
EpicQuest/
├─ EpicQuest/
│  ├─ Game/                  # State logic, progression, loot, persistence
│  ├─ GameData/              # Name pools (quests, monsters, gear, spells, attributes)
│  ├─ Models/                # Domain models and save snapshots
│  ├─ Views/                 # SwiftUI UI (character creation + gameplay screen)
│  ├─ UI/                    # Presentation constants/helpers
│  ├─ Assets.xcassets/       # Asset catalog (icons, colors)
│  ├─ ContentView.swift
│  └─ EpicQuestApp.swift
└─ Products/
```

## Gameplay Loop (aka "it starts and never stops") 🔁

1. Create your character (race + class).
2. Reroll stats until fate finally smiles at you.
3. Head into adventure: battles and quests happen automatically.
4. Collect loot, auto-equip the best gear, and stash the rest.
5. Inventory full? Back to town:
   - auto-sell,
   - buy merchant upgrades,
   - auto-fund town projects,
   - jump straight back into the adventure.
6. End-of-act bosses: low chance to drop spell scrolls, scaling with act and level.

## Requirements 📦

- macOS
- A recent version of Xcode with SwiftUI support

## Local Run 🚀

1. Open the project in Xcode.
2. Select the `EpicQuest` scheme.
3. Build & Run (`⌘R`) and let the grind do its thing.

## Project Status 🧪

Active development. The core loop is already playable and includes:

- automatic progression,
- economy (loot/sell/buy),
- spell progression,
- persistent saves.

## Roadmap (Wild Ideas, Good Ones) 🧠

- Advanced balancing for XP/loot/drop curves.
- Class talent trees or passive specializations.
- More random events and more content per act.
- More UI polish and even more satisfying visual feedback.

## License 📜

Add the license you prefer (for example: MIT) before publishing.
