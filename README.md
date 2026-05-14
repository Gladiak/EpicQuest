# EpicQuest

EpicQuest è un RPG idle/comedy in SwiftUI per macOS, ispirato al tono classico di Progress Quest: il personaggio avanza automaticamente tra quest, combattimenti, loot, vendita in città, upgrade e progressione continua.

## Highlights

- Character creation con razza, classe e roll/unroll delle statistiche.
- Progressione automatica con atti, quest e combattimenti.
- Sistema loot con equipaggiamento multi-slot, qualità, bonus e naming procedurale.
- Inventario con carico, ritorno al villaggio, vendita automatica e acquisti dal mercante.
- Spell Book con drop rari da boss di fine atto, livelli spell e costi MP.
- MP rigenerato nel tempo e utilizzo spell che accelera il killing rate.
- Salvataggio e ripristino automatico dello stato di gioco.

## Tech Stack

- Swift
- SwiftUI
- macOS app target (Xcode)

## Struttura Progetto

```text
EpicQuest/
├─ EpicQuest/
│  ├─ Game/                  # Logica di stato, progressione, loot, persistenza
│  ├─ GameData/              # Pool nomi (quest, mostri, equip, spell, attributi)
│  ├─ Models/                # Modelli dominio e snapshot salvataggio
│  ├─ Views/                 # UI SwiftUI (creazione personaggio + game screen)
│  ├─ UI/                    # Costanti/UI helpers
│  ├─ Assets.xcassets/       # Asset catalog (icone, colori)
│  ├─ ContentView.swift
│  └─ EpicQuestApp.swift
└─ Products/
```

## Gameplay Loop

1. Crea personaggio (razza + classe).
2. Roll stats e avvia avventura.
3. Combatti automaticamente e completa quest/atti.
4. Ottieni loot, equip automatico o stoccaggio in inventario.
5. Quando l’inventario è pieno:
   - ritorno al villaggio,
   - vendita automatica,
   - acquisti upgrade dal mercante,
   - ripresa avventura.
6. Boss di fine atto: chance bassa di drop scroll spell (scaling con atto/livello).

## Requisiti

- macOS
- Xcode recente con supporto SwiftUI

## Avvio Locale

1. Apri il progetto in Xcode.
2. Seleziona scheme `EpicQuest`.
3. Build & Run (`⌘R`).

## Stato del Progetto

Progetto in sviluppo attivo. La base di gameplay è giocabile e già include:

- progressione automatica,
- economia (loot/sell/buy),
- spell progression,
- salvataggio persistente.

## Roadmap (idee)

- Bilanciamento avanzato di curve XP/loot/drop.
- Skill tree o talenti passivi per classe.
- Più eventi casuali e contenuti di atto.
- UI polish e visual feedback avanzati.
- Metriche/debug panel per tuning gameplay.

## Licenza

Aggiungi qui la licenza desiderata (es. MIT) prima della pubblicazione.
