import Foundation
import SwiftUI

@Observable
final class GameState {
    private enum SpeedTuning {
        static let defaultMultiplier = 1.0
        static let step = 10.0
        static let minMultiplier = 1.0
        static let maxMultiplier = 1000.0
        static let baseTickMilliseconds = 250
        static let allowedMultipliers: [Double] = [1.0] + stride(from: 10, through: 1000, by: 10).map(Double.init)
    }

    var phase: GamePhase = .characterCreation
    var character = CharacterData()

    var level = 1
    var honorLevel = 0
    var honorMilestonesEarned = 0
    var arenaRating = 1000
    var gold = 0
    var hpMax = 10
    var currentHP = 10.0
    var mpMax = 5
    var currentMP = 5.0

    var experience = 0
    var experienceToNextLevel = BalanceTuning.startingExperienceToNextLevel

    var currentActNumber = 0
    var completedActs: [String] = []
    var questsCompletedInCurrentAct = 0
    var questsPerAct = BalanceTuning.baseQuestsPerAct

    var completedQuestNames: [String] = []
    var currentQuest = "Prepare your gear"
    var battlesPerQuest = BalanceTuning.baseBattlesPerQuest
    var completedBattlesInQuest = 0

    var currentMonster = "Training Dummy"
    var currentMonsterType: MonsterType = .common
    var battleProgress = 0.0
    var battlesUntilNextArena = BalanceTuning.arenaBattleInterval
    var isArenaActive = false
    var arenaRound = 0
    var arenaRoundsTotal = 0
    var arenaWins = 0
    var arenaLosses = 0

    var equipment: [EquipmentSlot: LootItem] = [:]
    var inventory: [LootItem] = []
    var inventoryCapacity = 10.0
    var inventoryLoad = 0.0
    var knownSpells: [SpellEntry] = []

    var logLine = "Roll your stats and start."
    var isSellingInTown = false
    var isReturningToTown = false
    var returnToTownTicksRemaining = 0
    var actAttackBonus = 0
    var actDefenseBonus = 0

    var experienceProgress: Double {
        clampedProgress(Double(experience) / Double(max(experienceToNextLevel, 1)))
    }

    var actProgress: Double {
        clampedProgress(Double(questsCompletedInCurrentAct) / Double(max(questsPerAct, 1)))
    }

    var questProgress: Double {
        clampedProgress(Double(completedBattlesInQuest) / Double(max(battlesPerQuest, 1)))
    }

    var inventoryProgress: Double {
        clampedProgress(inventoryLoad / max(inventoryCapacity, 1))
    }

    var battleProgressValue: Double {
        clampedProgress(battleProgress / BalanceTuning.battleProgressTarget)
    }

    var currentActLabel: String {
        if currentActNumber == 0 { return "Prologue" }
        return "Act \(romanNumeral(currentActNumber))"
    }

    var arenaLeague: ArenaLeague {
        ArenaLeague.from(rating: arenaRating)
    }

    var spellCombatBonus: Double {
        let totalSpellLevels = knownSpells.reduce(0) { $0 + $1.level }
        let bonus = Double(totalSpellLevels) * BalanceTuning.spellStepScale
        return min(BalanceTuning.maxSpellStepBonus, bonus)
    }

    var attackCombatBonus: Double {
        let bonus = Double(max(0, attack)) * BalanceTuning.attackStepScale
        return min(BalanceTuning.maxAttackStepBonus, bonus)
    }

    var defenseCombatBonus: Double {
        let bonus = Double(max(0, defense)) * BalanceTuning.defenseStepScale
        return min(BalanceTuning.maxDefenseStepBonus, bonus)
    }

    var battleTickStep: Double {
        BalanceTuning.baseBattleTickStep + spellCombatBonus + attackCombatBonus + defenseCombatBonus
    }

    var currentHPInt: Int {
        Int(currentHP.rounded(.down))
    }

    var currentMPInt: Int {
        Int(currentMP.rounded(.down))
    }

    var hpProgress: Double {
        clampedProgress(currentHP / Double(max(hpMax, 1)))
    }

    var mpProgress: Double {
        clampedProgress(currentMP / Double(max(mpMax, 1)))
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
        max(0, character.str + (character.dex / 2) + actAttackBonus)
    }

    var defense: Int {
        max(0, character.con + (character.wis / 2) + actDefenseBonus)
    }

