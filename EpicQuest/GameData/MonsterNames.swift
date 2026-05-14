import Foundation

enum MonsterNames {
    static let baseNames: [String] = [
        "Goblin", "Imp", "Orc", "Ghoul", "Wyrm", "Vampire", "Troll", "Lich", "Dragon",
        "Bone Stalker", "Swamp Horror", "Mud Elemental", "Basement Ogre", "Dust Wraith"
    ]

    static let goliardicAdjectives: [String] = [
        "Confused", "Suspiciously Moist", "Underpaid", "Crooked", "Noisy", "Unlicensed",
        "Flamboyant", "Overcaffeinated", "Questionable", "Belligerent", "Sleep-Deprived",
        "Unreasonably Polite", "Tax-Evading", "Existential", "Cranky"
    ]

    static func randomName() -> String {
        let adjective = goliardicAdjectives.randomElement() ?? "Odd"
        let base = baseNames.randomElement() ?? "Goblin"
        return "\(adjective) \(base)"
    }
}
