import Foundation

enum BalanceTuning {
    static let startingExperienceToNextLevel = 50

    static let baseBattleTickStep = 0.042
    static let battleProgressTarget = 1.6
    static let attackStepScale = 0.00022
    static let maxAttackStepBonus = 0.022
    static let defenseStepScale = 0.0001
    static let maxDefenseStepBonus = 0.012
    static let spellStepScale = 0.0011
    static let maxSpellStepBonus = 0.06

    static let baseXPPerBattle = 4
    static let xpPerMonsterLevel = 2
    static let baseGoldPerBattle = 1
    static let goldPerMonsterLevel = 1
    static let arenaXPBonusBase = 4
    static let arenaXPBonusPerRound = 2
    static let arenaGoldBonusBase = 3
    static let arenaGoldBonusPerRound = 2
    static let arenaLootQualityBonus = 3
    static let arenaMonsterLevelBonus = 4
    static let arenaMonsterLevelBonusPerRound = 2
    static let arenaIncomingDamageLevelBonus = 1
    static let arenaBaseRating = 1000
    static let arenaMinRating = 600
    static let arenaMaxRating = 2600
    static let arenaRatingLevelDivisor = 120
    static let arenaRatingRoundDivisor = 420
    static let arenaRatingKFactor = 28
    static let arenaBattleInterval = 6
    static let arenaBaseRounds = 3
    static let arenaRoundActDivisor = 3
    static let arenaRoundCap = 4
    static let honorPerTier = 24
    static let maxHonorTier = 5
    static let honorGainArenaRound = 1
    static let honorGainArenaClear = 4
    static let honorLossArenaForfeit = 5
    static let honorMilestoneStep = 20

    static let experienceGrowthBase = 1.17
    static let experienceGrowthLevelScale = 0.005
    static let experienceGrowthCap = 0.12
    static let experienceGrowthFlatGain = 9

    static let baseQuestsPerAct = 5
    static let questLevelDivisor = 4
    static let questActDivisor = 3
    static let maxQuestsPerAct = 20

    static let baseBattlesPerQuest = 4
    static let battleLevelDivisor = 3
    static let maxBattlesPerQuest = 16

    static let prologueBattlesPerQuest = 3

    static let bossSpellDropBase = 2
    static let bossSpellDropActScale = 4
    static let bossSpellDropLevelDivisor = 3
    static let bossSpellDropCap = 55

    static let incomingDamageBase = 2
    static let incomingDamagePerMonsterLevel = 2
    static let incomingDamageRandomMax = 4
    static let defenseMitigationDivisor = 6
    static let bossDamageBonus = 3
    static let incomingDamageRandomMin = -2
    static let monsterPowerPerLevel = 5
    static let bossPowerBonus = 10
    static let playerPowerLevelScale = 2
    static let highDefenseBlockDivisor = 3
    static let maxBlockChance = 55
    static let underpoweredGapDivisor = 5
    static let overpoweredGapDivisor = 7
    static let maxUnderpoweredBonusDamage = 8
    static let maxOverpoweredDamageReduction = 5

    static let constitutionHPGrowthChancePerPoint = 2
    static let minConstitutionHPGrowthChance = 10
    static let maxConstitutionHPGrowthChance = 60
    static let intelligenceMPGrowthChancePerPoint = 2
    static let minIntelligenceMPGrowthChance = 12
    static let maxIntelligenceMPGrowthChance = 65
    static let magicHPGainInterval = 2
    static let hpFloorConDivisor = 2
    static let mpFloorIntDivisor = 2

    static let mythicMinAct = 3
    static let mythicMinQuality = 8
    static let mythicQuestFinisherChance = 1
    static let mythicActBossChance = 4

    static let mpRegenBasePerTick = 0.11
    static let mpRegenPerLevel = 0.006
    static let spellCastChancePercent = 22
    static let minSpellCastChance = 3
    static let maxSpellCastChance = 68
    static let spellCastChanceProgressBonus = 10
    static let bossSpellCastChanceBonus = 10
    static let lowDifficultySpellThreshold = -8
    static let highDifficultySpellThreshold = 10
    static let highManaSpendThreshold = 0.92
    static let bossEncounterLevelBonus = 2
    static let spellImpactScale = 0.0045
    static let maxSpellImpact = 0.28

    static let townProjectBaseRequired = 120
    static let townProjectRequiredGrowth = 1.42
    static let townProjectRequiredFlatGain = 25
    static let townProjectBudgetShare = 0.32
    static let townProjectMinimumInvestment = 30
    static let townProjectForgeMerchantQualityPerLevel = 1
    static let townProjectForgeMerchantQualityCap = 12
    static let townProjectForgeMerchantPowerPerTwoLevels = 2
    static let townProjectForgeMerchantPowerCap = 6
    static let townProjectArcaneRegenPerLevel = 0.02
    static let townProjectArcaneRegenCap = 0.3
    static let townProjectArcaneDropChancePerLevel = 1
    static let townProjectArcaneDropChanceCap = 15
    static let townProjectCaravanCapacityPerLevel = 0.4
    static let townProjectCaravanCapacityCap = 22.0
    static let townProjectCaravanTravelTickReductionPerTwoLevels = 2
    static let townProjectCaravanTravelTickReductionCap = 4
    static let townProjectWallsMitigationPerLevel = 1
    static let townProjectWallsMitigationCap = 8
}

enum ArenaModifier: String, CaseIterable {
    case bloodsportContract
    case arcaneDrought
    case ironWard
    case executionersCrowd
    case suddenDeath
    case cursedTempo

    var shortName: String {
        switch self {
        case .bloodsportContract:
            return "Bloodsport"
        case .arcaneDrought:
            return "Arcane Drought"
        case .ironWard:
            return "Iron Ward"
        case .executionersCrowd:
            return "Executioner's Crowd"
        case .suddenDeath:
            return "Sudden Death"
        case .cursedTempo:
            return "Cursed Tempo"
        }
    }

