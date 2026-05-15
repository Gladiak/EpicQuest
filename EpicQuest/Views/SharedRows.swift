import SwiftUI

private enum RowLayout {
    static let labelColumnWidth: CGFloat = 70
    static let valueColumnWidth: CGFloat = 132
    static let statDetailColumnWidth: CGFloat = 132
    static let checkmarkColumnWidth: CGFloat = 16
}

private enum GlassLayout {
    static let panelCornerRadius: CGFloat = 12
    static let panelPadding: CGFloat = 8
    static let sectionSpacing: CGFloat = 6
}

private struct LiquidGlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                LiquidGlassPalette.panelTop.opacity(0.78),
                                LiquidGlassPalette.panelBottom.opacity(0.76)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .background(.regularMaterial, in: shape)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(LiquidGlassPalette.panelStroke.opacity(0.55), lineWidth: 0.7)
            }
            .shadow(color: Color.black.opacity(0.14), radius: 4, x: 0, y: 1)
    }
}

extension View {
    func liquidGlassCard(cornerRadius: CGFloat = GlassLayout.panelCornerRadius) -> some View {
        modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius))
    }
}

struct SectionPanel<Content: View>: View {
    let title: String
    let systemImage: String?
    let iconTint: Color
    let titleFont: Font
    let height: CGFloat?
    @ViewBuilder let content: Content

    init(title: String, systemImage: String? = nil, iconTint: Color = LiquidGlassPalette.sectionIconGlyph, titleFont: Font = .headline, height: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.iconTint = iconTint
        self.titleFont = titleFont
        self.height = height
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GlassLayout.sectionSpacing) {
            HStack(spacing: 7) {
                if let systemImage {
                    SectionHeaderIcon(systemImage: systemImage, tint: iconTint)
                }
                Text(title)
                    .font(titleFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(LiquidGlassPalette.primaryText)
                Spacer(minLength: 0)
                Circle()
                    .fill(LiquidGlassPalette.mutedText)
                    .frame(width: 7, height: 7)
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(GlassLayout.panelPadding)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: height, alignment: .topLeading)
        .clipped()
        .liquidGlassCard()
    }
}

private struct SectionHeaderIcon: View {
    let systemImage: String
    let tint: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.headline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(width: 20, alignment: .leading)
    }
}

struct ReadOnlyCheckRow: View {
    let label: String
    let isChecked: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isChecked ? "diamond.fill" : "diamond")
                .font(.callout)
                .frame(width: RowLayout.checkmarkColumnWidth, alignment: .leading)
                .foregroundStyle(isChecked ? LiquidGlassPalette.accentCyan : LiquidGlassPalette.mutedText)
            Text(label)
                .font(.callout)
                .lineLimit(1)
                .foregroundStyle(LiquidGlassPalette.secondaryText)
            Spacer(minLength: 0)
        }
    }
}

struct SelectionCheckboxRow: View {
    let label: String
    let isSelected: Bool
    let textColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? LiquidGlassPalette.accentCyan : LiquidGlassPalette.mutedText)
                Text(label)
                    .foregroundStyle(isSelected ? textColor : textColor.opacity(0.88))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .font(.callout)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? LiquidGlassPalette.accentCyan.opacity(0.22) : Color.white.opacity(0.04))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isSelected ? LiquidGlassPalette.accentCyan.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

extension SelectionCheckboxRow {
    init(label: String, isSelected: Bool, action: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.textColor = LiquidGlassPalette.primaryText
        self.action = action
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(LiquidGlassPalette.secondaryText)
                .frame(width: RowLayout.labelColumnWidth, alignment: .leading)
            Text(value)
                .foregroundStyle(LiquidGlassPalette.primaryText)
                .lineLimit(1)
                .frame(width: RowLayout.valueColumnWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
        .font(.callout)
    }
}

struct CompactInfoRow: View {
    let label: String
    let value: String
    var labelWidth: CGFloat = 52

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .foregroundStyle(LiquidGlassPalette.secondaryText)
                .frame(width: labelWidth, alignment: .leading)
            Text(value)
                .foregroundStyle(LiquidGlassPalette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
        }
        .font(.callout)
    }
}

struct ResourceBarRow: View {
    let label: String
    let progress: Double
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .frame(width: RowLayout.labelColumnWidth, alignment: .leading)
                .foregroundStyle(LiquidGlassPalette.secondaryText)

            GlassProgressBar(progress: progress, color: color)
                .frame(maxWidth: .infinity)

            Text(value)
                .monospacedDigit()
                .foregroundStyle(LiquidGlassPalette.primaryText)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.callout)
    }
}

private struct GlassProgressBar: View {
    let progress: Double
    let color: Color

    private var clamped: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = max(0, proxy.size.width * clamped)

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.16))
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.95), color.opacity(0.68)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width)
            }
        }
        .frame(height: 10)
    }
}

struct StatRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(LiquidGlassPalette.secondaryText)
            Spacer()
            Text("\(value)")
                .monospacedDigit()
                .foregroundStyle(LiquidGlassPalette.primaryText)
        }
        .font(.callout)
    }
}

struct StatTextRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(LiquidGlassPalette.secondaryText)
                .frame(width: RowLayout.labelColumnWidth, alignment: .leading)
            Text("\(value)")
                .monospacedDigit()
                .foregroundStyle(LiquidGlassPalette.primaryText)
                .frame(width: RowLayout.valueColumnWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
        .font(.callout)
    }
}

struct StatDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(LiquidGlassPalette.secondaryText)
                .frame(width: RowLayout.labelColumnWidth, alignment: .leading)
            Text(value)
                .font(.callout.monospacedDigit())
                .foregroundStyle(LiquidGlassPalette.primaryText)
                .lineLimit(1)
                .frame(width: RowLayout.statDetailColumnWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
        .font(.callout)
    }
}
