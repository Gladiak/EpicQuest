import Foundation

enum QuestNames {
    private static let verbs: [String] = [
        "Seek", "Escort", "Cleanse", "Recover", "Break", "Silence", "Map", "Deliver", "Defeat", "Seal",
        "Hunt", "Reforge", "Protect", "Unmask", "Conquer", "Banish", "Awaken", "Guard", "Raid", "Rescue"
    ]

    private static let objects: [String] = [
        "the Cruciate Spangle", "the Nameless Merchant", "the Mystic Swamp", "the Ivory Sigil", "the Siege of Sable Ford",
        "the Bell of Hollow Glass", "the Catacombs of Grief", "the Moonlit Writ", "the Baron of Rust", "the Weeping Gate",
        "the Ashen Leviathan", "the Crown of Briars", "the Obsidian Archive", "the Fallen Astrarium", "the Last Ember Chapel",
        "the Verdant Maw", "the Chain of Tides", "the Silent Spire", "the Black Orchard", "the Crimson Vault"
    ]

    static let all: [String] = buildAll(target: 100)

    private static func buildAll(target: Int) -> [String] {
        var out: [String] = []
        for verb in verbs {
            for object in objects {
                out.append("\(verb) \(object)")
                if out.count == target { return out }
            }
        }
        return Array(out.prefix(target))
    }
}
