import Foundation

enum MagicAttributes {
    private static let weaponSeeds: [String] = [
        "of Embers", "of Frostbite", "of Thunder", "of Venom", "of Echoes", "of Sundering", "of Dawn", "of Ruin",
        "of Cinders", "of Tempests", "of the Manticore", "of Hollow Stars", "of Ashen Oaths", "of Grave Salt",
        "of the Red Comet", "of Deep Howling", "of Witchfire", "of Broken Crowns", "of Blood Moons", "of Black Ice"
    ]

    private static let armorSeeds: [String] = [
        "of Warding", "of Stone", "of Mending", "of Aegis", "of Mist", "of Iron Will", "of Night", "of Sanctuary",
        "of Shells", "of Stormwall", "of Quiet Steps", "of Bastions", "of the Last Watch", "of Salt and Smoke",
        "of the Brass Choir", "of Thorns", "of Winter Fog", "of Oathglass", "of Broken Chains", "of Hidden Sigils"
    ]

    private static let epicQualifiers: [String] = [
        "Awakened", "Ancient", "Prime", "Cursed", "Blessed", "Celestial", "Infernal", "Forgotten", "Runebound", "Mythic"
    ]

    static let weapon: [String] = expanded(seeds: weaponSeeds, target: 100)
    static let armor: [String] = expanded(seeds: armorSeeds, target: 100)

    private static func expanded(seeds: [String], target: Int) -> [String] {
        var out = seeds
        guard !seeds.isEmpty else { return seeds }

        var i = 0
        while out.count < target {
            let base = seeds[i % seeds.count]
            let qualifier = epicQualifiers[(i / seeds.count) % epicQualifiers.count]
            let candidate = base + " " + qualifier
            if !out.contains(candidate) {
                out.append(candidate)
            }
            i += 1
        }

        return Array(out.prefix(target))
    }
}
