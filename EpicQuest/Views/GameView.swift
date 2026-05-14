import SwiftUI

private enum GameLayout {
    static let panelSpacing: CGFloat = 16
    static let topRowPanelHeight: CGFloat = 320
}

struct GameView: View {
    @Binding var game: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 6) {
                VStack(spacing: GameLayout.panelSpacing) {
                    SectionPanel(title: "Character Sheet", height: GameLayout.topRowPanelHeight) {
                        VStack(alignment: .leading, spacing: 3) {
                            InfoRow(label: "Name", value: game.character.name)
                            InfoRow(label: "Race", value: game.character.race)
                            InfoRow(label: "Class", value: game.character.characterClass)
                            InfoRow(label: "Level", value: "\(game.level)")
                            InfoRow(label: "Gold", value: "\(game.gold)")
                            Divider()
                                .padding(.vertical, 2)
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
                                color: .red
                            )
                            ResourceBarRow(
                                label: "MP",
                                progress: game.mpProgress,
                                value: "\(game.currentMPInt)/\(game.mpMax)",
                                color: Color(red: 1, green: 0, blue: 1)
                            )
                            Spacer(minLength: 0)
                            Divider()
                            ProgressView(value: game.experienceProgress)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    SectionPanel(title: "Spell Book") {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("Spell")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Lvl")
                                    .frame(width: 28, alignment: .trailing)
                                Text("MP")
                                    .frame(width: 28, alignment: .trailing)
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            Divider()

                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 3) {
                                    if game.knownSpells.isEmpty {
                                        Text("No known spells")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        ForEach(game.knownSpells) { spell in
                                            HStack(spacing: 6) {
                                                Text(spell.name)
                                                    .lineLimit(1)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(game.romanNumeral(spell.level))
                                                    .frame(width: 28, alignment: .trailing)
                                                Text("\(game.spellManaCost(for: spell))")
                                                    .monospacedDigit()
                                                    .frame(width: 28, alignment: .trailing)
                                            }
                                            .font(.caption)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack(spacing: GameLayout.panelSpacing) {
                    SectionPanel(title: "Equipment", height: GameLayout.topRowPanelHeight) {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(EquipmentSlot.allCases, id: \.self) { slot in
                                HStack(spacing: 6) {
                                    Text(slot.rawValue)
                                        .frame(width: 82, alignment: .leading)
                                    Text(game.equipment[slot]?.name ?? "-")
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .font(.caption)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }

                    SectionPanel(title: "Inventory") {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("Item")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Qty")
                                    .frame(width: 28, alignment: .trailing)
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            Divider()
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 2) {
                                    ForEach(game.inventory) { item in
                                        HStack(spacing: 6) {
                                            Text(item.name)
                                                .lineLimit(1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("1")
                                                .monospacedDigit()
                                                .frame(width: 28, alignment: .trailing)
                                        }
                                        .font(.caption)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Divider()
                            ProgressView(value: game.inventoryProgress)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack(spacing: GameLayout.panelSpacing) {
                    SectionPanel(title: "Plot Development", height: GameLayout.topRowPanelHeight) {
                        VStack(alignment: .leading, spacing: 3) {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 3) {
                                    ForEach(game.plotItems) { item in
                                        ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Divider()
                            ProgressView(value: game.actProgress)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }

                    SectionPanel(title: "Quests") {
                        VStack(alignment: .leading, spacing: 3) {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 3) {
                                    ForEach(game.questItems) { item in
                                        ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Divider()
                            ProgressView(value: game.questProgress)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            Text(game.logLine)
                .font(.caption)
                .lineLimit(1)

            ProgressView(value: game.battleProgressValue)
                .frame(height: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
