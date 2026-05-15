import Foundation

extension GameState {
    func seedInitialEquipment() {
        let quality = Int.random(in: -10 ... -8)
        let base = EpicEquipmentNames.weaponBases.randomElement() ?? "Sharp Rock"
        let qualityPrefix = qualityLabel(quality)
        let name = "\(qualityPrefix) \(base)"
        let attackBonus = max(0, (quality + 10) / 2)

        let starter = LootItem(
            name: name,
            power: 1,
            slot: .weapon,
            value: 2,
            weight: 1.0,
            attackBonus: attackBonus,
            defenseBonus: 0,
            qualityModifier: quality
        )

        equipment[.weapon] = starter
        actAttackBonus += starter.attackBonus
    }

    func generateLoot(
        for monsterLevel: Int,
        forcedSlot: EquipmentSlot? = nil,
        minimumQuality: Int? = nil,
        preferredBaseName: String? = nil,
        allowFlavorModifier: Bool = true,
        qualityBias: Int = 0
    ) -> LootItem {
        let slot = forcedSlot ?? EquipmentSlot.allCases.randomElement() ?? .weapon

        let rolledQuality = randomQualityModifier(forAct: currentActNumber) + qualityBias
        let quality = min(30, max(rolledQuality, minimumQuality ?? rolledQuality))

        let base = preferredBaseName ?? baseName(for: slot)
        let flavorModifier = allowFlavorModifier ? singleNameModifier(for: slot, quality: quality) : ""

        let qualityPowerBoost = max(-3, quality / 3)
        let power = max(1, monsterLevel + Int.random(in: -2...4) + qualityPowerBoost)
        let value = max(1, power * Int.random(in: 3...13) + quality * 3)
        let weight = Double.random(in: 0.4...2.4)

        let slotBias = slotBonusBias(for: slot)
        let qualityBias = quality / 4
        let attackRoll = Int.random(in: -1...(power + 3)) + qualityBias + slotBias.attack
        let defenseRoll = Int.random(in: -1...(power + 3)) + qualityBias + slotBias.defense
        let attackBonus = max(-2, attackRoll)
        let defenseBonus = max(-2, defenseRoll)

        let composedName = composeItemName(base: base, quality: quality, flavorModifier: flavorModifier)

        return LootItem(
            name: composedName,
            power: power,
            slot: slot,
            value: value,
            weight: weight,
            attackBonus: attackBonus,
            defenseBonus: defenseBonus,
            qualityModifier: quality
        )
    }

    func autoEquipOrStore(_ item: LootItem) {
        if let equipped = equipment[item.slot], equipped.power >= item.power {
            inventory.append(item)
            inventoryLoad += item.weight
            return
        }
        equipItem(item)
    }

    func sellStep() {
        guard !inventory.isEmpty else {
            inventoryLoad = 0
            runMerchantUpgradePhase()
            isSellingInTown = false
            return
        }

        let sold = inventory.removeLast()
        gold += sold.value
        inventoryLoad = max(0, inventoryLoad - sold.weight)
        logLine = "Sold \(sold.name) for \(sold.value) gold."
    }

    func runMerchantUpgradePhase() {
        let initialGold = gold
        var purchased = 0
        var failedAttempts = 0
        let maxFailedAttempts = max(10, EquipmentSlot.allCases.count * 5)

        while gold > 0 && failedAttempts < maxFailedAttempts {
            guard let slot = EquipmentSlot.allCases.randomElement() else { break }
            let candidate = generateMerchantUpgrade(for: slot)
            guard shouldBuyMerchantItem(candidate) else {
                failedAttempts += 1
                continue
            }
            guard gold >= candidate.value else {
                failedAttempts += 1
                continue
            }

            gold -= candidate.value
            purchased += 1
            failedAttempts = 0

            equipItem(candidate)
        }

        if purchased == 0 {
            logLine = "Done selling. No worthy merchant upgrades. Back to adventure."
            return
        }

        let spent = initialGold - gold
        logLine = "Done selling. Bought \(purchased) upgrade(s) for \(spent) gold. Back to adventure."
    }

