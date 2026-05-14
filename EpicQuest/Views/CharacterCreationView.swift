import SwiftUI

struct CharacterCreationView: View {
    @Binding var game: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("New Character")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(alignment: .top, spacing: 10) {
                GroupBox("General") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            TextField("Name", text: $game.character.name)
                            Button {
                                game.rollCharacterName()
                            } label: {
                                Text("🎲")
                            }
                            .buttonStyle(.plain)
                            .help("Randomize name")
                            .accessibilityLabel("Randomize name")
                        }

                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Race")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ForEach(GameData.races, id: \.self) { race in
                                    SelectionCheckboxRow(label: race, isSelected: game.character.race == race) {
                                        game.character.race = race
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Class")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ForEach(GameData.classes, id: \.self) { clazz in
                                    let archetype = GameData.classArchetype(for: clazz)
                                    SelectionCheckboxRow(
                                        label: GameData.classLabel(for: clazz),
                                        isSelected: game.character.characterClass == clazz,
                                        textColor: archetype == .warrior ? .orange : .blue
                                    ) {
                                        game.character.characterClass = clazz
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .padding(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                GroupBox("Attributes") {
                    VStack(alignment: .leading, spacing: 6) {
                        StatRow(label: "STR", value: game.character.str)
                        StatRow(label: "CON", value: game.character.con)
                        StatRow(label: "DEX", value: game.character.dex)
                        StatRow(label: "INT", value: game.character.int)
                        StatRow(label: "WIS", value: game.character.wis)
                        StatRow(label: "CHA", value: game.character.cha)

                        Divider()
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("\(game.character.totalStats)")
                                .monospacedDigit()
                                .foregroundStyle(game.character.totalStats > 80 ? Color.red : Color.primary)
                        }
                        .font(.caption)

                        Spacer()

                        HStack(spacing: 8) {
                            Button("Roll") { game.rollStats() }
                                .frame(maxWidth: .infinity)
                            Button("Unroll") { game.unrollStats() }
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(8)
                }
                .frame(width: 250)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            HStack {
                Spacer()
                Button("Start Adventure") {
                    game.startAdventure()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
    }
}