    var monsterLevelBonus: Int {
        switch self {
        case .bloodsportContract: return 2
        case .arcaneDrought: return 1
        case .ironWard: return 1
        case .executionersCrowd: return 2
        case .suddenDeath: return 3
        case .cursedTempo: return 1
        }
    }

    var incomingDamageLevelBonus: Int {
        switch self {
        case .bloodsportContract: return 1
        case .arcaneDrought: return 1
        case .ironWard: return 1
        case .executionersCrowd: return 2
        case .suddenDeath: return 3
        case .cursedTempo: return 1
        }
    }

    var battleStepMultiplier: Double {
        switch self {
        case .bloodsportContract: return 0.92
        case .arcaneDrought: return 0.9
        case .ironWard: return 0.8
        case .executionersCrowd: return 0.86
        case .suddenDeath: return 0.82
        case .cursedTempo: return 0.88
        }
    }

    var mpRegenMultiplier: Double {
        switch self {
        case .bloodsportContract: return 0.9
        case .arcaneDrought: return 0.42
        case .ironWard: return 0.78
        case .executionersCrowd: return 0.8
        case .suddenDeath: return 0.65
        case .cursedTempo: return 0.58
        }
    }

    var spellCastChanceDelta: Int {
        switch self {
        case .bloodsportContract: return -4
        case .arcaneDrought: return -18
        case .ironWard: return -10
        case .executionersCrowd: return -8
        case .suddenDeath: return -12
        case .cursedTempo: return -14
        }
    }

    var spellImpactMultiplier: Double {
        switch self {
        case .bloodsportContract: return 0.95
        case .arcaneDrought: return 0.74
        case .ironWard: return 0.9
        case .executionersCrowd: return 0.88
        case .suddenDeath: return 0.82
        case .cursedTempo: return 0.86
        }
    }

    var rewardMultiplier: Double {
        switch self {
        case .bloodsportContract: return 1.2
        case .arcaneDrought: return 1.24
        case .ironWard: return 1.28
        case .executionersCrowd: return 1.34
        case .suddenDeath: return 1.42
        case .cursedTempo: return 1.3
        }
    }

    var lootQualityBonus: Int {
        switch self {
        case .bloodsportContract: return 1
        case .arcaneDrought: return 2
        case .ironWard: return 2
        case .executionersCrowd: return 3
        case .suddenDeath: return 4
        case .cursedTempo: return 2
        }
    }

    var roundHonorBonus: Int {
        switch self {
        case .bloodsportContract: return 0
        case .arcaneDrought: return 1
        case .ironWard: return 1
        case .executionersCrowd: return 1
        case .suddenDeath: return 2
        case .cursedTempo: return 1
        }
    }

    var clearHonorBonus: Int {
        switch self {
        case .bloodsportContract: return 1
        case .arcaneDrought: return 1
        case .ironWard: return 1
        case .executionersCrowd: return 2
        case .suddenDeath: return 2
        case .cursedTempo: return 2
        }
    }

    var ratingWinBonus: Int {
        switch self {
        case .bloodsportContract: return 1
        case .arcaneDrought: return 1
        case .ironWard: return 2
        case .executionersCrowd: return 3
        case .suddenDeath: return 4
        case .cursedTempo: return 2
        }
    }

    var ratingLossPenalty: Int {
        switch self {
        case .bloodsportContract: return -1
        case .arcaneDrought: return -1
        case .ironWard: return -2
        case .executionersCrowd: return -2
        case .suddenDeath: return -4
        case .cursedTempo: return -2
        }
    }
}

extension GameState {
    func resolveBattle() {
        let defeatedMonster = currentMonster
        let defeatedMonsterType = currentMonsterType
        let wasArenaBattle = isArenaActive
        let completedArenaRound = arenaRound
        let completedArenaTotal = arenaRoundsTotal
        let wasActBossBattle = !wasArenaBattle && isActBossBattle()
        let isArenaFinalRound = wasArenaBattle && completedArenaRound >= completedArenaTotal && completedArenaTotal > 0

        var monsterLevel = currentEncounterMonsterLevel(
            monsterType: defeatedMonsterType,
            isBossBattle: wasActBossBattle || isArenaFinalRound
        )
        if wasArenaBattle {
            let ratingLevelBonus = max(0, (arenaRating - BalanceTuning.arenaBaseRating) / BalanceTuning.arenaRatingLevelDivisor)
            monsterLevel += BalanceTuning.arenaMonsterLevelBonus
                + (max(0, completedArenaRound - 1) * BalanceTuning.arenaMonsterLevelBonusPerRound)
                + ratingLevelBonus
                + arenaModifierMonsterLevelBonus()
        }

        var gainedXP = BalanceTuning.baseXPPerBattle + monsterLevel * BalanceTuning.xpPerMonsterLevel
        var gainedGold = BalanceTuning.baseGoldPerBattle + monsterLevel * BalanceTuning.goldPerMonsterLevel
        if wasArenaBattle {
            gainedXP += BalanceTuning.arenaXPBonusBase + completedArenaRound * BalanceTuning.arenaXPBonusPerRound
            gainedGold += BalanceTuning.arenaGoldBonusBase + completedArenaRound * BalanceTuning.arenaGoldBonusPerRound
            let rewardMultiplier = arenaModifierRewardMultiplier()
            gainedXP = Int((Double(gainedXP) * rewardMultiplier).rounded())
            gainedGold = Int((Double(gainedGold) * rewardMultiplier).rounded())
        }
        experience += gainedXP
        gold += gainedGold

        let incomingDamageLevel = wasArenaBattle
            ? monsterLevel
                + BalanceTuning.arenaIncomingDamageLevelBonus
                + max(0, completedArenaRound - 1)
                + arenaModifierIncomingDamageLevelBonus()
            : monsterLevel
        let incomingDamage = computeIncomingDamage(
            monsterLevel: incomingDamageLevel,
            isBossBattle: wasActBossBattle || isArenaFinalRound
        )
        currentHP = max(1, currentHP - Double(incomingDamage))

        var lootBias = MonsterNames.lootQualityBias(for: defeatedMonsterType, isActBossBattle: wasActBossBattle)
        if wasArenaBattle {
            lootBias += BalanceTuning.arenaLootQualityBonus + completedArenaRound
            lootBias += arenaModifierLootQualityBonus()
        }
        let loot = generateLoot(for: monsterLevel, qualityBias: lootBias)
        autoEquipOrStore(loot)

        var spellDropMessage = ""
        if wasActBossBattle, let message = tryDropBossSpellScroll() {
            spellDropMessage = " \(message)"
        }

        levelUpIfNeeded()

        var encounterSummary = ""
        if wasArenaBattle {
            encounterSummary = resolveArenaAfterVictory(monsterLevel: monsterLevel)
        } else {
            resolveQuestProgressAfterBattle()
            startArenaRunIfReady()
        }

        let hpSuffix = " Took \(incomingDamage) dmg. HP \(currentHPInt)/\(hpMax)."
        let arenaSuffix: String
        if wasArenaBattle, completedArenaTotal > 0 {
            arenaSuffix = " [Arena \(romanNumeral(max(1, completedArenaRound)))/\(romanNumeral(max(1, completedArenaTotal)))]"
        } else {
            arenaSuffix = ""
        }
        logLine = "Executing \(defeatedMonster)\(arenaSuffix)...\(spellDropMessage)\(encounterSummary)\(hpSuffix)"
    }

