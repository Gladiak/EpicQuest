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
        townProjectInvestmentThisVisit = 0

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

        let spentOnMerchant = initialGold - gold
        let projectSummary = investInTownProjectIfPossible()

        if purchased == 0 {
            if projectSummary.isEmpty {
                logLine = "Done selling. No worthy merchant upgrades. Back to adventure."
            } else {
                logLine = "Done selling. No worthy merchant upgrades. \(projectSummary) Back to adventure."
            }
            return
        }

        if projectSummary.isEmpty {
            logLine = "Done selling. Bought \(purchased) upgrade(s) for \(spentOnMerchant) gold. Back to adventure."
        } else {
            logLine = "Done selling. Bought \(purchased) upgrade(s) for \(spentOnMerchant) gold. \(projectSummary) Back to adventure."
        }
    }

    func generateMerchantUpgrade(for slot: EquipmentSlot) -> LootItem {
        let honorTierBonus = merchantHonorTier()
        let leagueBonus = arenaLeague.progressionBonus
        let forgeQualityBonus = townProjectForgeMerchantQualityBonus()
        let forgePowerBonus = townProjectForgeMerchantPowerBonus()
        let merchantBonus = honorTierBonus + leagueBonus + forgeQualityBonus
        let merchantLevelBonus = max(0, merchantBonus - 1) + forgePowerBonus
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
            let rerollCap = 6 + merchantBonus + forgePowerBonus
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

        let forgeFlex = min(3, max(0, townProjectLevel(for: .forgeDistrict) / 3))
        let requiredImprovement = max(3, (equipped.power <= 3 ? 5 : 7) - forgeFlex)
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

    func initializeTownProjects() {
        for type in TownProjectType.allCases {
            if var state = townProjects[type] {
                state.level = max(0, state.level)
                state.progress = max(0, state.progress)
                state.required = max(30, state.required)
                state.lastCompletedAtLevel = max(0, state.lastCompletedAtLevel)
                townProjects[type] = state
            }
        }

        for type in TownProjectType.allCases where townProjects[type] == nil {
            townProjects[type] = TownProjectState(
                type: type,
                level: 0,
                progress: 0,
                required: BalanceTuning.townProjectBaseRequired,
                lastCompletedAtLevel: 0
            )
        }

        if townProjects[activeTownProject] == nil {
            activeTownProject = .forgeDistrict
        }

        townProjectInvestmentThisVisit = max(0, townProjectInvestmentThisVisit)
        townRetreatCriticalCount = max(0, townRetreatCriticalCount)
        townRetreatInventoryCount = max(0, townRetreatInventoryCount)
    }

    func townProjectState(for type: TownProjectType) -> TownProjectState {
        if let stored = townProjects[type] {
            return stored
        }
        return TownProjectState(
            type: type,
            level: 0,
            progress: 0,
            required: BalanceTuning.townProjectBaseRequired,
            lastCompletedAtLevel: 0
        )
    }

    func townProjectLevel(for type: TownProjectType) -> Int {
        townProjectState(for: type).level
    }

    func townProjectInventoryCapacityBonus() -> Double {
        let level = townProjectLevel(for: .caravanGuild)
        let bonus = Double(level) * BalanceTuning.townProjectCaravanCapacityPerLevel
        return min(BalanceTuning.townProjectCaravanCapacityCap, bonus)
    }

    func townProjectTravelTickReduction() -> Int {
        let level = townProjectLevel(for: .caravanGuild)
        return min(
            BalanceTuning.townProjectCaravanTravelTickReductionCap,
            level / BalanceTuning.townProjectCaravanTravelTickReductionPerTwoLevels
        )
    }

    func townProjectForgeMerchantQualityBonus() -> Int {
        min(
            BalanceTuning.townProjectForgeMerchantQualityCap,
            townProjectLevel(for: .forgeDistrict) * BalanceTuning.townProjectForgeMerchantQualityPerLevel
        )
    }

    func townProjectForgeMerchantPowerBonus() -> Int {
        min(
            BalanceTuning.townProjectForgeMerchantPowerCap,
            townProjectLevel(for: .forgeDistrict) / BalanceTuning.townProjectForgeMerchantPowerPerTwoLevels
        )
    }

    func townProjectArcaneRegenBonusRatio() -> Double {
        let ratio = Double(townProjectLevel(for: .arcaneAcademy)) * BalanceTuning.townProjectArcaneRegenPerLevel
        return min(BalanceTuning.townProjectArcaneRegenCap, max(0, ratio))
    }

    func townProjectArcaneDropChanceBonus() -> Int {
        min(
            BalanceTuning.townProjectArcaneDropChanceCap,
            townProjectLevel(for: .arcaneAcademy) * BalanceTuning.townProjectArcaneDropChancePerLevel
        )
    }

    func townProjectWallsDamageMitigation() -> Int {
        min(
            BalanceTuning.townProjectWallsMitigationCap,
            townProjectLevel(for: .fortifiedWalls) * BalanceTuning.townProjectWallsMitigationPerLevel
        )
    }

    func chooseTownProjectFocus() -> TownProjectType {
        var best = TownProjectType.forgeDistrict
        var bestScore = Int.min

        for type in TownProjectType.allCases {
            let score = townProjectFocusScore(for: type)
            if score > bestScore {
                bestScore = score
                best = type
            }
        }

        return best
    }

    func townProjectFocusScore(for type: TownProjectType) -> Int {
        let levelPenalty = townProjectLevel(for: type) * 2

        switch type {
        case .forgeDistrict:
            let equippedAveragePower: Int
            if equipment.isEmpty {
                equippedAveragePower = 0
            } else {
                let totalPower = equipment.values.reduce(0) { $0 + $1.power }
                equippedAveragePower = totalPower / max(1, equipment.count)
            }
            let expectedPower = max(3, level + currentActNumber + honorTier())
            let gap = max(0, expectedPower - equippedAveragePower)
            return 20 + gap * 5 - levelPenalty

        case .arcaneAcademy:
            let spellNeed = max(0, (level / 2) - knownSpells.count)
            let manaNeed = max(0, (6 + level / 2) - mpMax)
            let archetypeBonus = GameData.classArchetype(for: character.characterClass) == .magic ? 10 : 0
            return 14 + spellNeed * 5 + manaNeed * 3 + archetypeBonus - levelPenalty

        case .caravanGuild:
            let inventoryPressure = townRetreatInventoryCount * 4
            let capacityNeed = max(0, (level / 2) - Int(effectiveInventoryCapacity / 2))
            return 12 + inventoryPressure + capacityNeed * 3 - levelPenalty

        case .fortifiedWalls:
            let criticalPressure = townRetreatCriticalCount * 5
            let defenseNeed = max(0, currentActNumber * 3 - defense / 5)
            return 12 + criticalPressure + defenseNeed * 4 - levelPenalty
        }
    }

    func investInTownProjectIfPossible() -> String {
        initializeTownProjects()

        let safetyReserve = max(30, level * 4 + currentActNumber * 8)
        let spendable = max(0, gold - safetyReserve)
        let proportional = Int((Double(gold) * BalanceTuning.townProjectBudgetShare).rounded(.down))
        let budget = min(spendable, proportional)

        guard budget >= BalanceTuning.townProjectMinimumInvestment else {
            townProjectInvestmentThisVisit = 0
            townProjectLogLine = "No project funding available."
            townRetreatCriticalCount = max(0, townRetreatCriticalCount - 1)
            townRetreatInventoryCount = max(0, townRetreatInventoryCount - 1)
            return ""
        }

        let focus = chooseTownProjectFocus()
        activeTownProject = focus
        var state = townProjectState(for: focus)

        var remaining = budget
        var totalInvested = 0
        var upgrades = 0

        while remaining > 0 {
            let needed = max(1, state.required - state.progress)
            let invested = min(remaining, needed)
            state.progress += invested
            remaining -= invested
            totalInvested += invested

            if state.progress >= state.required {
                state.progress -= state.required
                state.level += 1
                state.lastCompletedAtLevel = level
                upgrades += 1
                let nextRequired = Int((Double(state.required) * BalanceTuning.townProjectRequiredGrowth).rounded())
                    + BalanceTuning.townProjectRequiredFlatGain
                state.required = min(240_000, max(40, nextRequired))
            }
        }

        gold -= totalInvested
        townProjectInvestmentThisVisit = totalInvested
        townProjects[focus] = state

        townRetreatCriticalCount = max(0, townRetreatCriticalCount - 1)
        townRetreatInventoryCount = max(0, townRetreatInventoryCount - 1)

        if upgrades > 0 {
            townProjectLogLine = "\(focus.rawValue) upgraded to \(romanNumeral(max(1, state.level)))."
            return "Town invested \(totalInvested)g in \(focus.shortLabel) (+\(upgrades) level)."
        }

        townProjectLogLine = "Invested \(totalInvested)g in \(focus.rawValue)."
        return "Town invested \(totalInvested)g in \(focus.shortLabel)."
    }

    var townProjectStatusLabel: String {
        if isSellingInTown {
            return "Investing"
        }
        if townProjectInvestmentThisVisit > 0 {
            return "Funded +\(townProjectInvestmentThisVisit)g"
        }
        return "Standby"
    }

    var townProjectFocusLabel: String {
        let state = townProjectState(for: activeTownProject)
        return "\(activeTownProject.shortLabel) L\(state.level)"
    }

    var townProjectProgressValue: Double {
        let state = townProjectState(for: activeTownProject)
        let required = max(state.required, 1)
        return clampedProgress(Double(state.progress) / Double(required))
    }

    var townProjectBonusLabel: String {
        switch activeTownProject {
        case .forgeDistrict:
            return "Merchant quality +\(townProjectForgeMerchantQualityBonus())"
        case .arcaneAcademy:
            let regenBonus = Int((townProjectArcaneRegenBonusRatio() * 100).rounded())
            return "MP regen +\(regenBonus)% | Scroll +\(townProjectArcaneDropChanceBonus())%"
        case .caravanGuild:
            let capacityBonus = String(format: "%.1f", townProjectInventoryCapacityBonus())
            return "Capacity +\(capacityBonus) | Travel -\(townProjectTravelTickReduction())"
        case .fortifiedWalls:
            return "Damage mitigation +\(townProjectWallsDamageMitigation())"
        }
    }
}
