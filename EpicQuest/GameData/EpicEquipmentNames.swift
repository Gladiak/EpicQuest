import Foundation

enum EpicEquipmentNames {
    private static let rarePrefixSeeds: [String] = [
        "Forgotten", "Cracked", "Runed", "Bloodstained", "Dustbound", "Ashen", "Crowned", "Hollow",
        "Sunken", "Grinning", "Moonlit", "Blackened", "Silent", "Gilded", "Barbed", "Nameless"
    ]

    private static let epithetSeeds: [String] = [
        "of the Drunk Saint", "from the Ninth Cellar", "of Bad Omens", "of Three Regrets",
        "from the Last Siege", "of Crooked Destiny", "of the Seventh Bell", "of the Hollow Court",
        "of the Salt King", "from the Deep Ward", "of Grinning Teeth", "of Unpaid Debts"
    ]

    private static let weaponSeeds: [String] = [
        "Sharp Rock", "Pointy Stick", "Rusty Knife", "Bent Spear", "Blunt Axe", "Jagged Shiv", "Warpick", "Cracked Mace",
        "Hooked Cleaver", "Notched Saber", "Split Maul", "Needle Rapier", "Spite Dagger", "Gutter Pike", "Bone Flail"
    ]

    private static let shieldSeeds: [String] = [
        "Pie Plate", "Wooden Lid", "Kite Shield", "Soup Pot", "Door Plank", "Cracked Buckler", "Pan Shield", "Rivet Guard", "Tower Slab", "Oven Door"
    ]

    private static let helmSeeds: [String] = [
        "Colander", "War Cap", "Bucket Helm", "Old Pot", "Visored Helm", "Iron Kettle", "Bone Hood", "Spiked Cap", "Cage Helm", "Mail Coif"
    ]

    private static let hauberkSeeds: [String] = [
        "Burlap", "Chain Shirt", "Leather Vest", "Apron", "Scale Coat", "Laced Hauberk", "Linked Shirt", "Salt-Stiff Jerkin", "Ring Mail", "Battle Smock"
    ]

    private static let brassairtsSeeds: [String] = [
        "Patchwork", "Studded Plates", "Tin Bands", "Cord Wrap", "Brassairts", "Riveted Sleeves", "Stitched Braces", "Boiled Leather", "Bone Bands", "Sewn Splints"
    ]

    private static let vambracesSeeds: [String] = [
        "Wrist Wraps", "Bone Braces", "Riveted Bracers", "Scrap Guards", "Plate Vambraces", "Etched Vambraces", "Horn Braces", "Braided Guards", "Lamellar Cuffs", "Ashwood Bracers"
    ]

    private static let gauntletsSeeds: [String] = [
        "Work Gloves", "Iron Mitts", "Claw Grips", "Padded Gloves", "Spiked Gauntlets", "Chain Gloves", "Bone Knuckles", "Forge Gauntlets", "Scaled Mitts", "Grip Claws"
    ]

    private static let gambesonSeeds: [String] = [
        "Quilt Coat", "Padded Jacket", "Stitched Doublet", "Worn Tunic", "Layered Gambeson", "Needled Coat", "Arming Coat", "Bastion Padding", "Sealed Jerkin", "Thick Gambeson"
    ]

    private static let cuissesSeeds: [String] = [
        "Thigh Plates", "Leg Bands", "Ragged Cuisses", "Mail Straps", "Steel Cuisses", "Layered Cuisses", "Riveted Thighs", "Ringed Cuisses", "Splint Cuisses", "Leather Cuisses"
    ]

    private static let greavesSeeds: [String] = [
        "Shin Guards", "Bone Greaves", "Rust Greaves", "Tin Shins", "Iron Greaves", "Banded Greaves", "Etched Greaves", "Heavy Shins", "Lamellar Greaves", "Knight Greaves"
    ]

    private static let soleretsSeeds: [String] = [
        "Whippet Collar", "Toe Caps", "Nailed Shoes", "Bent Solerets", "Solerets", "Spur Shoes", "Iron Boots", "Steel Toes", "March Soles", "Winged Solerets"
    ]

    private static let equipmentQualifiers: [String] = [
        "Mk I", "Mk II", "Mk III", "Mk IV", "Prime", "Ascendant", "Elder", "Battleforged", "Ritual", "Warborn"
    ]

    static let rarePrefixes: [String] = expanded(seeds: rarePrefixSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let epithets: [String] = expanded(seeds: epithetSeeds, qualifiers: equipmentQualifiers, target: 100)

    static let weaponBases: [String] = expanded(seeds: weaponSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let shieldBases: [String] = expanded(seeds: shieldSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let helmBases: [String] = expanded(seeds: helmSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let hauberkBases: [String] = expanded(seeds: hauberkSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let brassairtsBases: [String] = expanded(seeds: brassairtsSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let vambracesBases: [String] = expanded(seeds: vambracesSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let gauntletsBases: [String] = expanded(seeds: gauntletsSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let gambesonBases: [String] = expanded(seeds: gambesonSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let cuissesBases: [String] = expanded(seeds: cuissesSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let greavesBases: [String] = expanded(seeds: greavesSeeds, qualifiers: equipmentQualifiers, target: 100)
    static let soleretsBases: [String] = expanded(seeds: soleretsSeeds, qualifiers: equipmentQualifiers, target: 100)

    private static func expanded(seeds: [String], qualifiers: [String], target: Int) -> [String] {
        var out = seeds
        guard !seeds.isEmpty, !qualifiers.isEmpty else { return seeds }

        var i = 0
        while out.count < target {
            let base = seeds[i % seeds.count]
            let qualifier = qualifiers[(i / seeds.count) % qualifiers.count]
            let candidate = "\(base) \(qualifier)"
            if !out.contains(candidate) {
                out.append(candidate)
            }
            i += 1
        }

        return Array(out.prefix(target))
    }
}