    func resolveQuestProgressAfterBattle() {
        completedBattlesInQuest += 1
        if completedBattlesInQuest >= battlesPerQuest {
            completeCurrentQuest()
        } else {
            prepareNextEncounterMonster()
        }
        updateArenaCadenceAfterRegularBattle()
    }

    func updateArenaCadenceAfterRegularBattle() {
        guard currentActNumber > 0 else { return }
        guard !isArenaActive else { return }

        battlesUntilNextArena = max(0, battlesUntilNextArena - 1)
    }

    func startArenaRunIfReady() {
        guard currentActNumber > 0 else { return }
        guard !isArenaActive else { return }
        guard battlesUntilNextArena == 0 else { return }

        isArenaActive = true
        arenaRound = 1
        arenaRoundsTotal = arenaRoundsForCurrentState()
        battlesUntilNextArena = BalanceTuning.arenaBattleInterval
        let rules = arenaModifiersDisplay
        if rules != "-" {
            logLine = "Arena rules: \(rules)."
        }
        prepareNextEncounterMonster()
    }

    func arenaRoundsForCurrentState() -> Int {
        let actBonus = max(0, currentActNumber - 1) / BalanceTuning.arenaRoundActDivisor
        let honorBonus = max(0, honorTier() / 2)
        let leagueBonus = arenaLeague.progressionBonus / 3
        let ratingBonus = max(0, arenaRating - BalanceTuning.arenaBaseRating) / BalanceTuning.arenaRatingRoundDivisor
        let total = BalanceTuning.arenaBaseRounds + actBonus + honorBonus + leagueBonus + ratingBonus
        return min(BalanceTuning.arenaRoundCap, max(1, total))
    }

    var arenaModifiersDisplay: String {
        let modifiers = arenaModifiersForCurrentRun()
        guard !modifiers.isEmpty else { return "-" }
        return modifiers.map(\.shortName).joined(separator: " + ")
    }

    func arenaModifiersForCurrentRun() -> [ArenaModifier] {
        guard isArenaActive, arenaRoundsTotal > 0 else { return [] }
        let all = ArenaModifier.allCases
        guard !all.isEmpty else { return [] }

        let seed = arenaRunSeed()
        let primaryIndex = Int(seed % UInt64(all.count))
        var selected: [ArenaModifier] = [all[primaryIndex]]

        let canRollSecond = currentActNumber >= 2 || arenaLeague.progressionBonus >= 2 || arenaRoundsTotal >= 4
        if canRollSecond {
            let chance = min(
                72,
                18
                    + currentActNumber * 4
                    + arenaLeague.progressionBonus * 8
                    + max(0, arenaRoundsTotal - 2) * 7
            )
            let roll = Int((seed >> 11) % 100)
            if roll < chance, all.count > 1 {
                let nextOffset = 1 + Int((seed >> 17) % UInt64(all.count - 1))
                let secondaryIndex = (primaryIndex + nextOffset) % all.count
                selected.append(all[secondaryIndex])
            }
        }

        return selected
    }

    func arenaRunSeed() -> UInt64 {
        let seedSource = [
            "\(currentActNumber)",
            "\(arenaRoundsTotal)",
            "\(arenaWins)",
            "\(arenaLosses)",
            "\(arenaRating)",
            "\(questsCompletedInCurrentAct)"
        ].joined(separator: "|")
        return stableSeed(from: seedSource)
    }

