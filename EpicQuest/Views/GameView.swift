import SwiftUI

struct GameView: View {
    @Binding var game: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 6) {
                VStack(spacing: 6) {
                    SectionPanel(title: "Character Sheet", height: 258) {
                        VStack(alignment: .leading, spacing: 2) {
                            InfoRow(label: "Name", value: game.character.name)
                            InfoRow(label: "Race", value: game.character.race)
                            InfoRow(label: "Class", value: game.character.characterClass)
                            InfoRow(label: "Level", value: "\(game.level)")
                            StatTextRow(label: "STR", value: game.character.str)
                            StatTextRow(label: "CON", value: game.character.con)
                            StatTextRow(label: "DEX", value: game.character.dex)
                            StatTextRow(label: "INT", value: game.character.int)
                            StatTextRow(label: "WIS", value: game.character.wis)
                            StatTextRow(label: "CHA", value: game.character.cha)
                            StatTextRow(label: "ATK", value: game.attack)
                            StatTextRow(label: "DEF", value: game.defense)
                            InfoRow(label: "HP Max", value: "\(game.hpMax)")
                            InfoRow(label: "MP Max", value: "\(game.mpMax)")
                        }
                    }

                    SectionPanel(title: "Experience", height: 56) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(game.experience)/\(game.experienceToNextLevel)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ProgressView(value: game.experienceProgress)
                        }
                    }

                    SectionPanel(title: "Spell Book") {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Spell")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Divider()
                            Text("-")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack(spacing: 6) {
                    SectionPanel(title: "Equipment", height: 198) {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(EquipmentSlot.allCases, id: \.self) { slot in
                                HStack(spacing: 6) {
                                    Text(slot.rawValue)
                                        .frame(width: 56, alignment: .leading)
                                    Text(game.equipment[slot]?.name ?? "-")
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                }
                                .font(.caption)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }

                    SectionPanel(title: "Inventory") {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("Item")
                                Spacer()
                                Text("Qty")
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            Divider()
                            ForEach(game.inventory.prefix(9)) { item in
                                HStack {
                                    Text(item.name)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("1")
                                }
                                .font(.caption)
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxHeight: .infinity)

                    SectionPanel(title: "Encumbrance", height: 56) {
                        ProgressView(value: game.inventoryProgress)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                VStack(spacing: 6) {
                    SectionPanel(title: "Plot Development", height: 222) {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(game.plotItems) { item in
                                ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                            }
                            Spacer()
                            ProgressView(value: game.actProgress)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }

                    SectionPanel(title: "Quests") {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(game.questItems) { item in
                                ReadOnlyCheckRow(label: item.title, isChecked: item.isCompleted)
                            }
                            Text(game.currentMonster)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
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

            ProgressView(value: game.battleProgress)
                .frame(height: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
