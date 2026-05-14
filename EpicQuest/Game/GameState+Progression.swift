import Foundation

extension GameState {
    func resolveBattle() {
        let monsterLevel = max(1, level + Int.random(in: -1...2))
        currentMonster = MonsterNames.randomName()
        let wasActBossBattle = isActBossBattle()

        let gainedXP = 4 + monsterLevel * 3
        let gainedGold = 2 + monsterLevel * 2
        experience += gainedXP
        gold += gainedGold

        if Int.random(in: 0...100) < 70 {
            let loot = generateLoot(for: monsterLevel)
            autoEquipOrStore(loot)
        }

        var spellDropMessage = ""
        if wasActBossBattle, let message = tryDropBossSpellScroll() {
            spellDropMessage = " \(message)"
        }

        levelUpIfNeeded()

        completedBattlesInQuest += 1
        if completedBattlesInQuest >= battlesPerQuest {
            completeCurrentQuest()
        }

        logLine = "Executing \(currentMonster)...\(spellDropMessage)"
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
        currentMonster = MonsterNames.randomName()
        battlesPerQuest = isPrologue ? 2 : battlesRequiredForCurrentLevel()
        completedBattlesInQuest = 0
    }

    func levelUpIfNeeded() {
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            level += 1

            let growthFactor = 1.16 + (Double(level) * 0.006)
            experienceToNextLevel = Int((Double(experienceToNextLevel) * growthFactor).rounded()) + 6

            applyDeterministicGrowthForCurrentLevel()
            inventoryCapacity += 0.35
        }
    }

    func questsRequiredForCurrentAct() -> Int {
        if currentActNumber == 0 { return 1 }
        let base = 4
        let levelContribution = max(0, (level - 1) / 4)
        let actContribution = max(0, currentActNumber / 3)
        return min(18, base + levelContribution + actContribution)
    }

    func battlesRequiredForCurrentLevel() -> Int {
        let base = 3
        let levelContribution = max(0, (level - 1) / 3)
        return min(14, base + levelContribution)
    }

    func randomQualityModifier(forAct actNumber: Int) -> Int {
        let minQuality = min(20, -10 + actNumber * 2)
        let maxQuality = min(24, -8 + actNumber * 3)
        return Int.random(in: minQuality...max(minQuality, maxQuality))
    }

    func qualityLabel(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }

    func shouldApplyMythicSuffix(quality: Int) -> Bool {
        let baseChance = max(2, min(25, 3 + currentActNumber * 2 + max(0, quality / 2)))
        return Int.random(in: 1...100) <= baseChance
    }

    func resetActBonuses() {
        actAttackBonus = 0
        actDefenseBonus = 0
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

        if level % (archetype == .warrior ? 3 : 6) == 0 {
            hpGain += 1
        }
        if level % (archetype == .magic ? 3 : 6) == 0 {
            mpGain += 1
        }

        hpMax += hpGain
        mpMax += mpGain
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
        character[keyPath: keyPath] = min(20, current + 1)
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

    func regenerateMP() {
        let regenPerTick = 0.18 + (Double(level) * 0.01)
        currentMP = min(Double(mpMax), currentMP + regenPerTick)
    }

    func castBestSpellIfPossible() {
        guard !knownSpells.isEmpty else { return }
        guard Int.random(in: 1...100) <= 40 else { return }

        let castable = knownSpells
            .filter { currentMP >= Double(spellManaCost(for: $0)) }
            .sorted { spellPower(for: $0) > spellPower(for: $1) }

        guard let spell = castable.first else { return }

        let manaCost = spellManaCost(for: spell)
        currentMP = max(0, currentMP - Double(manaCost))
        battleProgress += spellBattleImpact(for: spell)
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
        let impact = Double(spellPower(for: spell)) * 0.007
        return min(0.55, max(0.06, impact))
    }

    func tryDropBossSpellScroll() -> String? {
        let dropRate = bossSpellDropChancePercent()
        guard Int.random(in: 1...100) <= dropRate else { return nil }

        let spellName = SpellNames.all.randomElement() ?? "Arc Spark"
        return learnSpellFromScroll(named: spellName)
    }

    func bossSpellDropChancePercent() -> Int {
        let actBoost = currentActNumber * 4
        let levelBoost = max(0, level - 1) / 2
        return min(68, 1 + actBoost + levelBoost)
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