    func generateMerchantUpgrade(for slot: EquipmentSlot) -> LootItem {
        let honorTierBonus = merchantHonorTier()
        let leagueBonus = arenaLeague.progressionBonus
        let merchantBonus = honorTierBonus + leagueBonus
        let merchantLevelBonus = max(0, merchantBonus - 1)
        let merchantLevel = max(level + 2 + merchantLevelBonus, level + currentActNumber + merchantLevelBonus)
        let equipped = equipment[slot]
        let preferredBase = equipped.flatMap { canonicalBaseName(from: $0.name, slot: slot) }
        let minimumQuality = (equipped?.qualityModifier ?? -10) + 1 + merchantBonus

        var candidate = generateLoot(
            for: merchantLevel,
            forcedSlot: slot,
            minimumQuality: minimumQuality,
            preferredBaseName: preferredBase,
            allowFlavorModifier: false
        )

        if let equipped {
            var rerolls = 0
            let rerollCap = 6 + merchantBonus
            while candidate.power <= equipped.power && rerolls < rerollCap {
                candidate = generateLoot(
                    for: merchantLevel + 1 + rerolls,
                    forcedSlot: slot,
                    minimumQuality: equipped.qualityModifier + 1 + merchantBonus,
                    preferredBaseName: preferredBase,
                    allowFlavorModifier: false
                )
                rerolls += 1
            }

            if candidate.power <= equipped.power {
                let boostedPower = equipped.power + Int.random(in: 1...(2 + merchantBonus))
                let boostedQuality = max(candidate.qualityModifier, equipped.qualityModifier + 1 + merchantBonus)
                let boostedName = composeItemName(
                    base: preferredBase ?? baseName(for: slot),
                    quality: boostedQuality,
                    flavorModifier: ""
                )
                candidate = LootItem(
                    name: boostedName,
                    power: boostedPower,
                    slot: candidate.slot,
                    value: max(candidate.value, boostedPower * Int.random(in: 18...30)),
                    weight: candidate.weight,
                    attackBonus: max(candidate.attackBonus, equipped.attackBonus),
                    defenseBonus: max(candidate.defenseBonus, equipped.defenseBonus),
                    qualityModifier: boostedQuality
                )
            }
        }

        return applyMerchantPricing(to: candidate, equipped: equipped)
    }

    func shouldBuyMerchantItem(_ candidate: LootItem) -> Bool {
        guard let equipped = equipment[candidate.slot] else {
            let baselineScore = max(8, level + currentActNumber * 2)
            return itemScore(candidate) >= baselineScore
        }

        let currentScore = itemScore(equipped)
        let candidateScore = itemScore(candidate)
        let improvement = candidateScore - currentScore

        if improvement <= 0 {
            return false
        }

        let requiredImprovement = equipped.power <= 3 ? 5 : 7
        if candidate.power >= equipped.power + 4 {
            return true
        }

        let qualityStep = candidate.qualityModifier - equipped.qualityModifier
        return improvement >= requiredImprovement && qualityStep >= 1
    }

    func itemScore(_ item: LootItem) -> Int {
        (item.power * 3) + (item.attackBonus * 2) + (item.defenseBonus * 2) + item.qualityModifier
    }

    func applyMerchantPricing(to candidate: LootItem, equipped: LootItem?) -> LootItem {
        let equippedPower = equipped?.power ?? max(1, level / 2)
        let powerDelta = max(0, candidate.power - equippedPower)
        let qualityPremium = max(0, candidate.qualityModifier) * Int.random(in: 8...14)
        let powerPremium = powerDelta * Int.random(in: 9...13)
        let statPremium = (max(0, candidate.attackBonus) + max(0, candidate.defenseBonus)) * Int.random(in: 4...7)
        let actPremium = max(0, currentActNumber) * Int.random(in: 14...22)
        let markedBase = candidate.value + qualityPremium + powerPremium + statPremium + actPremium
        let multiplier = Double.random(in: 1.65...2.35)
        let markedValue = Int((Double(markedBase) * multiplier).rounded(.up))

        return LootItem(
            name: candidate.name,
            power: candidate.power,
            slot: candidate.slot,
            value: max(candidate.value, markedValue),
            weight: candidate.weight,
            attackBonus: candidate.attackBonus,
            defenseBonus: candidate.defenseBonus,
            qualityModifier: candidate.qualityModifier
        )
    }

