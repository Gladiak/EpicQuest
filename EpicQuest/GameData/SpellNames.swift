import Foundation

enum SpellNames {
    private static let prefixes: [String] = [
        "Arc", "Frost", "Ember", "Static", "Venom", "Stone", "Gale", "Moonlit", "Bone", "Thorn",
        "Aether", "Cinder", "Iron", "Grim", "Sable", "Storm", "Rift", "Ash", "Mirror", "Dawn"
    ]

    private static let cores: [String] = [
        "Spark", "Needle", "Lash", "Bloom", "Drip", "Tongue", "Cut", "Hex", "Lantern", "Burst",
        "Pin", "Psalm", "Prayer", "Waltz", "Beacon", "Rune", "Nail", "Orbit", "Fang", "Fracture"
    ]

    static let all: [String] = buildAll(target: 100)

    private static func buildAll(target: Int) -> [String] {
        var out: [String] = []
        for prefix in prefixes {
            for core in cores {
                out.append("\(prefix) \(core)")
                if out.count == target { return out }
            }
        }
        return Array(out.prefix(target))
    }
}
