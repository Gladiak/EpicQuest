import Foundation

extension GameState {
    func snapshot() -> GameSnapshot {
        GameSnapshot(
            phase: phase,
            character: character,
            level: level,
            gold: gold,
            hpMax: hpMax,
            mpMax: mpMax,
            currentMP: currentMP,
            experience: experience,
            experienceToNextLevel: experienceToNextLevel,
            currentActNumber: currentActNumber,
            completedActs: completedActs,
            questsCompletedInCurrentAct: questsCompletedInCurrentAct,
            questsPerAct: questsPerAct,
            completedQuestNames: completedQuestNames,
            currentQuest: currentQuest,
            battlesPerQuest: battlesPerQuest,
            completedBattlesInQuest: completedBattlesInQuest,
            currentMonster: currentMonster,
            battleProgress: battleProgress,
            equipment: equipment,
            inventory: inventory,
            inventoryCapacity: inventoryCapacity,
            inventoryLoad: inventoryLoad,
            knownSpells: knownSpells,
            logLine: logLine,
            isSellingInTown: isSellingInTown,
            actAttackBonus: actAttackBonus,
            actDefenseBonus: actDefenseBonus
        )
    }

    func apply(snapshot: GameSnapshot) {
        phase = snapshot.phase
        character = snapshot.character
        level = snapshot.level
        gold = snapshot.gold
        hpMax = snapshot.hpMax
        mpMax = snapshot.mpMax
        currentMP = min(Double(snapshot.mpMax), max(0, snapshot.currentMP))
        experience = snapshot.experience
        experienceToNextLevel = snapshot.experienceToNextLevel
        currentActNumber = snapshot.currentActNumber
        completedActs = snapshot.completedActs
        questsCompletedInCurrentAct = snapshot.questsCompletedInCurrentAct
        questsPerAct = snapshot.questsPerAct
        completedQuestNames = snapshot.completedQuestNames
        currentQuest = snapshot.currentQuest
        battlesPerQuest = snapshot.battlesPerQuest
        completedBattlesInQuest = snapshot.completedBattlesInQuest
        currentMonster = snapshot.currentMonster
        battleProgress = snapshot.battleProgress
        equipment = snapshot.equipment
        inventory = snapshot.inventory
        inventoryCapacity = snapshot.inventoryCapacity
        inventoryLoad = snapshot.inventoryLoad
        knownSpells = snapshot.knownSpells
        logLine = snapshot.logLine
        isSellingInTown = snapshot.isSellingInTown
        actAttackBonus = snapshot.actAttackBonus
        actDefenseBonus = snapshot.actDefenseBonus
    }

    func saveCurrentGame() {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(snapshot()) else { return }

        let url = saveURL()
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }

    func loadSnapshot() -> GameSnapshot? {
        let url = saveURL()
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(GameSnapshot.self, from: data)
    }

    func deleteSave() {
        try? FileManager.default.removeItem(at: saveURL())
    }

    func saveURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return appSupport
            .appendingPathComponent("EpicQuest", isDirectory: true)
            .appendingPathComponent("savegame.json")
    }
}
