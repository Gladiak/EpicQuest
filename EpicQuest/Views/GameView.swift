import SwiftUI

private enum GameLayout {
    static let outerPadding: CGFloat = 8
    static let panelSpacing: CGFloat = 8
    static let topRowRatio: CGFloat = 0.58
    static let minTopRowHeight: CGFloat = 280
    static let minSecondRowHeight: CGFloat = 180
    static let topPrimaryMinHeight: CGFloat = 150
    static let topSecondaryMinHeight: CGFloat = 124
    static let topSecondaryPreferredHeight: CGFloat = 132
    static let battleFeedMinHeight: CGFloat = 70
    static let battleFeedPreferredHeight: CGFloat = 78
}

private struct GameLayoutMetrics {
    let topRowHeight: CGFloat
    let secondRowHeight: CGFloat
    let battleFeedHeight: CGFloat
    let topPrimaryPanelHeight: CGFloat
    let topSecondaryPanelHeight: CGFloat
}

struct GameView: View {
    @Binding var game: GameState

    private static let equipmentBottomAnchorID = "equipment-bottom-anchor"
    private static let spellbookBottomAnchorID = "spellbook-bottom-anchor"
    private static let inventoryBottomAnchorID = "inventory-bottom-anchor"
    private static let plotBottomAnchorID = "plot-bottom-anchor"
    private static let questBottomAnchorID = "quest-bottom-anchor"

    private var equipmentScrollToken: String {
        EquipmentSlot.allCases
            .map { slot in "\(slot.rawValue):\(game.equipment[slot]?.name ?? "-")" }
            .joined(separator: "||")
    }

    private var plotScrollToken: String {
        game.plotItems
            .map { item in "\(item.title):\(item.isCompleted)" }
            .joined(separator: "||")
    }

    private var questScrollToken: String {
        "\(game.completedQuestNames.count)|\(game.completedQuestNames.last ?? "")|\(game.currentQuest)"
    }

    private var spellbookScrollToken: String {
        game.knownSpells
            .map { spell in "\(spell.id.uuidString):\(spell.level)" }
            .joined(separator: "||")
    }

    private var inventoryScrollToken: String {
        game.inventory
            .map { item in item.id.uuidString }
            .joined(separator: "||")
    }

