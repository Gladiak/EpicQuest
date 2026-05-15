import SwiftUI

private enum GameLayout {
    static let panelSpacing: CGFloat = 8
    static let topRowRatio: CGFloat = 0.54
    static let minTopRowHeight: CGFloat = 240
    static let minBottomRowHeight: CGFloat = 170
}

struct GameView: View {
    @Binding var game: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: GameLayout.panelSpacing) {
                leftColumn
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                middleColumn
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                rightColumn
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
            .liquidGlassCard(cornerRadius: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(8)
    }

    private func rowHeights(for columnHeight: CGFloat) -> (top: CGFloat, bottom: CGFloat) {
        let availableHeight = max(0, columnHeight - GameLayout.panelSpacing)
        guard availableHeight > 0 else { return (0, 0) }

        // If the window gets compact, keep proportional split to avoid hard clipping.
        if availableHeight < (GameLayout.minTopRowHeight + GameLayout.minBottomRowHeight) {
            let top = availableHeight * GameLayout.topRowRatio
            return (top, max(0, availableHeight - top))
        }

        let desiredTop = availableHeight * GameLayout.topRowRatio
        let maxTop = availableHeight - GameLayout.minBottomRowHeight
        let top = min(max(desiredTop, GameLayout.minTopRowHeight), maxTop)
        let bottom = max(0, availableHeight - top)
        return (top, bottom)
    }

    private var leftColumn: some View {
        GeometryReader { proxy in
            let heights = rowHeights(for: proxy.size.height)

            VStack(spacing: GameLayout.panelSpacing) {
                SectionPanel(title: "Character", systemImage: "person.text.rectangle", iconTint: LiquidGlassPalette.accentCyan) {
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
                .frame(maxWidth: .infinity)
                .frame(height: heights.top)

                SectionPanel(title: "Spellbook", systemImage: "book.closed.fill", iconTint: LiquidGlassPalette.accentPurple) {
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
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: heights.bottom)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
    }

    private var middleColumn: some View {
        GeometryReader { proxy in
            let heights = rowHeights(for: proxy.size.height)
            let topAvailable = heights.top
            let minArenaHeight: CGFloat = 74
            let desiredArenaHeight: CGFloat = 108
            let maxEquipmentHeight = max(0, topAvailable - GameLayout.panelSpacing - minArenaHeight)
            let equipmentHeight = max(0, min(maxEquipmentHeight, topAvailable - GameLayout.panelSpacing - desiredArenaHeight))
            let arenaHeight = max(0, topAvailable - equipmentHeight - GameLayout.panelSpacing)

            VStack(spacing: GameLayout.panelSpacing) {
                SectionPanel(title: "Equipment", systemImage: "shield.fill", iconTint: LiquidGlassPalette.accentOrange) {
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
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: equipmentHeight)

                SectionPanel(title: "Arena", systemImage: "trophy.fill", iconTint: LiquidGlassPalette.accentRed) {
                    VStack(alignment: .leading, spacing: 4) {
                        InfoRow(label: "Rating", value: "\(game.arenaRating)")
                        InfoRow(label: "League", value: game.arenaLeague.rawValue)
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
                .frame(maxWidth: .infinity)
                .frame(height: arenaHeight)

                SectionPanel(title: "Inventory", systemImage: "archivebox.fill", iconTint: LiquidGlassPalette.accentGreen) {
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
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Divider().overlay(Color.white.opacity(0.1))

                        ProgressView(value: game.inventoryProgress)
                            .tint(LiquidGlassPalette.accentGreen.opacity(0.85))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: heights.bottom)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
    }

    private var rightColumn: some View {
        GeometryReader { proxy in
            let heights = rowHeights(for: proxy.size.height)

            VStack(spacing: GameLayout.panelSpacing) {
                SectionPanel(title: "Plot", systemImage: "map.fill", iconTint: LiquidGlassPalette.accentBlue) {
                    VStack(alignment: .leading, spacing: 6) {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(game.plotItems) { item in
                                    ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Divider().overlay(Color.white.opacity(0.1))

                        ProgressView(value: game.actProgress)
                            .tint(LiquidGlassPalette.accentBlue.opacity(0.85))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: heights.top)

                SectionPanel(title: "Quests", systemImage: "checklist", iconTint: LiquidGlassPalette.accentPurple) {
                    VStack(alignment: .leading, spacing: 6) {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(game.questItems) { item in
                                    ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Divider().overlay(Color.white.opacity(0.1))

                        ProgressView(value: game.questProgress)
                            .tint(LiquidGlassPalette.accentPurple.opacity(0.9))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: heights.bottom)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
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
