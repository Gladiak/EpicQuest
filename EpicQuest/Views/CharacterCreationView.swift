import SwiftUI

private enum CreationLayout {
    static let panelSpacing: CGFloat = 12
    static let sidePanelWidth: CGFloat = 260
}

struct CharacterCreationView: View {
    @Binding var game: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: CreationLayout.panelSpacing) {
            header

            HStack(alignment: .top, spacing: CreationLayout.panelSpacing) {
                generalPanel
                attributesPanel
                    .frame(width: CreationLayout.sidePanelWidth)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            HStack {
                Spacer()

                Button {
                    game.startAdventure()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Start Adventure")
                            .fontWeight(.semibold)
                    }
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [LiquidGlassPalette.accentCyan.opacity(0.86), LiquidGlassPalette.accentBlue.opacity(0.84)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule(style: .continuous)
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(12)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "shield.fill")
                .foregroundStyle(LiquidGlassPalette.accentCyan.opacity(0.95))
                .font(.title3.weight(.semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text("New Character")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(LiquidGlassPalette.primaryText)
                Text("Choose race, class and roll your destiny.")
                    .font(.callout)
                    .foregroundStyle(LiquidGlassPalette.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }

    private var generalPanel: some View {
        SectionPanel(title: "General", systemImage: "person.crop.square", iconTint: LiquidGlassPalette.accentCyan) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TextField("Name", text: $game.character.name)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                        }
                        .foregroundStyle(LiquidGlassPalette.primaryText)

                    Button {
                        game.rollCharacterName()
                    } label: {
                        Image(systemName: "dice.fill")
                            .font(.headline)
                            .foregroundStyle(LiquidGlassPalette.accentCyan)
                            .frame(width: 36, height: 36)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .help("Randomize name")
                    .accessibilityLabel("Randomize name")
                }

                HStack(alignment: .top, spacing: 10) {
                    choiceColumn(title: "Race") {
                        ForEach(GameData.races, id: \.self) { race in
                            SelectionCheckboxRow(label: race, isSelected: game.character.race == race) {
                                game.character.race = race
                            }
                        }
                    }

                    choiceColumn(title: "Class") {
                        ForEach(GameData.classes, id: \.self) { clazz in
                            let archetype = GameData.classArchetype(for: clazz)
                            SelectionCheckboxRow(
                                label: GameData.classLabel(for: clazz),
                                isSelected: game.character.characterClass == clazz,
                                textColor: archetype == .warrior ? LiquidGlassPalette.accentOrange : LiquidGlassPalette.accentBlue
                            ) {
                                game.character.characterClass = clazz
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var attributesPanel: some View {
        SectionPanel(title: "Attributes", systemImage: "chart.bar.fill", iconTint: LiquidGlassPalette.accentOrange, titleFont: .title3) {
            VStack(alignment: .leading, spacing: 6) {
                StatRow(label: "STR", value: game.character.str)
                StatRow(label: "CON", value: game.character.con)
                StatRow(label: "DEX", value: game.character.dex)
                StatRow(label: "INT", value: game.character.int)
                StatRow(label: "WIS", value: game.character.wis)
                StatRow(label: "CHA", value: game.character.cha)

                Divider().overlay(Color.white.opacity(0.1))

                HStack {
                    Text("Total")
                        .foregroundStyle(LiquidGlassPalette.secondaryText)
                    Spacer()
                    Text("\(game.character.totalStats)")
                        .monospacedDigit()
                        .foregroundStyle(game.character.totalStats > 80 ? LiquidGlassPalette.accentRed.opacity(0.95) : LiquidGlassPalette.primaryText)
                }
                .font(.callout)

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    CreationActionButton(
                        title: "Roll",
                        icon: "arrow.triangle.2.circlepath",
                        tint: LiquidGlassPalette.accentCyan
                    ) {
                        game.rollStats()
                    }

                    CreationActionButton(
                        title: "Unroll",
                        icon: "arrow.uturn.backward",
                        tint: LiquidGlassPalette.accentOrange
                    ) {
                        game.unrollStats()
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func choiceColumn<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.callout)
                .foregroundStyle(LiquidGlassPalette.mutedText)
                .padding(.horizontal, 2)

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .liquidGlassCard(cornerRadius: 12)
    }
}

private struct CreationActionButton: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.callout)
            .foregroundStyle(Color.white.opacity(0.95))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.8), tint.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