    private func scrollToBottom(using proxy: ScrollViewProxy, anchorID: String, animated: Bool = true) {
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(anchorID, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(anchorID, anchor: .bottom)
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = max(0, proxy.size.width - GameLayout.outerPadding * 2)
            let contentHeight = max(0, proxy.size.height - GameLayout.outerPadding * 2)
            let metrics = layoutMetrics(for: contentHeight)
            let columnWidth = columnWidth(for: contentWidth)

            VStack(alignment: .leading, spacing: GameLayout.panelSpacing) {
                topRow(
                    height: metrics.topRowHeight,
                    primaryPanelHeight: metrics.topPrimaryPanelHeight,
                    secondaryPanelHeight: metrics.topSecondaryPanelHeight,
                    columnWidth: columnWidth
                )

                secondRow(height: metrics.secondRowHeight, columnWidth: columnWidth)

                battleFeed(height: metrics.battleFeedHeight)
            }
            .padding(GameLayout.outerPadding)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
    }

    private func layoutMetrics(for contentHeight: CGFloat) -> GameLayoutMetrics {
        let rowStackHeight = max(0, contentHeight - GameLayout.panelSpacing * 2)
        let battleFeedHeight = battleFeedHeight(for: rowStackHeight)
        let rowContentHeight = max(0, rowStackHeight - battleFeedHeight)
        let rowHeights = mainRowHeights(for: rowContentHeight)
        let secondaryHeight = topSecondaryPanelHeight(for: rowHeights.top)
        let primaryHeight = max(0, rowHeights.top - GameLayout.panelSpacing - secondaryHeight)

        return GameLayoutMetrics(
            topRowHeight: rowHeights.top,
            secondRowHeight: rowHeights.second,
            battleFeedHeight: battleFeedHeight,
            topPrimaryPanelHeight: primaryHeight,
            topSecondaryPanelHeight: secondaryHeight
        )
    }

    private func columnWidth(for contentWidth: CGFloat) -> CGFloat {
        max(0, (contentWidth - GameLayout.panelSpacing * 2) / 3)
    }

    private func battleFeedHeight(for rowStackHeight: CGFloat) -> CGFloat {
        guard rowStackHeight > 0 else { return 0 }

        let responsiveHeight = max(GameLayout.battleFeedMinHeight, rowStackHeight * 0.1)
        return min(GameLayout.battleFeedPreferredHeight, responsiveHeight, rowStackHeight)
    }

    private func mainRowHeights(for availableHeight: CGFloat) -> (top: CGFloat, second: CGFloat) {
        guard availableHeight > 0 else { return (0, 0) }

        if availableHeight < (GameLayout.minTopRowHeight + GameLayout.minSecondRowHeight) {
            let top = availableHeight * GameLayout.topRowRatio
            return (top, max(0, availableHeight - top))
        }

        let desiredTop = availableHeight * GameLayout.topRowRatio
        let maxTop = availableHeight - GameLayout.minSecondRowHeight
        let top = min(max(desiredTop, GameLayout.minTopRowHeight), maxTop)
        return (top, max(0, availableHeight - top))
    }

    private func topSecondaryPanelHeight(for topRowHeight: CGFloat) -> CGFloat {
        let maxSecondaryHeight = max(0, topRowHeight - GameLayout.panelSpacing - GameLayout.topPrimaryMinHeight)
        guard maxSecondaryHeight > 0 else {
            return max(0, topRowHeight - GameLayout.panelSpacing)
        }

        let preferred = min(GameLayout.topSecondaryPreferredHeight, maxSecondaryHeight)
        let minimum = min(GameLayout.topSecondaryMinHeight, maxSecondaryHeight)
        return max(minimum, preferred)
    }

    private func topRow(
        height: CGFloat,
        primaryPanelHeight: CGFloat,
        secondaryPanelHeight: CGFloat,
        columnWidth: CGFloat
    ) -> some View {
        HStack(alignment: .top, spacing: GameLayout.panelSpacing) {
            characterPanel(height: height)
                .frame(width: columnWidth, height: height, alignment: .top)

            VStack(spacing: GameLayout.panelSpacing) {
                equipmentPanel(height: primaryPanelHeight)
                arenaPanel(height: secondaryPanelHeight)
            }
            .frame(width: columnWidth, height: height, alignment: .top)

            VStack(spacing: GameLayout.panelSpacing) {
                plotPanel(height: primaryPanelHeight)
                townProjectsPanel(height: secondaryPanelHeight)
            }
            .frame(width: columnWidth, height: height, alignment: .top)
        }
        .frame(height: height, alignment: .top)
    }

    private func secondRow(height: CGFloat, columnWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: GameLayout.panelSpacing) {
            spellbookPanel(height: height)
                .frame(width: columnWidth, height: height, alignment: .top)
            inventoryPanel(height: height)
                .frame(width: columnWidth, height: height, alignment: .top)
            questsPanel(height: height)
                .frame(width: columnWidth, height: height, alignment: .top)
        }
        .frame(height: height, alignment: .top)
    }

