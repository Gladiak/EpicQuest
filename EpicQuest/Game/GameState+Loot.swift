import Foundation

extension GameState {
    func seedInitialEquipment() {
        let quality = Int.random(in: -10 ... -8)
        let base = EpicEquipmentNames.weaponBases.randomElement() ?? "Sword"
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
        let magicSuffix: String
        if slot.isWeaponLike {
            magicSuffix = shouldApplyMythicSuffix(quality: quality) ? (MagicAttributes.weapon.randomElement() ?? "of Embers") : ""
        } else {
            magicSuffix = shouldApplyMythicSuffix(quality: quality) ? (MagicAttributes.armor.randomElement() ?? "of Warding") : ""
        }

        let qualityPowerBoost = max(-2, quality / 4)
        let power = max(1, monsterLevel + Int.random(in: -1...3) + qualityPowerBoost)
        let value = max(1, power * Int.random(in: 4...10) + quality * 2)
        let weight = Double.random(in: 0.6...1.8)
        let attackBonus = max(0, Int.random(in: 0...(power + 1)) + max(0, quality / 3))
        let defenseBonus = max(0, Int.random(in: 0...(power + 1)) + max(0, quality / 3))

        let composedName = magicSuffix.isEmpty
            ? "\(qualityPrefix) \(base)"
            : "\(qualityPrefix) \(base) \(magicSuffix)"

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
        actAttackBonus += item.attackBonus
        actDefenseBonus += item.defenseBonus

        if let equipped = equipment[item.slot], equipped.power >= item.power {
            inventory.append(item)
            inventoryLoad += item.weight
            return
        }

        if let equipped = equipment[item.slot] {
            inventory.append(equipped)
            inventoryLoad += equipped.weight
        }

        equipment[item.slot] = item
    }

    func sellStep() {
        guard !inventory.isEmpty else {
            inventoryLoad = 0
            isSellingInTown = false
            logLine = "Done selling. Back to adventure."
            return
        }

        let sold = inventory.removeLast()
        gold += sold.value
        inventoryLoad = max(0, inventoryLoad - sold.weight)
        logLine = "Sold \(sold.name) for \(sold.value) gold."
    }

    func baseName(for slot: EquipmentSlot) -> String {
        switch slot {
        case .weapon:
            return EpicEquipmentNames.weaponBases.randomElement() ?? "Sword"
        case .shield:
            return EpicEquipmentNames.shieldBases.randomElement() ?? "Shield"
        case .armor:
            return EpicEquipmentNames.armorBases.randomElement() ?? "Hauberk"
        case .helm:
            return EpicEquipmentNames.helmBases.randomElement() ?? "Helm"
        case .ring:
            return EpicEquipmentNames.ringBases.randomElement() ?? "Ring"
        case .boots:
            return EpicEquipmentNames.bootsBases.randomElement() ?? "Boots"
        }
    }
}
