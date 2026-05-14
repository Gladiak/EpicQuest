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

    func generateLoot(for monsterLevel: Int, forcedSlot: EquipmentSlot? = nil) -> LootItem {
        let slot = forcedSlot ?? EquipmentSlot.allCases.randomElement() ?? .weapon

        let quality = randomQualityModifier(forAct: currentActNumber)
        let qualityPrefix = qualityLabel(quality)

        let base = baseName(for: slot)
        let namePrefix = namePrefix(forQuality: quality)
        let epithet = nameEpithet(forQuality: quality)

        let magicSuffix: String
        if slot.isWeaponLike {
            let suffixes = epicSuffixes(from: MagicAttributes.weapon, quality: quality)
            magicSuffix = suffixes.joined(separator: " ")
        } else {
            let suffixes = epicSuffixes(from: MagicAttributes.armor, quality: quality)
            magicSuffix = suffixes.joined(separator: " ")
        }

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

        let composedCore = [qualityPrefix, namePrefix, base, epithet]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        let composedName = magicSuffix.isEmpty
            ? composedCore
            : "\(composedCore) \(magicSuffix)"

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

        if let equipped = equipment[item.slot] {
            inventory.append(equipped)
            inventoryLoad += equipped.weight
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

        for slot in EquipmentSlot.allCases.shuffled() {
            let candidate = generateMerchantUpgrade(for: slot)
            guard shouldBuyMerchantItem(candidate) else { continue }
            guard gold >= candidate.value else { continue }

            gold -= candidate.value
            purchased += 1

            if let equipped = equipment[slot] {
                inventory.append(equipped)
                inventoryLoad += equipped.weight
            }

            equipItem(candidate)

            if purchased >= 3 {
                break
            }
        }

        if purchased == 0 {
            logLine = "Done selling. No worthy merchant upgrades. Back to adventure."
            return
        }

        let spent = initialGold - gold
        logLine = "Done selling. Bought \(purchased) upgrade(s) for \(spent) gold. Back to adventure."
    }

    func generateMerchantUpgrade(for slot: EquipmentSlot) -> LootItem {
        let merchantLevel = max(level + 2, level + currentActNumber)
        return generateLoot(for: merchantLevel, forcedSlot: slot)
    }

    func shouldBuyMerchantItem(_ candidate: LootItem) -> Bool {
        guard let equipped = equipment[candidate.slot] else { return true }

        let currentScore = itemScore(equipped)
        let candidateScore = itemScore(candidate)
        let improvement = candidateScore - currentScore

        if improvement <= 0 {
            return false
        }

        let maxAffordableSpend = max(18, Int(Double(gold) * 0.7))
        if candidate.value > maxAffordableSpend {
            return false
        }

        return improvement >= 2 || candidate.power > equipped.power
    }

    func itemScore(_ item: LootItem) -> Int {
        (item.power * 3) + (item.attackBonus * 2) + (item.defenseBonus * 2) + item.qualityModifier
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

    func baseName(for slot: EquipmentSlot) -> String {
        switch slot {
        case .weapon:
            return EpicEquipmentNames.weaponBases.randomElement() ?? "Sharp Rock"
        case .shield:
            return EpicEquipmentNames.shieldBases.randomElement() ?? "Wooden Lid"
        case .helm:
            return EpicEquipmentNames.helmBases.randomElement() ?? "War Cap"
        case .hauberk:
            return EpicEquipmentNames.hauberkBases.randomElement() ?? "Burlap"
        case .brassairts:
            return EpicEquipmentNames.brassairtsBases.randomElement() ?? "Patchwork"
        case .vambraces:
            return EpicEquipmentNames.vambracesBases.randomElement() ?? "Wrist Wraps"
        case .gauntlets:
            return EpicEquipmentNames.gauntletsBases.randomElement() ?? "Work Gloves"
        case .gambeson:
            return EpicEquipmentNames.gambesonBases.randomElement() ?? "Quilt Coat"
        case .cuisses:
            return EpicEquipmentNames.cuissesBases.randomElement() ?? "Thigh Plates"
        case .greaves:
            return EpicEquipmentNames.greavesBases.randomElement() ?? "Shin Guards"
        case .solerets:
            return EpicEquipmentNames.soleretsBases.randomElement() ?? "Solerets"
        }
    }

    func epicSuffixes(from pool: [String], quality: Int) -> [String] {
        guard shouldApplyMythicSuffix(quality: quality) else { return [] }

        var count = 1
        if quality >= 4, Int.random(in: 1...100) <= 35 { count += 1 }
        if quality >= 8, Int.random(in: 1...100) <= 20 { count += 1 }

        var selected: [String] = []
        var remaining = pool
        for _ in 0..<count {
            guard !remaining.isEmpty else { break }
            let index = Int.random(in: 0..<remaining.count)
            selected.append(remaining.remove(at: index))
        }

        return selected
    }

    func namePrefix(forQuality quality: Int) -> String {
        guard quality >= -2 else { return "" }
        return EpicEquipmentNames.rarePrefixes.randomElement() ?? ""
    }

    func nameEpithet(forQuality quality: Int) -> String {
        guard quality >= 2, Int.random(in: 1...100) <= 40 else { return "" }
        return EpicEquipmentNames.epithets.randomElement() ?? ""
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