    private func characterPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Character",
            systemImage: "person.text.rectangle",
            iconTint: LiquidGlassPalette.accentCyan,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 6) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                CompactInfoRow(label: "Name", value: game.character.name)
                                CompactInfoRow(label: "Race", value: game.character.race)
                                CompactInfoRow(label: "Class", value: game.character.characterClass)
                                CompactInfoRow(label: "Level", value: "\(game.level)")
                                CompactInfoRow(label: "Honor", value: "\(game.honorLevel)")
                                CompactInfoRow(label: "Prestige", value: "\(game.prestigeLevel)")
                                CompactInfoRow(label: "Gold", value: "\(game.gold)")
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                            CharacterAvatarBadge(
                                race: game.character.race,
                                className: game.character.characterClass
                            )
                            .frame(width: 86)
                        }

                        Color.clear
                            .frame(height: 6)
                        Divider().overlay(Color.white.opacity(0.1))
                        Color.clear
                            .frame(height: 4)

                        StatDetailRow(label: "STR", value: game.strDisplay)
                        StatDetailRow(label: "CON", value: game.conDisplay)
                        StatDetailRow(label: "DEX", value: game.dexDisplay)
                        StatDetailRow(label: "INT", value: game.intDisplay)
                        StatDetailRow(label: "WIS", value: game.wisDisplay)
                        StatDetailRow(label: "CHA", value: game.chaDisplay)
                        StatTextRow(label: "ATK", value: game.attack)
                        StatTextRow(label: "DEF", value: game.defense)

                        ResourceBarRow(
                            label: "HP",
                            progress: game.hpProgress,
                            value: "\(game.currentHPInt)/\(game.hpMax)",
                            color: LiquidGlassPalette.accentRed
                        )
                        ResourceBarRow(
                            label: "MP",
                            progress: game.mpProgress,
                            value: "\(game.currentMPInt)/\(game.mpMax)",
                            color: LiquidGlassPalette.accentMagenta
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider().overlay(Color.white.opacity(0.1))

                ProgressView(value: game.experienceProgress)
                    .tint(LiquidGlassPalette.accentCyan.opacity(0.9))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func equipmentPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Equipment",
            systemImage: "shield.fill",
            iconTint: LiquidGlassPalette.accentOrange,
            height: height
        ) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(EquipmentSlot.allCases, id: \.self) { slot in
                            HStack(spacing: 6) {
                                Text(slot.rawValue)
                                    .foregroundStyle(LiquidGlassPalette.secondaryText)
                                    .frame(width: 82, alignment: .leading)
                                Text(game.equipment[slot]?.name ?? "-")
                                    .foregroundStyle(LiquidGlassPalette.primaryText)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .font(.callout)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id(Self.equipmentBottomAnchorID)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .onAppear {
                    scrollToBottom(using: proxy, anchorID: Self.equipmentBottomAnchorID, animated: false)
                }
                .onChange(of: equipmentScrollToken) { _, _ in
                    scrollToBottom(using: proxy, anchorID: Self.equipmentBottomAnchorID)
                }
            }
        }
    }

    private func arenaPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Arena",
            systemImage: "trophy.fill",
            iconTint: LiquidGlassPalette.accentRed,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 4) {
                InfoRow(label: "Rating", value: "\(game.arenaRating)")
                InfoRow(label: "League", value: game.arenaLeague.rawValue)
                HStack(spacing: 4) {
                    Text("Rules")
                        .foregroundStyle(LiquidGlassPalette.secondaryText)
                        .frame(width: 70, alignment: .leading)
                    Text(game.arenaModifiersDisplay)
                        .foregroundStyle(LiquidGlassPalette.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.callout)

                let roundValue = game.isArenaActive
                    ? "\(game.romanNumeral(max(1, game.arenaRound)))/\(game.romanNumeral(max(1, game.arenaRoundsTotal)))"
                    : "-"
                HStack(spacing: 4) {
                    Text("Record")
                        .foregroundStyle(LiquidGlassPalette.secondaryText)
                        .frame(width: 70, alignment: .leading)

                    HStack(spacing: 10) {
                        Text("W: \(game.arenaWins) L: \(game.arenaLosses)")
                            .foregroundStyle(LiquidGlassPalette.primaryText)
                            .lineLimit(1)
                            .layoutPriority(1)
                            .minimumScaleFactor(0.92)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 4) {
                            Text("Round")
                                .foregroundStyle(LiquidGlassPalette.secondaryText)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            Text(roundValue)
                                .font(.callout.monospaced())
                                .foregroundStyle(LiquidGlassPalette.primaryText)
                                .lineLimit(1)
                                .frame(width: 54, alignment: .leading)
                        }
                        .frame(width: 102, alignment: .leading)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.callout)
            }
        }
    }

    private func plotPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Plot",
            systemImage: "map.fill",
            iconTint: LiquidGlassPalette.accentBlue,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 6) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(game.plotItems) { item in
                                ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(Self.plotBottomAnchorID)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .onAppear {
                        scrollToBottom(using: proxy, anchorID: Self.plotBottomAnchorID, animated: false)
                    }
                    .onChange(of: plotScrollToken) { _, _ in
                        scrollToBottom(using: proxy, anchorID: Self.plotBottomAnchorID)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider().overlay(Color.white.opacity(0.1))

                ProgressView(value: game.actProgress)
                    .tint(LiquidGlassPalette.accentBlue.opacity(0.85))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func townProjectsPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Town Projects",
            systemImage: "building.2.fill",
            iconTint: LiquidGlassPalette.accentOrange,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 4) {
                InfoRow(label: "Status", value: game.townProjectStatusLabel)
                InfoRow(label: "Focus", value: game.townProjectFocusLabel)
                HStack(spacing: 4) {
                    Text("Progress")
                        .foregroundStyle(LiquidGlassPalette.secondaryText)
                        .frame(width: 70, alignment: .leading)
                    ProgressView(value: game.townProjectProgressValue)
                        .progressViewStyle(.linear)
                        .controlSize(.mini)
                        .tint(LiquidGlassPalette.accentOrange.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 10)
                }
                .font(.callout)
                HStack(spacing: 4) {
                    Text("Bonus")
                        .foregroundStyle(LiquidGlassPalette.secondaryText)
                        .frame(width: 70, alignment: .leading)
                    Text(game.townProjectBonusLabel)
                        .foregroundStyle(LiquidGlassPalette.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.callout)
            }
        }
    }

    private func spellbookPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Spellbook",
            systemImage: "book.closed.fill",
            iconTint: LiquidGlassPalette.accentPurple,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("Spell")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Lvl")
                        .frame(width: 28, alignment: .trailing)
                    Text("MP")
                        .frame(width: 30, alignment: .trailing)
                }
                .font(.callout)
                .foregroundStyle(LiquidGlassPalette.mutedText)

                Divider().overlay(Color.white.opacity(0.1))

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            if game.knownSpells.isEmpty {
                                Text("No known spells")
                                    .font(.callout)
                                    .foregroundStyle(LiquidGlassPalette.mutedText)
                            } else {
                                ForEach(game.knownSpells) { spell in
                                    HStack(spacing: 6) {
                                        Text(spell.name)
                                            .foregroundStyle(LiquidGlassPalette.primaryText)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(game.romanNumeral(spell.level))
                                            .foregroundStyle(LiquidGlassPalette.secondaryText)
                                            .frame(width: 28, alignment: .trailing)
                                        Text("\(game.spellManaCost(for: spell))")
                                            .monospacedDigit()
                                            .foregroundStyle(LiquidGlassPalette.secondaryText)
                                            .frame(width: 30, alignment: .trailing)
                                    }
                                    .font(.callout)
                                }
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(Self.spellbookBottomAnchorID)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .onAppear {
                        scrollToBottom(using: proxy, anchorID: Self.spellbookBottomAnchorID, animated: false)
                    }
                    .onChange(of: spellbookScrollToken) { _, _ in
                        scrollToBottom(using: proxy, anchorID: Self.spellbookBottomAnchorID)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func inventoryPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Inventory",
            systemImage: "archivebox.fill",
            iconTint: LiquidGlassPalette.accentGreen,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("Item")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Qty")
                        .frame(width: 30, alignment: .trailing)
                }
                .font(.callout)
                .foregroundStyle(LiquidGlassPalette.mutedText)

                Divider().overlay(Color.white.opacity(0.1))

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(game.inventory) { item in
                                HStack(spacing: 6) {
                                    Text(item.name)
                                        .foregroundStyle(LiquidGlassPalette.primaryText)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("1")
                                        .monospacedDigit()
                                        .foregroundStyle(LiquidGlassPalette.secondaryText)
                                        .frame(width: 30, alignment: .trailing)
                                }
                                .font(.callout)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(Self.inventoryBottomAnchorID)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .onAppear {
                        scrollToBottom(using: proxy, anchorID: Self.inventoryBottomAnchorID, animated: false)
                    }
                    .onChange(of: inventoryScrollToken) { _, _ in
                        scrollToBottom(using: proxy, anchorID: Self.inventoryBottomAnchorID)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider().overlay(Color.white.opacity(0.1))

                ProgressView(value: game.inventoryProgress)
                    .tint(LiquidGlassPalette.accentGreen.opacity(0.85))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func questsPanel(height: CGFloat) -> some View {
        SectionPanel(
            title: "Quests",
            systemImage: "checklist",
            iconTint: LiquidGlassPalette.accentPurple,
            height: height
        ) {
            VStack(alignment: .leading, spacing: 6) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(game.questItems) { item in
                                ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(Self.questBottomAnchorID)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .onAppear {
                        scrollToBottom(using: proxy, anchorID: Self.questBottomAnchorID, animated: false)
                    }
                    .onChange(of: questScrollToken) { _, _ in
                        scrollToBottom(using: proxy, anchorID: Self.questBottomAnchorID)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider().overlay(Color.white.opacity(0.1))

                ProgressView(value: game.questProgress)
                    .tint(LiquidGlassPalette.accentPurple.opacity(0.9))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func battleFeed(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(LiquidGlassPalette.accentOrange)
                Text("Battle Feed")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(LiquidGlassPalette.primaryText)
                Spacer(minLength: 0)
                Text(String(format: "Speed x%.0f", game.gameSpeedMultiplier))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(LiquidGlassPalette.mutedText)
            }

            Text(game.logLine)
                .font(.callout)
                .lineLimit(1)
                .foregroundStyle(LiquidGlassPalette.secondaryText)

            ProgressView(value: game.battleProgressValue)
                .tint(LiquidGlassPalette.accentOrange.opacity(0.9))
                .frame(height: 12)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: height, alignment: .topLeading)
        .clipped()
        .liquidGlassCard(cornerRadius: 12)
    }
}

private struct CharacterAvatarBadge: View {
    let race: String
    let className: String

    private var raceAssetName: String {
        RacePortraitCatalog.raceAssetName(for: race)
    }

    private var classSymbol: String {
        RacePortraitCatalog.classSymbol(for: className)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.28))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                }
                .overlay {
                    Image(raceAssetName)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

            Circle()
                .fill(Color.black.opacity(0.34))
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: classSymbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.95))
                }
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                }
                .padding(6)
        }
        .frame(height: 122)
    }
}