    func equipItem(_ item: LootItem) {
        if let current = equipment[item.slot] {
            actAttackBonus -= current.attackBonus
            actDefenseBonus -= current.defenseBonus
        }

        equipment[item.slot] = item
        actAttackBonus += item.attackBonus
        actDefenseBonus += item.defenseBonus
    }

    func rebuildCombatBonusesFromEquipment() {
        actAttackBonus = equipment.values.reduce(0) { $0 + $1.attackBonus }
        actDefenseBonus = equipment.values.reduce(0) { $0 + $1.defenseBonus }
    }

    func baseName(for slot: EquipmentSlot) -> String {
        basePool(for: slot).randomElement() ?? "Simple Gear"
    }

    func basePool(for slot: EquipmentSlot) -> [String] {
        switch slot {
        case .weapon:
            return EpicEquipmentNames.weaponBases
        case .shield:
            return EpicEquipmentNames.shieldBases
        case .helm:
            return EpicEquipmentNames.helmBases
        case .hauberk:
            return EpicEquipmentNames.hauberkBases
        case .brassairts:
            return EpicEquipmentNames.brassairtsBases
        case .vambraces:
            return EpicEquipmentNames.vambracesBases
        case .gauntlets:
            return EpicEquipmentNames.gauntletsBases
        case .gambeson:
            return EpicEquipmentNames.gambesonBases
        case .cuisses:
            return EpicEquipmentNames.cuissesBases
        case .greaves:
            return EpicEquipmentNames.greavesBases
        case .solerets:
            return EpicEquipmentNames.soleretsBases
        }
    }

    func canonicalBaseName(from itemName: String, slot: EquipmentSlot) -> String? {
        let candidates = basePool(for: slot).sorted { $0.count > $1.count }
        for base in candidates where itemName.contains(base) {
            return base
        }
        return nil
    }

    func composeItemName(base: String, quality: Int, flavorModifier: String) -> String {
        let numericPrefix = qualityLabel(quality)
        if flavorModifier.isEmpty {
            return "\(numericPrefix) \(base)"
        }
        return "\(numericPrefix) \(base) \(flavorModifier)"
    }

    func singleNameModifier(for slot: EquipmentSlot, quality: Int) -> String {
        let isQuestFinisher = completedBattlesInQuest + 1 >= battlesPerQuest
        if shouldApplyMythicSuffix(quality: quality) {
            if slot.isWeaponLike {
                return MagicAttributes.weapon.randomElement() ?? ""
            } else {
                return MagicAttributes.armor.randomElement() ?? ""
            }
        }

        let prefixChance = min(20, 4 + currentActNumber * 2 + (isQuestFinisher ? 5 : 0))
        if quality >= 0, Int.random(in: 1...100) <= prefixChance {
            return EpicEquipmentNames.rarePrefixes.randomElement() ?? ""
        }

        let epithetChance = min(10, 1 + currentActNumber)
        if quality >= 4, isQuestFinisher, Int.random(in: 1...100) <= epithetChance {
            return EpicEquipmentNames.epithets.randomElement() ?? ""
        }

        return ""
    }

    func slotBonusBias(for slot: EquipmentSlot) -> (attack: Int, defense: Int) {
        switch slot {
        case .weapon:
            return (attack: 4, defense: -1)
        case .shield:
            return (attack: -1, defense: 4)
        case .helm, .hauberk, .brassairts, .vambraces, .gauntlets, .gambeson, .cuisses, .greaves, .solerets:
            return (attack: 1, defense: 2)
        }
    }
}
