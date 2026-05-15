# EpicQuest ⚔️🤣

Benvenuto in **EpicQuest**, l'idle RPG per macOS dove il tuo eroe lavora mentre tu ti godi lo spettacolo.  
Ispirazione: vibes da *Progress Quest*.  
Risultato: botte, loot, magie, arena, upgrade e una quantità sana di caos controllato. 🍻

## Perché è una droga (buona) 🎯

- Crei il personaggio con razza, classe e roll/unroll delle stats.
- Avatar della scheda personaggio generato in base a razza/classe.
- Progressione automatica tra atti, quest e combattimenti.
- Arena automatica ogni tot incontri con round sempre più tosti e ricompense più golose.
- Modificatori Arena dinamici: ogni run può cambiare le regole per alzare il pepe (e il premio).
- Progetti della città automatici: l'oro in surplus viene investito in upgrade permanenti.
- Loot equip multi-slot con qualità, bonus e naming procedurale.
- Inventario intelligente: pieno -> ritorno in città -> auto-vendita -> upgrade -> ripartenza.
- Progressione Honor: più domini l'arena, più sblocchi bonus e mini-crescita permanente delle stats.
- Spell Book con pergamene rare dai boss di fine atto, livelli magia e costo MP.
- Rigenerazione MP nel tempo + magie che accelerano la velocità di kill.
- Costanti di bilanciamento centralizzate per tweak rapidi e puliti.
- Loop vitalità: perdi HP in battaglia, ritirata d'emergenza a HP critici, recupero completo in città.
- Salvataggio/ripristino automatico dello stato completo. Sempre. 🛟

## Stack Tecnologico 🛠️

- Swift
- SwiftUI
- Target macOS (Xcode)

## Struttura Progetto 🗂️

```text
EpicQuest/
├─ EpicQuest/
│  ├─ Game/                  # Logica di stato, progressione, loot, persistenza
│  ├─ GameData/              # Pool nomi (quest, mostri, equip, spell, attributi)
│  ├─ Models/                # Modelli dominio e snapshot di salvataggio
│  ├─ Views/                 # UI SwiftUI (creazione personaggio + schermata di gioco)
│  ├─ UI/                    # Costanti/helper di presentazione
│  ├─ Assets.xcassets/       # Catalogo asset (icone, colori)
│  ├─ ContentView.swift
│  └─ EpicQuestApp.swift
└─ Products/
```

## Loop di Gioco (aka "si parte e non ci si ferma") 🔁

1. Crea il personaggio (razza + classe).
2. Rerolla le stats finché il destino ti sorride.
3. Parti all'avventura: combattimenti e quest in automatico.
4. Raccogli loot, auto-equip del meglio e stiva il resto.
5. Inventario pieno? Si torna in città:
   - auto-vendita,
   - acquisto upgrade mercante,
   - autofinanziamento progetti cittadini,
   - ritorno immediato all'avventura.
6. Boss di fine atto: bassa chance di drop pergamene magia (scala con atto/livello).

## Requisiti 📦

- macOS
- Versione recente di Xcode con supporto SwiftUI

## Avvio Locale 🚀

1. Apri il progetto in Xcode.
2. Seleziona lo scheme `EpicQuest`.
3. Build & Run (`⌘R`) e lascia che il grind faccia il suo sporco lavoro.

## Stato Progetto 🧪

Sviluppo attivo. Il core loop è già giocabile e include:

- progressione automatica,
- economia (loot/vendi/compra),
- progressione magie,
- salvataggi persistenti.

## Roadmap (Idee Folli ma Buone) 🧠

- Bilanciamento avanzato di curve XP/loot/drop.
- Talent tree di classe o specializzazioni passive.
- Eventi random aggiuntivi e più contenuti per atto.
- Maggiore polish UI e feedback visivo ancora più appagante.

## License 📜

Aggiungi la licenza che preferisci (esempio: MIT) prima della pubblicazione.