    private var timerStarted = false
    private var timerTask: Task<Void, Never>?
    private var statRollHistory: [[Int]] = []

    var lastSaveFilePath = ""

    var baseStr = 0
    var baseCon = 0
    var baseDex = 0
    var baseInt = 0
    var baseWis = 0
    var baseCha = 0
    var gameSpeedMultiplier = SpeedTuning.defaultMultiplier

    func startTimerIfNeeded() {
        guard !timerStarted else { return }
        timerStarted = true

        timerTask = Task {
            while !Task.isCancelled {
                let sleepMilliseconds = await MainActor.run { tickIntervalMilliseconds() }
                try? await Task.sleep(for: .milliseconds(sleepMilliseconds))
                await MainActor.run {
                    runTimerStep()
                }
            }
        }
    }

    func restoreIfPossible() {
        guard let snapshot = loadSnapshot() else { return }
        apply(snapshot: snapshot)
        ensureBaseStatsInitialized()
    }

    func resetToNewCharacter() {
        phase = .characterCreation
        character = CharacterData()
        level = 1
        honorLevel = 0
        honorMilestonesEarned = 0
        arenaRating = 1000
        gold = 0
        hpMax = 10
        currentHP = 10
        mpMax = 5
        currentMP = Double(mpMax)
        experience = 0
        experienceToNextLevel = BalanceTuning.startingExperienceToNextLevel

        currentActNumber = 0
        completedActs.removeAll()
        questsCompletedInCurrentAct = 0
        questsPerAct = questsRequiredForCurrentAct()

        completedQuestNames.removeAll()
        currentQuest = "Prepare your gear"
        battlesPerQuest = BalanceTuning.baseBattlesPerQuest
        completedBattlesInQuest = 0

        currentMonster = "Training Dummy"
        currentMonsterType = .common
        battleProgress = 0
        battlesUntilNextArena = BalanceTuning.arenaBattleInterval
        isArenaActive = false
        arenaRound = 0
        arenaRoundsTotal = 0
        arenaWins = 0
        arenaLosses = 0

        equipment.removeAll()
        inventory.removeAll()
        inventoryCapacity = 10
        inventoryLoad = 0
        knownSpells.removeAll()

        logLine = "Roll your stats and start."
        isSellingInTown = false
        isReturningToTown = false
        returnToTownTicksRemaining = 0
        statRollHistory.removeAll()
        actAttackBonus = 0
        actDefenseBonus = 0
        captureBaseStatsFromCurrentCharacter()

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

    func rollCharacterName() {
        character.name = EpicCharacterNames.randomName()
    }

    func increaseGameSpeed() {
        guard let next = SpeedTuning.allowedMultipliers.first(where: { $0 > gameSpeedMultiplier }) else {
            setGameSpeedMultiplier(SpeedTuning.maxMultiplier)
            return
        }
        setGameSpeedMultiplier(next)
    }

    func decreaseGameSpeed() {
        guard let previous = SpeedTuning.allowedMultipliers.reversed().first(where: { $0 < gameSpeedMultiplier }) else {
            setGameSpeedMultiplier(SpeedTuning.minMultiplier)
            return
        }
        setGameSpeedMultiplier(previous)
    }

    func resetGameSpeedToDefault() {
        setGameSpeedMultiplier(SpeedTuning.defaultMultiplier)
    }

    func startAdventure() {
        phase = .adventuring
        level = 1
        honorLevel = 0
        honorMilestonesEarned = 0
        arenaRating = 1000
        gold = 0
        hpMax = 10
        currentHP = 10
        mpMax = 5
        currentMP = Double(mpMax)
        experience = 0
        experienceToNextLevel = BalanceTuning.startingExperienceToNextLevel

        currentActNumber = 0
        completedActs.removeAll()
        questsCompletedInCurrentAct = 0
        questsPerAct = questsRequiredForCurrentAct()
        battlesUntilNextArena = BalanceTuning.arenaBattleInterval
        isArenaActive = false
        arenaRound = 0
        arenaRoundsTotal = 0
        arenaWins = 0
        arenaLosses = 0

        completedQuestNames.removeAll()
        startNewQuest(isPrologue: true)

        equipment.removeAll()
        inventory.removeAll()
        inventoryLoad = 0
        inventoryCapacity = 10
        knownSpells.removeAll()

        isSellingInTown = false
        isReturningToTown = false
        returnToTownTicksRemaining = 0
        battleProgress = 0
        logLine = "Starting Prologue."
        statRollHistory.removeAll()

        resetActBonuses()
        captureBaseStatsFromCurrentCharacter()
        seedInitialEquipment()
        saveCurrentGame()
    }

    func runTimerStep() {
        let burstTicks = tickBurstCount()
        for index in 0..<burstTicks {
            let shouldSave = index == burstTicks - 1
            tick(shouldSave: shouldSave)
            if phase != .adventuring {
                break
            }
        }
    }

    func tick(shouldSave: Bool = true) {
        guard phase == .adventuring else { return }

        regenerateMP()

        if isReturningToTown {
            returnToTownTicksRemaining = max(0, returnToTownTicksRemaining - 1)
            if returnToTownTicksRemaining == 0 {
                isReturningToTown = false
                isSellingInTown = true
                healToFullInTown()
                logLine = "Reached town. Rested and started selling loot..."
            } else {
                logLine = "Returning to town..."
            }
            if shouldSave {
                saveCurrentGame()
            }
            return
        }

        if isSellingInTown {
            sellStep()
            if shouldSave {
                saveCurrentGame()
            }
            return
        }

        castBestSpellIfPossible()
        battleProgress += battleTickStep
        if battleProgress < BalanceTuning.battleProgressTarget {
            if shouldSave {
                saveCurrentGame()
            }
            return
        }

        battleProgress = 0
        resolveBattle()

        if currentHP <= 1 {
            var retreatReason = "Critically wounded. Retreating to town..."
            if isArenaActive {
                let arenaLossSummary = forfeitArenaRun()
                if !arenaLossSummary.isEmpty {
                    retreatReason += " \(arenaLossSummary)"
                }
            }
            startReturningToTown(reason: retreatReason, travelTicks: 1)
        } else if !isArenaActive && inventoryProgress >= 1 {
            startReturningToTown(reason: "Backpack full. Returning to town...", travelTicks: 8)
        }

        if shouldSave {
            saveCurrentGame()
        }
    }

    func captureBaseStatsFromCurrentCharacter() {
        baseStr = character.str
        baseCon = character.con
        baseDex = character.dex
        baseInt = character.int
        baseWis = character.wis
        baseCha = character.cha
    }

    func ensureBaseStatsInitialized() {
        guard baseStr == 0 && baseCon == 0 && baseDex == 0 && baseInt == 0 && baseWis == 0 && baseCha == 0 else {
            return
        }

        captureBaseStatsFromCurrentCharacter()
    }

    func statDisplay(current: Int, base: Int) -> String {
        let delta = current - base
        let sign = delta >= 0 ? "+" : ""
        return "\(current)\t[\(sign)\(delta)]"
    }

    func clampedProgress(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    func tickIntervalMilliseconds() -> Int {
        SpeedTuning.baseTickMilliseconds
    }

    func tickBurstCount() -> Int {
        let safeSpeed = max(SpeedTuning.minMultiplier, min(SpeedTuning.maxMultiplier, gameSpeedMultiplier))
        return max(1, Int(safeSpeed.rounded()))
    }

    func setGameSpeedMultiplier(_ value: Double) {
        let clamped = max(SpeedTuning.minMultiplier, min(SpeedTuning.maxMultiplier, value))
        let rounded = SpeedTuning.allowedMultipliers.min(by: { abs($0 - clamped) < abs($1 - clamped) }) ?? SpeedTuning.defaultMultiplier
        gameSpeedMultiplier = rounded
        logLine = String(format: "Developer speed set to x%.0f", rounded)
    }

    func startReturningToTown(reason: String, travelTicks: Int) {
        guard !isReturningToTown && !isSellingInTown else { return }
        isReturningToTown = true
        returnToTownTicksRemaining = max(1, travelTicks)
        isSellingInTown = false
        logLine = reason
    }

    func healToFullInTown() {
        currentHP = Double(hpMax)
    }

    var strDisplay: String { statDisplay(current: character.str, base: baseStr) }
    var conDisplay: String { statDisplay(current: character.con, base: baseCon) }
    var dexDisplay: String { statDisplay(current: character.dex, base: baseDex) }
    var intDisplay: String { statDisplay(current: character.int, base: baseInt) }
    var wisDisplay: String { statDisplay(current: character.wis, base: baseWis) }
    var chaDisplay: String { statDisplay(current: character.cha, base: baseCha) }
}
