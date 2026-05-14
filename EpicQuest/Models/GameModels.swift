import Foundation

enum ClassArchetype {
    case warrior
    case magic
}

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

    static func classArchetype(for className: String) -> ClassArchetype {
        let magicClasses: Set<String> = [
            "Voodoo Princess", "Robot Monk", "Mu-Fu Monk", "Mage Illusioner",
            "Inner Mason", "Runeloremaster", "Tickle-Mimic", "Slow Poisoner"
        ]
        return magicClasses.contains(className) ? .magic : .warrior
    }

    static func classLabel(for className: String) -> String {
        switch classArchetype(for: className) {
        case .warrior:
            return "[W] \(className)"
        case .magic:
            return "[M] \(className)"
        }
    }
}

enum GamePhase: String, Codable {
    case characterCreation
    case adventuring
}

enum MonsterType: String, Codable, CaseIterable {
    case weak
    case common
    case elite
    case apex
}

enum EquipmentSlot: String, CaseIterable, Codable {
    case weapon = "Weapon"
    case shield = "Shield"
    case helm = "Helm"
    case hauberk = "Hauberk"
    case brassairts = "Brassairts"
    case vambraces = "Vambraces"
    case gauntlets = "Gauntlets"
    case gambeson = "Gambeson"
    case cuisses = "Cuisses"
    case greaves = "Greaves"
    case solerets = "Solerets"

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
    var name = EpicCharacterNames.randomName()
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

struct SpellEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    var level: Int

    init(id: UUID = UUID(), name: String, level: Int = 1) {
        self.id = id
        self.name = name
        self.level = max(1, level)
    }
}

struct GameSnapshot: Codable {
    let phase: GamePhase
    let character: CharacterData
    let level: Int
    let gold: Int
    let hpMax: Int
    let currentHP: Double
    let mpMax: Int
    let currentMP: Double
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
    let currentMonsterType: MonsterType
    let battleProgress: Double
    let equipment: [EquipmentSlot: LootItem]
    let inventory: [LootItem]
    let inventoryCapacity: Double
    let inventoryLoad: Double
    let knownSpells: [SpellEntry]
    let logLine: String
    let isSellingInTown: Bool
    let isReturningToTown: Bool
    let returnToTownTicksRemaining: Int
    let baseStr: Int
    let baseCon: Int
    let baseDex: Int
    let baseInt: Int
    let baseWis: Int
    let baseCha: Int
    let actAttackBonus: Int
    let actDefenseBonus: Int

    enum CodingKeys: String, CodingKey {
        case phase, character, level, gold, hpMax, currentHP, mpMax, currentMP
        case experience, experienceToNextLevel
        case currentActNumber, completedActs, questsCompletedInCurrentAct, questsPerAct
        case completedQuestNames, currentQuest, battlesPerQuest, completedBattlesInQuest
        case currentMonster, currentMonsterType, battleProgress
        case equipment, inventory, inventoryCapacity, inventoryLoad
        case knownSpells, logLine, isSellingInTown, isReturningToTown, returnToTownTicksRemaining
        case baseStr, baseCon, baseDex, baseInt, baseWis, baseCha
        case actAttackBonus, actDefenseBonus
    }

