import Foundation

extension GameState {
    func resolveBattle() {
        let monsterLevel = max(1, level + Int.random(in: -1...2))
        currentMonster = MonsterNames.randomName()

        let gainedXP = 4 + monsterLevel * 3
        let gainedGold = 2 + monsterLevel * 2
        experience += gainedXP
        gold += gainedGold

        if Int.random(in: 0...100) < 70 {
            let loot = generateLoot(for: monsterLevel)
            autoEquipOrStore(loot)
        }

        levelUpIfNeeded()

        completedBattlesInQuest += 1
        if completedBattlesInQuest >= battlesPerQuest {
            completeCurrentQuest()
        }

        logLine = "Executing \(currentMonster)..."
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

            hpMax += Int.random(in: 2...5)
            mpMax += Int.random(in: 1...3)
            inventoryCapacity += 0.6
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
