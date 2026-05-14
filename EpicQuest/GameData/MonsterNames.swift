import Foundation

enum MonsterNames {
    private static let weakBaseSeeds = [
        "Goblin", "Imp", "Ash Spider", "Ruin Hound", "Frost Gnoll"
    ]
    private static let commonBaseSeeds = [
        "Orc", "Ghoul", "Bone Stalker", "Bog Reaver", "Blight Harpy", "Mud Elemental"
    ]
    private static let eliteBaseSeeds = [
        "Wyrm", "Vampire", "Troll", "Swamp Horror", "Cave Manticore", "Basement Ogre"
    ]
    private static let apexBaseSeeds = [
        "Lich", "Dragon", "Dread Wyrm", "Ancient Tyrant"
    ]

    private static let adjectiveSeeds: [String] = [
        "Confused", "Suspiciously Moist", "Underpaid", "Crooked", "Noisy", "Unlicensed", "Flamboyant", "Overcaffeinated",
        "Questionable", "Belligerent", "Sleep-Deprived", "Unreasonably Polite", "Tax-Evading", "Existential", "Cranky",
        "Ancient", "Vicious", "Gloomy", "Starved", "Howling"
    ]

    private static let baseQualifiers: [String] = [
        "Alpha", "Brute", "Marauder", "Stalker", "Ravager", "Raider", "Sentinel", "Behemoth", "Reaver", "Tyrant"
    ]

    private static let adjectiveQualifiers: [String] = [
        "Feral", "Grim", "Wild", "Dire", "Savage", "Twisted", "Raging", "Dread", "Scarred", "Hollow"
    ]

    private static let weakKeywords = ["Goblin", "Imp", "Ash Spider", "Ruin Hound"]
    private static let eliteKeywords = ["Troll", "Vampire", "Wyrm", "Cave Manticore", "Basement Ogre"]
    private static let apexKeywords = ["Lich", "Dragon"]
    private static let eliteQualifierKeywords = ["Tyrant", "Behemoth", "Ravager", "Reaver"]

    static let baseNames: [String] = expanded(
        seeds: weakBaseSeeds + commonBaseSeeds + eliteBaseSeeds + apexBaseSeeds,
        qualifiers: baseQualifiers,
        target: 120
    )
    static let goliardicAdjectives: [String] = expanded(seeds: adjectiveSeeds, qualifiers: adjectiveQualifiers, target: 100)

    static func randomName() -> String {
        randomName(for: .common)
    }

    static func randomName(for type: MonsterType) -> String {
        let adjective = goliardicAdjectives.randomElement() ?? "Odd"
        let base = baseNamePool(for: type).randomElement() ?? "Goblin"
        return "\(adjective) \(base)"
    }

    static func lootQualityBias(for monsterType: MonsterType, isActBossBattle: Bool) -> Int {
        let baseBias: Int
        switch monsterType {
        case .weak:
            baseBias = -2
        case .common:
            baseBias = 0
        case .elite:
            baseBias = 2
        case .apex:
            baseBias = 4
        }

        return isActBossBattle ? baseBias + 2 : baseBias
    }

    static func difficultyLevelOffset(for type: MonsterType) -> Int {
        switch type {
        case .weak:
            return -1
        case .common:
            return 0
        case .elite:
            return 1
        case .apex:
            return 2
        }
    }

    static func difficultyPowerBonus(for type: MonsterType) -> Int {
        switch type {
        case .weak:
            return -4
        case .common:
            return 0
        case .elite:
            return 6
        case .apex:
            return 12
        }
    }

    static func legacyType(for monsterName: String) -> MonsterType {
        if containsAnyKeyword(monsterName, keywords: apexKeywords) {
            return .apex
        }
        if containsAnyKeyword(monsterName, keywords: eliteKeywords) || containsAnyKeyword(monsterName, keywords: eliteQualifierKeywords) {
            return .elite
        }
        if containsAnyKeyword(monsterName, keywords: weakKeywords) {
            return .weak
        }
        return .common
    }

    private static func expanded(seeds: [String], qualifiers: [String], target: Int) -> [String] {
        var out = seeds
        guard !seeds.isEmpty, !qualifiers.isEmpty else { return seeds }

        var i = 0
        while out.count < target {
            let seed = seeds[i % seeds.count]
            let qualifier = qualifiers[(i / seeds.count) % qualifiers.count]
            let candidate = "\(qualifier) \(seed)"
            if !out.contains(candidate) {
                out.append(candidate)
            }
            i += 1
        }

        return Array(out.prefix(target))
    }

    private static func baseNamePool(for type: MonsterType) -> [String] {
        switch type {
        case .weak:
            return weakBaseSeeds
        case .common:
            return commonBaseSeeds
        case .elite:
            return eliteBaseSeeds
        case .apex:
            return apexBaseSeeds
        }
    }

    private static func containsAnyKeyword(_ value: String, keywords: [String]) -> Bool {
        for keyword in keywords where value.contains(keyword) {
            return true
        }
        return false
    }
}
