import Foundation

extension GameState {
    private enum SaveFormat {
        static let magic = "EQSV1"
        static let version: UInt8 = 1
        static let xorSalt = "EpicQuest.Save.Obfuscation.v1"
    }

    func snapshot() -> GameSnapshot {
        GameSnapshot(
            phase: phase,
            character: character,
            level: level,
            gold: gold,
            hpMax: hpMax,
            currentHP: currentHP,
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
            currentMonsterType: currentMonsterType,
            battleProgress: battleProgress,
            equipment: equipment,
            inventory: inventory,
            inventoryCapacity: inventoryCapacity,
            inventoryLoad: inventoryLoad,
            knownSpells: knownSpells,
            logLine: logLine,
            isSellingInTown: isSellingInTown,
            isReturningToTown: isReturningToTown,
            returnToTownTicksRemaining: returnToTownTicksRemaining,
            baseStr: baseStr,
            baseCon: baseCon,
            baseDex: baseDex,
            baseInt: baseInt,
            baseWis: baseWis,
            baseCha: baseCha,
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
        currentHP = min(Double(snapshot.hpMax), max(1, snapshot.currentHP))
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
        currentMonsterType = snapshot.currentMonsterType
        battleProgress = snapshot.battleProgress
        equipment = snapshot.equipment
        inventory = snapshot.inventory
        inventoryCapacity = snapshot.inventoryCapacity
        inventoryLoad = snapshot.inventoryLoad
        knownSpells = snapshot.knownSpells
        logLine = snapshot.logLine
        isSellingInTown = snapshot.isSellingInTown
        isReturningToTown = snapshot.isReturningToTown
        returnToTownTicksRemaining = max(0, snapshot.returnToTownTicksRemaining)
        baseStr = snapshot.baseStr
        baseCon = snapshot.baseCon
        baseDex = snapshot.baseDex
        baseInt = snapshot.baseInt
        baseWis = snapshot.baseWis
        baseCha = snapshot.baseCha
        actAttackBonus = snapshot.actAttackBonus
        actDefenseBonus = snapshot.actDefenseBonus
        rebuildCombatBonusesFromEquipment()
        rebalanceResourceMinimumsForCurrentLevel()
    }

    func saveCurrentGame() {
        let snapshot = snapshot()
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        guard let payload = try? encoder.encode(snapshot) else { return }

        let playerName = snapshot.character.name
        let key = obfuscationKey(for: playerName)
        let obfuscatedPayload = xorData(payload, key: key)

        guard let playerNameData = playerName.data(using: .utf8) else { return }
        let nameLength = UInt16(min(playerNameData.count, Int(UInt16.max)))
        let payloadLength = UInt32(min(obfuscatedPayload.count, Int(UInt32.max)))

        var fileData = Data()
        fileData.append(contentsOf: SaveFormat.magic.utf8)
        fileData.append(SaveFormat.version)
        appendUInt16(nameLength, to: &fileData)
        fileData.append(playerNameData.prefix(Int(nameLength)))
        appendUInt32(payloadLength, to: &fileData)
        fileData.append(obfuscatedPayload.prefix(Int(payloadLength)))

        let checksum = checksum64(payload)
        appendUInt64(checksum, to: &fileData)

        let url = saveURL(for: playerName)
        let directory = url.deletingLastPathComponent()

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileData.write(to: url, options: .atomic)
            lastSaveFilePath = url.path
        } catch {
            // Keep silent in release flow, but make path observability explicit for tests.
            lastSaveFilePath = "SAVE_FAILED: \(url.path)"
        }
    }

    func loadSnapshot() -> GameSnapshot? {
        for url in candidateSaveURLs() {
            guard let fileData = try? Data(contentsOf: url) else { continue }
            guard let decoded = decodeSnapshot(from: fileData) else { continue }
            return decoded
        }

        return nil
    }

    func deleteSave() {
        try? FileManager.default.removeItem(at: saveURL(for: character.name))
    }

    func saveDirectoryURL() -> URL {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())