    init(
        phase: GamePhase,
        character: CharacterData,
        level: Int,
        gold: Int,
        hpMax: Int,
        currentHP: Double,
        mpMax: Int,
        currentMP: Double,
        experience: Int,
        experienceToNextLevel: Int,
        currentActNumber: Int,
        completedActs: [String],
        questsCompletedInCurrentAct: Int,
        questsPerAct: Int,
        completedQuestNames: [String],
        currentQuest: String,
        battlesPerQuest: Int,
        completedBattlesInQuest: Int,
        currentMonster: String,
        currentMonsterType: MonsterType,
        battleProgress: Double,
        equipment: [EquipmentSlot: LootItem],
        inventory: [LootItem],
        inventoryCapacity: Double,
        inventoryLoad: Double,
        knownSpells: [SpellEntry],
        logLine: String,
        isSellingInTown: Bool,
        isReturningToTown: Bool,
        returnToTownTicksRemaining: Int,
        baseStr: Int,
        baseCon: Int,
        baseDex: Int,
        baseInt: Int,
        baseWis: Int,
        baseCha: Int,
        actAttackBonus: Int,
        actDefenseBonus: Int
    ) {
        self.phase = phase
        self.character = character
        self.level = level
        self.gold = gold
        self.hpMax = hpMax
        self.currentHP = currentHP
        self.mpMax = mpMax
        self.currentMP = currentMP
        self.experience = experience
        self.experienceToNextLevel = experienceToNextLevel
        self.currentActNumber = currentActNumber
        self.completedActs = completedActs
        self.questsCompletedInCurrentAct = questsCompletedInCurrentAct
        self.questsPerAct = questsPerAct
        self.completedQuestNames = completedQuestNames
        self.currentQuest = currentQuest
        self.battlesPerQuest = battlesPerQuest
        self.completedBattlesInQuest = completedBattlesInQuest
        self.currentMonster = currentMonster
        self.currentMonsterType = currentMonsterType
        self.battleProgress = battleProgress
        self.equipment = equipment
        self.inventory = inventory
        self.inventoryCapacity = inventoryCapacity
        self.inventoryLoad = inventoryLoad
        self.knownSpells = knownSpells
        self.logLine = logLine
        self.isSellingInTown = isSellingInTown
        self.isReturningToTown = isReturningToTown
        self.returnToTownTicksRemaining = returnToTownTicksRemaining
        self.baseStr = baseStr
        self.baseCon = baseCon
        self.baseDex = baseDex
        self.baseInt = baseInt
        self.baseWis = baseWis
        self.baseCha = baseCha
        self.actAttackBonus = actAttackBonus
        self.actDefenseBonus = actDefenseBonus
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        phase = try c.decode(GamePhase.self, forKey: .phase)
        character = try c.decode(CharacterData.self, forKey: .character)
        level = try c.decode(Int.self, forKey: .level)
        gold = try c.decode(Int.self, forKey: .gold)
        hpMax = try c.decode(Int.self, forKey: .hpMax)
        currentHP = try c.decodeIfPresent(Double.self, forKey: .currentHP) ?? Double(hpMax)
        mpMax = try c.decode(Int.self, forKey: .mpMax)
        currentMP = try c.decode(Double.self, forKey: .currentMP)
        experience = try c.decode(Int.self, forKey: .experience)
        experienceToNextLevel = try c.decode(Int.self, forKey: .experienceToNextLevel)
        currentActNumber = try c.decode(Int.self, forKey: .currentActNumber)
        completedActs = try c.decode([String].self, forKey: .completedActs)
        questsCompletedInCurrentAct = try c.decode(Int.self, forKey: .questsCompletedInCurrentAct)
        questsPerAct = try c.decode(Int.self, forKey: .questsPerAct)
        completedQuestNames = try c.decode([String].self, forKey: .completedQuestNames)
        currentQuest = try c.decode(String.self, forKey: .currentQuest)
        battlesPerQuest = try c.decode(Int.self, forKey: .battlesPerQuest)
        completedBattlesInQuest = try c.decode(Int.self, forKey: .completedBattlesInQuest)
        currentMonster = try c.decode(String.self, forKey: .currentMonster)
        currentMonsterType = try c.decodeIfPresent(MonsterType.self, forKey: .currentMonsterType)
            ?? MonsterNames.legacyType(for: currentMonster)
        battleProgress = try c.decode(Double.self, forKey: .battleProgress)
        equipment = try c.decode([EquipmentSlot: LootItem].self, forKey: .equipment)
        inventory = try c.decode([LootItem].self, forKey: .inventory)
        inventoryCapacity = try c.decode(Double.self, forKey: .inventoryCapacity)
        inventoryLoad = try c.decode(Double.self, forKey: .inventoryLoad)
        knownSpells = try c.decode([SpellEntry].self, forKey: .knownSpells)
        logLine = try c.decode(String.self, forKey: .logLine)
        isSellingInTown = try c.decode(Bool.self, forKey: .isSellingInTown)
        isReturningToTown = try c.decode(Bool.self, forKey: .isReturningToTown)
        returnToTownTicksRemaining = try c.decode(Int.self, forKey: .returnToTownTicksRemaining)

        baseStr = try c.decodeIfPresent(Int.self, forKey: .baseStr) ?? character.str
        baseCon = try c.decodeIfPresent(Int.self, forKey: .baseCon) ?? character.con
        baseDex = try c.decodeIfPresent(Int.self, forKey: .baseDex) ?? character.dex
        baseInt = try c.decodeIfPresent(Int.self, forKey: .baseInt) ?? character.int
        baseWis = try c.decodeIfPresent(Int.self, forKey: .baseWis) ?? character.wis
        baseCha = try c.decodeIfPresent(Int.self, forKey: .baseCha) ?? character.cha

        actAttackBonus = try c.decode(Int.self, forKey: .actAttackBonus)
        actDefenseBonus = try c.decode(Int.self, forKey: .actDefenseBonus)
    }
}
