import Foundation

enum GameData {
    static let races = [
        "Half Orc", "Half Man", "Half Halfling", "Double Hobbit", "Hob-Hobbit",
        "Low Elf", "Dung Elf", "Talking Pony", "Gygnome", "Lesser Dwarf",
        "Crested Dwarf", "Eel Man", "Panda Man", "Trans-Kobold", "Enchanted Motorcycle"
    ]

    static let classes = [
        "Ur-Paladin", "Voodoo Princess", "Robot Monk", "Mu-Fu Monk", "Mage Illusioner",
        "Shiv-Knight", "Inner Mason", "Fighter/Organist", "Puma Burgular", "Runeloremaster",
        "Hunter Strangler", "Battle-Felon", "Tickle-Mimic", "Slow Poisoner", "Bastard Lunatic"
    ]
}

enum GamePhase: String, Codable {
    case characterCreation
    case adventuring
}

enum EquipmentSlot: String, CaseIterable, Codable {
    case weapon = "Weapon"
    case shield = "Shield"
    case armor = "Armor"
    case helm = "Helm"
    case ring = "Ring"
    case boots = "Boots"

    var isWeaponLike: Bool {
        self == .weapon
    }
}

struct LootItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let power: Int
    let slot: EquipmentSlot
    let value: Int
    let weight: Double
    let attackBonus: Int
    let defenseBonus: Int
    let qualityModifier: Int

    init(
        id: UUID = UUID(),
        name: String,
        power: Int,
        slot: EquipmentSlot,
        value: Int,
        weight: Double,
        attackBonus: Int,
        defenseBonus: Int,
        qualityModifier: Int
    ) {
        self.id = id
        self.name = name
        self.power = power
        self.slot = slot
        self.value = value
        self.weight = weight
        self.attackBonus = attackBonus
        self.defenseBonus = defenseBonus
        self.qualityModifier = qualityModifier
    }
}

struct CharacterData: Codable {
    var name = "Uckvood"
    var race = GameData.races.first ?? "Half Orc"
    var characterClass = GameData.classes.first ?? "Ur-Paladin"
    var str = 4
    var con = 8
    var dex = 10
    var int = 9
    var wis = 10
    var cha = 11

    var totalStats: Int {
        str + con + dex + int + wis + cha
    }
}

struct ReadOnlyCheckItem: Identifiable {
    let id = UUID()
    let title: String
    let isCompleted: Bool
}

struct GameSnapshot: Codable {
    let phase: GamePhase
    let character: CharacterData
    let level: Int
    let gold: Int
    let hpMax: Int
    let mpMax: Int
    let experience: Int
    let experienceToNextLevel: Int
    let currentActNumber: Int
    let completedActs: [String]
    let questsCompletedInCurrentAct: Int
    let questsPerAct: Int
    let completedQuestNames: [String]
    let currentQuest: String
    let battlesPerQuest: Int
    let completedBattlesInQuest: Int
    let currentMonster: String
    let battleProgress: Double
    let equipment: [EquipmentSlot: LootItem]
    let inventory: [LootItem]
    let inventoryCapacity: Double
    let inventoryLoad: Double
    let logLine: String
    let isSellingInTown: Bool
    let actAttackBonus: Int
    let actDefenseBonus: Int
}