    func arenaModifierMonsterLevelBonus() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.monsterLevelBonus }
    }

    func arenaModifierIncomingDamageLevelBonus() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.incomingDamageLevelBonus }
    }

    func arenaModifierBattleStepMultiplier() -> Double {
        let multiplier = arenaModifiersForCurrentRun().reduce(1.0) { $0 * $1.battleStepMultiplier }
        return max(0.55, min(1.0, multiplier))
    }

    func arenaModifierMPRegenMultiplier() -> Double {
        let multiplier = arenaModifiersForCurrentRun().reduce(1.0) { $0 * $1.mpRegenMultiplier }
        return max(0.35, min(1.0, multiplier))
    }

    func arenaModifierSpellCastChanceDelta() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.spellCastChanceDelta }
    }

    func arenaModifierSpellImpactMultiplier() -> Double {
        let multiplier = arenaModifiersForCurrentRun().reduce(1.0) { $0 * $1.spellImpactMultiplier }
        return max(0.6, min(1.0, multiplier))
    }

    func arenaModifierRewardMultiplier() -> Double {
        let multiplier = arenaModifiersForCurrentRun().reduce(1.0) { $0 * $1.rewardMultiplier }
        return max(1.0, min(2.2, multiplier))
    }

    func arenaModifierLootQualityBonus() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.lootQualityBonus }
    }

    func arenaModifierRoundHonorBonus() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.roundHonorBonus }
    }

    func arenaModifierClearHonorBonus() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.clearHonorBonus }
    }

    func arenaModifierRatingWinBonus() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.ratingWinBonus }
    }

    func arenaModifierRatingLossPenalty() -> Int {
        arenaModifiersForCurrentRun().reduce(0) { $0 + $1.ratingLossPenalty }
    }

    func resolveArenaAfterVictory(monsterLevel: Int) -> String {
        guard isArenaActive else { return "" }

        let roundGain = updateHonor(by: BalanceTuning.honorGainArenaRound + arenaModifierRoundHonorBonus())
        if arenaRound >= arenaRoundsTotal {
            let clearGain = updateHonor(
                by: BalanceTuning.honorGainArenaClear
                    + max(0, currentActNumber / 3)
                    + arenaModifierClearHonorBonus()
            )
            arenaWins += 1
            let opponentRating = arenaOpponentRating(forRound: arenaRound, totalRounds: arenaRoundsTotal, monsterType: currentMonsterType)
            let ratingDelta = updateArenaRating(
                by: arenaRatingDelta(didWin: true, opponentRating: opponentRating) + arenaModifierRatingWinBonus()
            )
            let reward = applyArenaClearRewards(monsterLevel: monsterLevel)
            finishArenaRun()
            let totalHonorGain = max(0, roundGain) + max(0, clearGain)
            return " Arena cleared. Honor +\(totalHonorGain). Rating +\(max(0, ratingDelta)). Reward: \(reward.name)."
        }

        arenaRound += 1
        prepareNextEncounterMonster()
        return " Arena round cleared. Honor +\(max(0, roundGain))."
    }

    func applyArenaClearRewards(monsterLevel: Int) -> LootItem {
        let minimumQuality = max(
            0,
            honorTier() + (currentActNumber / 2) + arenaLeague.progressionBonus + arenaModifierLootQualityBonus()
        )
        let qualityBias = BalanceTuning.arenaLootQualityBonus
            + honorTier()
            + arenaLeague.progressionBonus
            + arenaModifierLootQualityBonus()
        let reward = generateLoot(
            for: monsterLevel + 1 + honorTier(),
            minimumQuality: minimumQuality,
            qualityBias: qualityBias
        )
        autoEquipOrStore(reward)
        return reward
    }

    func forfeitArenaRun() -> String {
        guard isArenaActive else { return "" }
        let lostHonor = abs(min(0, updateHonor(by: -BalanceTuning.honorLossArenaForfeit)))
        arenaLosses += 1
        let opponentRating = arenaOpponentRating(
            forRound: max(1, arenaRound),
            totalRounds: max(1, arenaRoundsTotal),
            monsterType: arenaEncounterMonsterType()
        )
        let ratingDelta = updateArenaRating(
            by: arenaRatingDelta(didWin: false, opponentRating: opponentRating) + arenaModifierRatingLossPenalty()
        )
        finishArenaRun()
        return "Arena run failed. Honor -\(lostHonor). Rating \(ratingDelta)."
    }

    func finishArenaRun() {
        isArenaActive = false
        arenaRound = 0
        arenaRoundsTotal = 0
        battlesUntilNextArena = max(1, battlesUntilNextArena)
        prepareNextEncounterMonster()
    }

    func arenaEncounterMonsterType() -> MonsterType {
        guard arenaRoundsTotal > 0 else { return .elite }
        if arenaRound >= arenaRoundsTotal { return .apex }
        if arenaRound + 1 >= arenaRoundsTotal { return .apex }
        return .elite
    }

    func honorTier() -> Int {
        min(BalanceTuning.maxHonorTier, max(0, honorLevel / BalanceTuning.honorPerTier))
    }

    func merchantHonorTier() -> Int {
        honorTier()
    }

    func arenaOpponentRating(forRound round: Int, totalRounds: Int, monsterType: MonsterType) -> Int {
        let tierBonus: Int
        switch monsterType {
        case .weak:
            tierBonus = -40
        case .common:
            tierBonus = 0
        case .elite:
            tierBonus = 30
        case .apex:
            tierBonus = 70
        }

        let rating = BalanceTuning.arenaBaseRating
            + currentActNumber * 35
            + max(0, level - 1) * 3
            + max(1, round) * 24
            + max(1, totalRounds) * 18
            + arenaLeague.progressionBonus * 8
            + tierBonus
        return max(BalanceTuning.arenaMinRating, rating)
    }

    func arenaRatingDelta(didWin: Bool, opponentRating: Int) -> Int {
        let expected = 1.0 / (1.0 + pow(10.0, Double(opponentRating - arenaRating) / 400.0))
        let outcome = didWin ? 1.0 : 0.0
        var delta = Int((Double(BalanceTuning.arenaRatingKFactor) * (outcome - expected)).rounded())

        if didWin {
            delta = max(8, delta)
        } else {
            delta = min(-6, delta)
        }

        return delta
    }

    @discardableResult
    func updateArenaRating(by delta: Int) -> Int {
        guard delta != 0 else { return 0 }
        let previous = arenaRating
        arenaRating = min(BalanceTuning.arenaMaxRating, max(BalanceTuning.arenaMinRating, arenaRating + delta))
        return arenaRating - previous
    }

    @discardableResult
    func updateHonor(by amount: Int) -> Int {
        guard amount != 0 else { return 0 }

        let previous = honorLevel
        honorLevel = max(0, honorLevel + amount)
        let appliedDelta = honorLevel - previous

        if appliedDelta > 0 {
            synchronizeHonorMilestonesWithCurrentHonor()
        }

        return appliedDelta
    }

    func synchronizeHonorMilestonesWithCurrentHonor() {
        let targetMilestones = max(0, honorLevel / BalanceTuning.honorMilestoneStep)
        while honorMilestonesEarned < targetMilestones {
            honorMilestonesEarned += 1
            grantHonorMilestoneGrowth(at: honorMilestonesEarned)
        }
    }

    func grantHonorMilestoneGrowth(at milestone: Int) {
        let statPaths: [WritableKeyPath<CharacterData, Int>] = [\.str, \.con, \.dex, \.int, \.wis, \.cha]
        let index = deterministicInt(level: milestone, salt: 709, seed: growthSeed(), modulo: statPaths.count)
        let keyPath = statPaths[index]

        character[keyPath: keyPath] += 1

        if keyPath == \CharacterData.con {
            hpMax += 1
            currentHP = min(Double(hpMax), currentHP + 1)
        }

        if keyPath == \CharacterData.int {
            mpMax += 1
            currentMP = min(Double(mpMax), currentMP + 1)
        }
    }

    func sanitizeArenaStateAfterLoad() {
        battlesUntilNextArena = max(1, battlesUntilNextArena)

        guard phase == .adventuring, currentActNumber > 0 else {
            isArenaActive = false
            arenaRound = 0
            arenaRoundsTotal = 0
            return
        }

        guard isArenaActive else {
            arenaRound = 0
            arenaRoundsTotal = 0
            return
        }

        if arenaRoundsTotal <= 0 {
            arenaRoundsTotal = arenaRoundsForCurrentState()
        }
        arenaRound = min(max(1, arenaRound), arenaRoundsTotal)
        prepareNextEncounterMonster()
    }

    func completeCurrentQuest() {
        completedQuestNames.append(currentQuest)
        questsCompletedInCurrentAct += 1

        if currentActNumber == 0 {
            completedActs.append("Prologue")
            currentActNumber = 1
            questsCompletedInCurrentAct = 0
            questsPerAct = questsRequiredForCurrentAct()
            resetActBonuses()
            logLine = "Prologue completed. Entering Act I."
            startNewQuest()
            return
        }

        if questsCompletedInCurrentAct >= questsPerAct {
            completedActs.append(currentActLabel)
            currentActNumber += 1
            questsCompletedInCurrentAct = 0
            questsPerAct = questsRequiredForCurrentAct()
            resetActBonuses()
            logLine = "Entering \(currentActLabel)."
        }

        startNewQuest()
    }

    func startNewQuest(isPrologue: Bool = false) {
        currentQuest = isPrologue ? "Prepare your gear" : (QuestNames.all.randomElement() ?? "Unknown Quest")
        battlesPerQuest = isPrologue ? BalanceTuning.prologueBattlesPerQuest : battlesRequiredForCurrentLevel()
        completedBattlesInQuest = 0
        prepareNextEncounterMonster()
    }

    func levelUpIfNeeded() {
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            level += 1

            let growthFactor = BalanceTuning.experienceGrowthBase
                + min(BalanceTuning.experienceGrowthCap, Double(level) * BalanceTuning.experienceGrowthLevelScale)
            experienceToNextLevel = Int((Double(experienceToNextLevel) * growthFactor).rounded()) + BalanceTuning.experienceGrowthFlatGain

            applyDeterministicGrowthForCurrentLevel()
            inventoryCapacity += 0.35
        }
    }

    func questsRequiredForCurrentAct() -> Int {
        if currentActNumber == 0 { return 1 }
        let levelContribution = max(0, (level - 1) / BalanceTuning.questLevelDivisor)
        let actContribution = max(0, currentActNumber / BalanceTuning.questActDivisor)
        return min(BalanceTuning.maxQuestsPerAct, BalanceTuning.baseQuestsPerAct + levelContribution + actContribution)
    }

    func battlesRequiredForCurrentLevel() -> Int {
        let levelContribution = max(0, (level - 1) / BalanceTuning.battleLevelDivisor)
        return min(BalanceTuning.maxBattlesPerQuest, BalanceTuning.baseBattlesPerQuest + levelContribution)
    }

    func randomQualityModifier(forAct actNumber: Int) -> Int {
        let isQuestFinisher = completedBattlesInQuest + 1 >= battlesPerQuest
        let isActBoss = isActBossBattle()
        let levelContribution = max(0, (level - 1) / 10)

        var minQuality = -12 + (actNumber / 2) + (levelContribution / 2)
        var maxQuality = -10 + (actNumber / 2) + levelContribution

        if isQuestFinisher {
            maxQuality += 1
        }
        if isActBoss {
            maxQuality += 2
        }

        minQuality = min(8, max(-12, minQuality))
        maxQuality = min(14, max(-8, maxQuality))
        return Int.random(in: minQuality...max(minQuality, maxQuality))
    }

    func qualityLabel(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }

    func shouldApplyMythicSuffix(quality: Int) -> Bool {
        guard currentActNumber >= BalanceTuning.mythicMinAct else { return false }
        guard quality >= BalanceTuning.mythicMinQuality else { return false }

        let isQuestFinisher = completedBattlesInQuest + 1 >= battlesPerQuest
        guard isQuestFinisher else { return false }

        let chance = isActBossBattle()
            ? BalanceTuning.mythicActBossChance
            : BalanceTuning.mythicQuestFinisherChance
        return Int.random(in: 1...100) <= chance
    }

    func resetActBonuses() {
        rebuildCombatBonusesFromEquipment()
    }

    func applyDeterministicGrowthForCurrentLevel() {
        let archetype = GameData.classArchetype(for: character.characterClass)
        let seed = growthSeed()

        let hpBase = archetype == .warrior ? 1 : 0
        let mpBase = archetype == .magic ? 1 : 0

        var hpGain = hpBase
        var mpGain = mpBase

        if deterministicPercent(level: level, salt: 11, seed: seed) < raceHPBonusPercent(seed: seed) {
            hpGain += 1
        }
        if deterministicPercent(level: level, salt: 17, seed: seed) < raceMPBonusPercent(seed: seed) {
            mpGain += 1
        }
        let constitutionRollChance = max(
            BalanceTuning.minConstitutionHPGrowthChance,
            min(BalanceTuning.maxConstitutionHPGrowthChance, character.con * BalanceTuning.constitutionHPGrowthChancePerPoint)
        )
        if deterministicPercent(level: level, salt: 53, seed: seed) < constitutionRollChance {
            hpGain += 1
        }
        let intelligenceRollChance = max(
            BalanceTuning.minIntelligenceMPGrowthChance,
            min(BalanceTuning.maxIntelligenceMPGrowthChance, character.int * BalanceTuning.intelligenceMPGrowthChancePerPoint)
        )
        if deterministicPercent(level: level, salt: 59, seed: seed) < intelligenceRollChance {
            mpGain += 1
        }

        if level % (archetype == .warrior ? 3 : 6) == 0 {
            hpGain += 1
        }
        if level % (archetype == .magic ? 3 : 6) == 0 {
            mpGain += 1
        }
        if archetype == .magic, level % BalanceTuning.magicHPGainInterval == 0 {
            hpGain += 1
        }

        hpMax += hpGain
        mpMax += mpGain
        currentHP = min(Double(hpMax), currentHP + Double(hpGain))
        currentMP = min(Double(mpMax), currentMP + Double(mpGain))

        applyStatGrowth(archetype: archetype, seed: seed)
    }

    func applyStatGrowth(archetype: ClassArchetype, seed: UInt64) {
        let physicalStats: [WritableKeyPath<CharacterData, Int>] = [\.str, \.con, \.dex]
        let mysticalStats: [WritableKeyPath<CharacterData, Int>] = [\.int, \.wis, \.cha]

        let focused = archetype == .warrior ? physicalStats : mysticalStats
        let support = archetype == .warrior ? mysticalStats : physicalStats

        if level % 2 == 0 {
            growOneStat(from: focused, level: level, salt: 31, seed: seed)
        }

        if level % 4 == 0 && deterministicPercent(level: level, salt: 37, seed: seed) < 34 {
            growOneStat(from: focused, level: level, salt: 41, seed: seed)
        }

        if level % 6 == 0 && deterministicPercent(level: level, salt: 43, seed: seed) < 24 {
            growOneStat(from: support, level: level, salt: 47, seed: seed)
        }
    }

    func growOneStat(from keyPaths: [WritableKeyPath<CharacterData, Int>], level: Int, salt: Int, seed: UInt64) {
        guard !keyPaths.isEmpty else { return }

        let index = deterministicInt(level: level, salt: salt, seed: seed, modulo: keyPaths.count)
        let keyPath = keyPaths[index]
        let current = character[keyPath: keyPath]
        let updated = current + 1
        character[keyPath: keyPath] = updated

        // Secondary progression link: higher CON -> more HP, higher INT -> more MP.
        if keyPath == \CharacterData.con {
            hpMax += 1
            currentHP = min(Double(hpMax), currentHP + 1)
        }

        if keyPath == \CharacterData.int {
            mpMax += 1
            currentMP = min(Double(mpMax), currentMP + 1)
        }
    }

    func growthSeed() -> UInt64 {
        stableSeed(from: "\(character.race)|\(character.characterClass)")
    }

    func raceHPBonusPercent(seed: UInt64) -> Int {
        8 + Int((seed >> 2) % 10)
    }

    func raceMPBonusPercent(seed: UInt64) -> Int {
        8 + Int((seed >> 8) % 10)
    }

    func deterministicPercent(level: Int, salt: Int, seed: UInt64) -> Int {
        deterministicInt(level: level, salt: salt, seed: seed, modulo: 100)
    }

    func deterministicInt(level: Int, salt: Int, seed: UInt64, modulo: Int) -> Int {
        let value = seed
            &+ UInt64(level &* 1_103)
            &+ UInt64(salt &* 7_919)
            &+ 0x9E3779B97F4A7C15
        return Int(value % UInt64(max(1, modulo)))
    }

    func stableSeed(from text: String) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return hash
    }

    func isActBossBattle() -> Bool {
        guard !isArenaActive else { return false }
        guard currentActNumber > 0 else { return false }
        let isLastBattleOfQuest = completedBattlesInQuest + 1 >= battlesPerQuest
        let isLastQuestOfAct = questsCompletedInCurrentAct + 1 >= questsPerAct
        return isLastBattleOfQuest && isLastQuestOfAct
    }

    func prepareNextEncounterMonster() {
        if isArenaActive {
            currentMonsterType = arenaEncounterMonsterType()
            let baseArenaName = MonsterNames.randomName(for: currentMonsterType)
            currentMonster = "Arena \(romanNumeral(max(1, arenaRound))): \(baseArenaName)"
            return
        }

        let bossEncounter = isActBossBattle()
        currentMonsterType = determineMonsterTypeForNextEncounter(isActBossBattle: bossEncounter)
        currentMonster = MonsterNames.randomName(for: currentMonsterType)
    }

    func determineMonsterTypeForNextEncounter(isActBossBattle: Bool) -> MonsterType {
        let progression = currentActNumber + max(0, (level - 1) / 6)
        let roll = deterministicEncounterPercent(salt: isActBossBattle ? 131 : 127)

        if isActBossBattle {
            let apexChance = min(80, 35 + progression * 5)
            return roll < apexChance ? .apex : .elite
        }

        let weakChance = max(8, 38 - progression * 4)
        let eliteChance = min(38, 10 + progression * 3)
        let apexChance = min(18, max(0, progression - 2) * 2)
        let commonChance = max(0, 100 - weakChance - eliteChance - apexChance)

        if roll < weakChance {
            return .weak
        }
        if roll < weakChance + commonChance {
            return .common
        }
        if roll < weakChance + commonChance + eliteChance {
            return .elite
        }
        return .apex
    }

    func deterministicEncounterPercent(salt: Int) -> Int {
        let encounterIndex = currentActNumber * 10_000
            + questsCompletedInCurrentAct * 200
            + completedBattlesInQuest * 7
            + completedQuestNames.count
        let rollLevel = level + encounterIndex
        return deterministicInt(level: rollLevel, salt: salt, seed: growthSeed(), modulo: 100)
    }

    func currentEncounterMonsterLevel(monsterType: MonsterType, isBossBattle: Bool) -> Int {
        let variance = deterministicInt(
            level: level + currentActNumber + completedBattlesInQuest,
            salt: isBossBattle ? 173 : 167,
            seed: growthSeed(),
            modulo: 3
        ) - 1

        let baseLevel = level + MonsterNames.difficultyLevelOffset(for: monsterType)
        let bossBonus = isBossBattle ? BalanceTuning.bossEncounterLevelBonus : 0
        return max(1, baseLevel + bossBonus + variance)
    }

    func regenerateMP() {
        let arcaneMultiplier = 1.0 + townProjectArcaneRegenBonusRatio()
        let baseRegen = (BalanceTuning.mpRegenBasePerTick + (Double(level) * BalanceTuning.mpRegenPerLevel)) * arcaneMultiplier
        let regenPerTick = isArenaActive ? baseRegen * arenaModifierMPRegenMultiplier() : baseRegen
        currentMP = min(Double(mpMax), currentMP + regenPerTick)
    }

    func castBestSpellIfPossible() {
        guard !knownSpells.isEmpty else { return }
        let isBossBattle = isActBossBattle()
        let difficultyScore = encounterDifficultyScore(isBossBattle: isBossBattle)
        let castChance = dynamicSpellCastChance(difficultyScore: difficultyScore, isBossBattle: isBossBattle)
        guard Int.random(in: 1...100) <= castChance else { return }

        guard let spell = selectSpellForCurrentEncounter(
            difficultyScore: difficultyScore,
            isBossBattle: isBossBattle
        ) else { return }

        let manaCost = spellManaCost(for: spell)
        currentMP = max(0, currentMP - Double(manaCost))
        battleProgress += spellBattleImpact(for: spell)
    }

    func dynamicSpellCastChance(difficultyScore: Int, isBossBattle: Bool) -> Int {
        var chance = BalanceTuning.spellCastChancePercent

        if difficultyScore >= 20 {
            chance += 20
        } else if difficultyScore >= 10 {
            chance += 12
        } else if difficultyScore >= 4 {
            chance += 6
        } else if difficultyScore <= -16 {
            chance -= 14
        } else if difficultyScore <= -8 {
            chance -= 8
        }

        chance += Int(battleProgressValue * Double(BalanceTuning.spellCastChanceProgressBonus))
        if isBossBattle {
            chance += BalanceTuning.bossSpellCastChanceBonus
        }
        if isArenaActive {
            chance += arenaModifierSpellCastChanceDelta()
        }

        return min(BalanceTuning.maxSpellCastChance, max(BalanceTuning.minSpellCastChance, chance))
    }

    func selectSpellForCurrentEncounter(difficultyScore: Int, isBossBattle: Bool) -> SpellEntry? {
        let castableNow = knownSpells.filter { currentMP >= Double(spellManaCost(for: $0)) }
        guard !castableNow.isEmpty else { return nil }

        let highestKnownCost = knownSpells.map { spellManaCost(for: $0) }.max() ?? 0
        let manaReserve = desiredSpellManaReserve(
            highestKnownCost: highestKnownCost,
            difficultyScore: difficultyScore,
            isBossBattle: isBossBattle
        )
        let spendableMana = currentMP - Double(manaReserve)

        var preferredPool = castableNow.filter { Double(spellManaCost(for: $0)) <= spendableMana }
        if preferredPool.isEmpty {
            let manaRatio = currentMP / Double(max(mpMax, 1))
            if isBossBattle || difficultyScore >= BalanceTuning.highDifficultySpellThreshold || manaRatio >= BalanceTuning.highManaSpendThreshold {
                preferredPool = castableNow
            } else {
                return nil
            }
        }

        let ascendingByPower = preferredPool.sorted { spellPower(for: $0) < spellPower(for: $1) }
        if difficultyScore <= BalanceTuning.lowDifficultySpellThreshold, !isBossBattle {
            return ascendingByPower.first
        }

        let targetPower = targetSpellPowerForEncounter(difficultyScore: difficultyScore, isBossBattle: isBossBattle)
        if let matched = ascendingByPower.first(where: { spellPower(for: $0) >= targetPower }) {
            return matched
        }
        return ascendingByPower.last
    }

    func desiredSpellManaReserve(highestKnownCost: Int, difficultyScore: Int, isBossBattle: Bool) -> Int {
        if isBossBattle || difficultyScore >= BalanceTuning.highDifficultySpellThreshold {
            return 0
        }
        if difficultyScore >= 4 {
            return max(2, highestKnownCost / 3)
        }
        if difficultyScore >= -4 {
            return max(4, highestKnownCost / 2)
        }
        return max(6, highestKnownCost - 2)
    }

    func targetSpellPowerForEncounter(difficultyScore: Int, isBossBattle: Bool) -> Int {
        var targetPower = 10
        if difficultyScore >= 20 {
            targetPower = 36
        } else if difficultyScore >= 12 {
            targetPower = 28
        } else if difficultyScore >= 6 {
            targetPower = 22
        } else if difficultyScore >= 1 {
            targetPower = 16
        }

        if isBossBattle {
            targetPower += 6
        }

        return min(90, max(8, targetPower))
    }

    func encounterDifficultyScore(isBossBattle: Bool) -> Int {
        let estimatedMonsterLevel = currentEncounterMonsterLevel(monsterType: currentMonsterType, isBossBattle: isBossBattle)
        let monsterPower = estimatedMonsterLevel * BalanceTuning.monsterPowerPerLevel
            + encounterTierPowerBonus(for: currentMonsterType)
            + (isBossBattle ? BalanceTuning.bossPowerBonus : 0)
        let playerPower = max(1, attack + defense + level * BalanceTuning.playerPowerLevelScale)
        return monsterPower - playerPower
    }

    func encounterTierPowerBonus(for tier: MonsterType) -> Int {
        MonsterNames.difficultyPowerBonus(for: tier)
    }

    func spellManaCost(for spell: SpellEntry) -> Int {
        let baseCost = 4 + spell.level * 2
        return min(max(4, baseCost), 36)
    }

    func spellPower(for spell: SpellEntry) -> Int {
        let base = 2 + spell.level * 3
        return min(90, base + max(0, level / 3))
    }

    func spellBattleImpact(for spell: SpellEntry) -> Double {
        let arenaMultiplier = isArenaActive ? arenaModifierSpellImpactMultiplier() : 1.0
        let impact = Double(spellPower(for: spell)) * BalanceTuning.spellImpactScale * arenaMultiplier
        return min(BalanceTuning.maxSpellImpact, max(0.03, impact))
    }

    func tryDropBossSpellScroll() -> String? {
        let dropRate = bossSpellDropChancePercent()
        guard Int.random(in: 1...100) <= dropRate else { return nil }

        let spellName = SpellNames.all.randomElement() ?? "Arc Spark"
        return learnSpellFromScroll(named: spellName)
    }

    func bossSpellDropChancePercent() -> Int {
        let actBoost = currentActNumber * BalanceTuning.bossSpellDropActScale
        let levelBoost = max(0, level - 1) / BalanceTuning.bossSpellDropLevelDivisor
        let townBoost = townProjectArcaneDropChanceBonus()
        return min(BalanceTuning.bossSpellDropCap, BalanceTuning.bossSpellDropBase + actBoost + levelBoost + townBoost)
    }

    func learnSpellFromScroll(named spellName: String) -> String {
        if let index = knownSpells.firstIndex(where: { $0.name == spellName }) {
            knownSpells[index].level += 1
            return "Found ancient scroll: \(spellName) \(romanNumeral(knownSpells[index].level))."
        }

        knownSpells.append(SpellEntry(name: spellName, level: 1))
        knownSpells.sort { $0.name < $1.name }
        return "Found rare spell scroll: \(spellName) I."
    }

    func computeIncomingDamage(monsterLevel: Int, isBossBattle: Bool) -> Int {
        let base = BalanceTuning.incomingDamageBase + (monsterLevel * BalanceTuning.incomingDamagePerMonsterLevel)
        let randomBonus = Int.random(in: BalanceTuning.incomingDamageRandomMin...BalanceTuning.incomingDamageRandomMax)
        let bossBonus = isBossBattle ? BalanceTuning.bossDamageBonus : 0
        let mitigation = max(0, defense / BalanceTuning.defenseMitigationDivisor)
        let monsterPower = monsterLevel * BalanceTuning.monsterPowerPerLevel + (isBossBattle ? BalanceTuning.bossPowerBonus : 0)
        let playerPower = max(1, attack + defense + level * BalanceTuning.playerPowerLevelScale)
        let powerGap = monsterPower - playerPower

        var damage = base + randomBonus + bossBonus - mitigation

        if powerGap > 0 {
            let pressureBonus = min(
                BalanceTuning.maxUnderpoweredBonusDamage,
                (powerGap / BalanceTuning.underpoweredGapDivisor) + Int.random(in: 0...2)
            )
            damage += pressureBonus
            if powerGap >= 12 {
                damage += Int.random(in: 1...2)
            }
        } else if powerGap < 0 {
            let relief = min(
                BalanceTuning.maxOverpoweredDamageReduction,
                abs(powerGap) / BalanceTuning.overpoweredGapDivisor
            )
            damage -= relief
        }

        let defenseAdvantage = defense - (monsterLevel * 4)
        if damage <= 0 || defenseAdvantage > 0 {
            let blockChance = min(
                BalanceTuning.maxBlockChance,
                max(0, defenseAdvantage / BalanceTuning.highDefenseBlockDivisor)
            )
            if Int.random(in: 1...100) <= blockChance {
                return 0
            }
        }

        damage -= townProjectWallsDamageMitigation()
        return max(0, damage)
    }

    func rebalanceResourceMinimumsForCurrentLevel() {
        let minimumHP = minimumExpectedHPMax()
        let minimumMP = minimumExpectedMPMax()

        hpMax = max(hpMax, minimumHP)
        mpMax = max(mpMax, minimumMP)
        currentHP = min(Double(hpMax), max(1, currentHP))
        currentMP = min(Double(mpMax), max(0, currentMP))
    }

    func minimumExpectedHPMax() -> Int {
        let levelGains = max(0, level - 1)
        let archetype = GameData.classArchetype(for: character.characterClass)
        let classFloor: Int
        if archetype == .warrior {
            classFloor = levelGains + (level / 3)
        } else {
            classFloor = (level / BalanceTuning.magicHPGainInterval) + (level / 6)
        }
        let conFloor = max(0, character.con - 10) / BalanceTuning.hpFloorConDivisor
        return 10 + classFloor + conFloor
    }

    func minimumExpectedMPMax() -> Int {
        let levelGains = max(0, level - 1)
        let archetype = GameData.classArchetype(for: character.characterClass)
        let classFloor: Int
        if archetype == .magic {
            classFloor = levelGains + (level / 3) + (level / 4)
        } else {
            classFloor = level / 6
        }
        let intFloor = max(0, character.int - 10) / BalanceTuning.mpFloorIntDivisor
        return 5 + classFloor + intFloor
    }

    func romanNumeral(_ value: Int) -> String {
        let map: [(Int, String)] = [
            (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
            (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
            (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]

        var number = max(1, value)
        var result = ""

        for (base, symbol) in map {
            while number >= base {
                result += symbol
                number -= base
            }
        }

        return result
    }
}
