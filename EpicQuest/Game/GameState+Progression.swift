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
}

extension GameState {
    func resolveBattle() {
        let defeatedMonster = currentMonster
        let defeatedMonsterType = currentMonsterType
        let wasActBossBattle = isActBossBattle()
        let monsterLevel = currentEncounterMonsterLevel(
            monsterType: defeatedMonsterType,
            isBossBattle: wasActBossBattle
        )

        let gainedXP = BalanceTuning.baseXPPerBattle + monsterLevel * BalanceTuning.xpPerMonsterLevel
        let gainedGold = BalanceTuning.baseGoldPerBattle + monsterLevel * BalanceTuning.goldPerMonsterLevel
        experience += gainedXP
        gold += gainedGold

        let incomingDamage = computeIncomingDamage(monsterLevel: monsterLevel, isBossBattle: wasActBossBattle)
        currentHP = max(1, currentHP - Double(incomingDamage))

        let lootBias = MonsterNames.lootQualityBias(for: defeatedMonsterType, isActBossBattle: wasActBossBattle)
        let loot = generateLoot(for: monsterLevel, qualityBias: lootBias)
        autoEquipOrStore(loot)

        var spellDropMessage = ""
        if wasActBossBattle, let message = tryDropBossSpellScroll() {
            spellDropMessage = " \(message)"
        }

        levelUpIfNeeded()

        completedBattlesInQuest += 1
        if completedBattlesInQuest >= battlesPerQuest {
            completeCurrentQuest()
        } else {
            prepareNextEncounterMonster()
        }

        let hpSuffix = " Took \(incomingDamage) dmg. HP \(currentHPInt)/\(hpMax)."
        logLine = "Executing \(defeatedMonster)...\(spellDropMessage)\(hpSuffix)"
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
        guard currentActNumber > 0 else { return false }
        let isLastBattleOfQuest = completedBattlesInQuest + 1 >= battlesPerQuest
        let isLastQuestOfAct = questsCompletedInCurrentAct + 1 >= questsPerAct
        return isLastBattleOfQuest && isLastQuestOfAct
    }

    func prepareNextEncounterMonster() {
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
        let regenPerTick = BalanceTuning.mpRegenBasePerTick + (Double(level) * BalanceTuning.mpRegenPerLevel)
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
        let impact = Double(spellPower(for: spell)) * BalanceTuning.spellImpactScale
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
        return min(BalanceTuning.bossSpellDropCap, BalanceTuning.bossSpellDropBase + actBoost + levelBoost)
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
