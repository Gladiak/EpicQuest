import SwiftUI

@Observable
final class GameState {
    var phase: GamePhase = .characterCreation
    var character = CharacterData()

    var level = 1
    var gold = 0
    var hpMax = 10
    var mpMax = 5
    var currentMP = 5.0

    var experience = 0
    var experienceToNextLevel = 50

    var currentActNumber = 0
    var completedActs: [String] = []
    var questsCompletedInCurrentAct = 0
    var questsPerAct = 4

    var completedQuestNames: [String] = []
    var currentQuest = "Prepare your gear"
    var battlesPerQuest = 3
    var completedBattlesInQuest = 0

    var currentMonster = "Training Dummy"
    var battleProgress = 0.0

    var equipment: [EquipmentSlot: LootItem] = [:]
    var inventory: [LootItem] = []
    var inventoryCapacity = 10.0
    var inventoryLoad = 0.0
    var knownSpells: [SpellEntry] = []

    var logLine = "Roll your stats and start."
    var isSellingInTown = false
    var actAttackBonus = 0
    var actDefenseBonus = 0

    var experienceProgress: Double {
        Double(experience) / Double(max(experienceToNextLevel, 1))
    }

    var actProgress: Double {
        Double(questsCompletedInCurrentAct) / Double(max(questsPerAct, 1))
    }

    var questProgress: Double {
        Double(completedBattlesInQuest) / Double(max(battlesPerQuest, 1))
    }

    var inventoryProgress: Double {
        inventoryLoad / max(inventoryCapacity, 1)
    }

    var currentActLabel: String {
        if currentActNumber == 0 { return "Prologue" }
        return "Act \(romanNumeral(currentActNumber))"
    }

    var spellCombatBonus: Double {
        let totalSpellLevels = knownSpells.reduce(0) { $0 + $1.level }
        let bonus = Double(totalSpellLevels) * 0.002
        return min(0.12, bonus)
    }

    var battleTickStep: Double {
        0.08 + spellCombatBonus
    }

    var currentMPInt: Int {
        Int(currentMP.rounded(.down))
    }

    var plotItems: [ReadOnlyCheckItem] {
        var items = [ReadOnlyCheckItem(title: "Prologue", isCompleted: completedActs.contains("Prologue"))]
        for act in completedActs where act != "Prologue" {
            items.append(ReadOnlyCheckItem(title: act, isCompleted: true))
        }
        if items.last?.title != currentActLabel {
            items.append(ReadOnlyCheckItem(title: currentActLabel, isCompleted: false))
        }
        return items
    }

    var questItems: [ReadOnlyCheckItem] {
        var items = completedQuestNames.suffix(5).map { ReadOnlyCheckItem(title: $0, isCompleted: true) }
        items.append(ReadOnlyCheckItem(title: currentQuest, isCompleted: false))
        return items
    }

    var attack: Int {
        character.str + (character.dex / 2) + actAttackBonus
    }

    var defense: Int {
        character.con + (character.wis / 2) + actDefenseBonus
    }

    private var timerStarted = false
    private var timerTask: Task<Void, Never>?
    private var statRollHistory: [[Int]] = []

    func startTimerIfNeeded() {
        guard !timerStarted else { return }
        timerStarted = true

        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                await MainActor.run {
                    tick()
                }
            }
        }
    }

    func restoreIfPossible() {
        guard let snapshot = loadSnapshot() else { return }
        apply(snapshot: snapshot)
    }

    func resetToNewCharacter() {
        phase = .characterCreation
        character = CharacterData()
        level = 1
        gold = 0
        hpMax = 10
        mpMax = 5
        currentMP = Double(mpMax)
        experience = 0
        experienceToNextLevel = 50

        currentActNumber = 0
        completedActs.removeAll()
        questsCompletedInCurrentAct = 0
        questsPerAct = questsRequiredForCurrentAct()

        completedQuestNames.removeAll()
        currentQuest = "Prepare your gear"
        battlesPerQuest = 3
        completedBattlesInQuest = 0

        currentMonster = "Training Dummy"
        battleProgress = 0

        equipment.removeAll()
        inventory.removeAll()
        inventoryCapacity = 10
        inventoryLoad = 0
        knownSpells.removeAll()

        logLine = "Roll your stats and start."
        isSellingInTown = false
        statRollHistory.removeAll()
        actAttackBonus = 0
        actDefenseBonus = 0

        deleteSave()
    }

    func rollStats() {
        statRollHistory.append([
            character.str,
            character.con,
            character.dex,
            character.int,
            character.wis,
            character.cha
        ])

        character.str = Int.random(in: 1...20)
        character.con = Int.random(in: 1...20)
        character.dex = Int.random(in: 1...20)
        character.int = Int.random(in: 1...20)
        character.wis = Int.random(in: 1...20)
        character.cha = Int.random(in: 1...20)
        saveCurrentGame()
    }

    func unrollStats() {
        guard let previous = statRollHistory.popLast(), previous.count == 6 else { return }
        character.str = previous[0]
        character.con = previous[1]
        character.dex = previous[2]
        character.int = previous[3]
        character.wis = previous[4]
        character.cha = previous[5]
        saveCurrentGame()
    }

    func startAdventure() {
        phase = .adventuring
        level = 1
        gold = 0
        hpMax = 10
        mpMax = 5
        currentMP = Double(mpMax)
        experience = 0
        experienceToNextLevel = 50

        currentActNumber = 0
        completedActs.removeAll()
        questsCompletedInCurrentAct = 0
        questsPerAct = questsRequiredForCurrentAct()

        completedQuestNames.removeAll()
        startNewQuest(isPrologue: true)

        equipment.removeAll()
        inventory.removeAll()
        inventoryLoad = 0
        inventoryCapacity = 10
        knownSpells.removeAll()

        isSellingInTown = false
        battleProgress = 0
        logLine = "Starting Prologue."
        statRollHistory.removeAll()

        resetActBonuses()
        seedInitialEquipment()
        saveCurrentGame()
    }

    func tick() {
        guard phase == .adventuring else { return }

        regenerateMP()

        if isSellingInTown {
            sellStep()
            saveCurrentGame()
            return
        }

        castBestSpellIfPossible()
        battleProgress += battleTickStep
        if battleProgress < 1 {
            saveCurrentGame()
            return
        }

        battleProgress = 0
        resolveBattle()

        if inventoryProgress >= 1 {
            isSellingInTown = true
            logLine = "Backpack full. Returning to town to sell loot."
        }

        saveCurrentGame()
    }
}