        return appSupport
            .appendingPathComponent("EpicQuest", isDirectory: true)
            .appendingPathComponent("Saves", isDirectory: true)
    }

    func saveURL(for playerName: String) -> URL {
        let safeName = sanitizeFileName(playerName)
        return saveDirectoryURL().appendingPathComponent("\(safeName).eq")
    }

    func sanitizeFileName(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? "UnknownHero" : trimmed
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))

        let mapped = base.unicodeScalars.map { scalar -> Character in
            allowed.contains(scalar) ? Character(scalar) : "_"
        }

        let value = String(mapped)
        return value.isEmpty ? "UnknownHero" : value
    }

    func candidateSaveURLs() -> [URL] {
        var urls: [URL] = []
        let currentPlayerURL = saveURL(for: character.name)
        urls.append(currentPlayerURL)

        let all = allSaveFilesSortedByDate()
        for url in all where url != currentPlayerURL {
            urls.append(url)
        }

        return urls
    }

    func allSaveFilesSortedByDate() -> [URL] {
        let dir = saveDirectoryURL()
        let files = (try? FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        return files
            .filter { $0.pathExtension.lowercased() == "eq" }
            .sorted { lhs, rhs in
                let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                return lhsDate > rhsDate
            }
    }

    func decodeSnapshot(from fileData: Data) -> GameSnapshot? {
        var offset = 0

        guard let magic = readString(from: fileData, offset: &offset, length: SaveFormat.magic.count),
              magic == SaveFormat.magic else {
            return nil
        }

        guard let version = readByte(from: fileData, offset: &offset), version == SaveFormat.version else {
            return nil
        }

        guard let nameLength = readUInt16(from: fileData, offset: &offset),
              let playerName = readString(from: fileData, offset: &offset, length: Int(nameLength)),
              let payloadLength = readUInt32(from: fileData, offset: &offset) else {
            return nil
        }

        let payloadCount = Int(payloadLength)
        guard let obfuscatedPayload = readData(from: fileData, offset: &offset, length: payloadCount),
              let storedChecksum = readUInt64(from: fileData, offset: &offset) else {
            return nil
        }

        let key = obfuscationKey(for: playerName)
        let payload = xorData(obfuscatedPayload, key: key)

        guard checksum64(payload) == storedChecksum else {
            return nil
        }

        let decoder = PropertyListDecoder()
        return try? decoder.decode(GameSnapshot.self, from: payload)
    }

    func obfuscationKey(for playerName: String) -> Data {
        let base = (playerName + SaveFormat.xorSalt).data(using: .utf8) ?? Data([0x45, 0x51])
        return base.isEmpty ? Data([0x45, 0x51]) : base
    }

    func xorData(_ data: Data, key: Data) -> Data {
        guard !key.isEmpty else { return data }
        var result = Data(capacity: data.count)

        for (index, byte) in data.enumerated() {
            result.append(byte ^ key[index % key.count])
        }

        return result
    }

    func checksum64(_ data: Data) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return hash
    }

    func appendUInt16(_ value: UInt16, to data: inout Data) {
        var littleEndian = value.littleEndian
        withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
    }

    func appendUInt32(_ value: UInt32, to data: inout Data) {
        var littleEndian = value.littleEndian
        withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
    }

    func appendUInt64(_ value: UInt64, to data: inout Data) {
        var littleEndian = value.littleEndian
        withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
    }

    func readByte(from data: Data, offset: inout Int) -> UInt8? {
        guard offset < data.count else { return nil }
        defer { offset += 1 }
        return data[offset]
    }

    func readUInt16(from data: Data, offset: inout Int) -> UInt16? {
        guard let chunk = readData(from: data, offset: &offset, length: 2), chunk.count == 2 else { return nil }
        let b0 = UInt16(chunk[chunk.startIndex])
        let b1 = UInt16(chunk[chunk.startIndex.advanced(by: 1)])
        return b0 | (b1 << 8)
    }

    func readUInt32(from data: Data, offset: inout Int) -> UInt32? {
        guard let chunk = readData(from: data, offset: &offset, length: 4), chunk.count == 4 else { return nil }
        let b0 = UInt32(chunk[chunk.startIndex])
        let b1 = UInt32(chunk[chunk.startIndex.advanced(by: 1)])
        let b2 = UInt32(chunk[chunk.startIndex.advanced(by: 2)])
        let b3 = UInt32(chunk[chunk.startIndex.advanced(by: 3)])
        return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
    }

    func readUInt64(from data: Data, offset: inout Int) -> UInt64? {
        guard let chunk = readData(from: data, offset: &offset, length: 8), chunk.count == 8 else { return nil }
        let b0 = UInt64(chunk[chunk.startIndex])
        let b1 = UInt64(chunk[chunk.startIndex.advanced(by: 1)])
        let b2 = UInt64(chunk[chunk.startIndex.advanced(by: 2)])
        let b3 = UInt64(chunk[chunk.startIndex.advanced(by: 3)])
        let b4 = UInt64(chunk[chunk.startIndex.advanced(by: 4)])
        let b5 = UInt64(chunk[chunk.startIndex.advanced(by: 5)])
        let b6 = UInt64(chunk[chunk.startIndex.advanced(by: 6)])
        let b7 = UInt64(chunk[chunk.startIndex.advanced(by: 7)])
        return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24) | (b4 << 32) | (b5 << 40) | (b6 << 48) | (b7 << 56)
    }

    func readString(from data: Data, offset: inout Int, length: Int) -> String? {
        guard let chunk = readData(from: data, offset: &offset, length: length) else { return nil }
        return String(data: chunk, encoding: .utf8)
    }

    func readData(from data: Data, offset: inout Int, length: Int) -> Data? {
        guard length >= 0, offset + length <= data.count else { return nil }
        let range = offset..<(offset + length)
        offset += length
        return data.subdata(in: range)
    }
}
