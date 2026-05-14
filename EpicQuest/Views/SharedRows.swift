import SwiftUI

private enum RowLayout {
    static let labelColumnWidth: CGFloat = 64
    static let valueColumnWidth: CGFloat = 116
    static let checkmarkColumnWidth: CGFloat = 12
}

private enum SectionPanelLayout {
    static let headerSpacing: CGFloat = 4
    static let contentPadding: CGFloat = 8
}

struct SectionPanel<Content: View>: View {

    let title: String
    let height: CGFloat?
    @ViewBuilder let content: Content

    init(title: String, height: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.height = height
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SectionPanelLayout.headerSpacing) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupBox {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(SectionPanelLayout.contentPadding)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
        }
    }
}

struct ReadOnlyCheckRow: View {
    let label: String
    let isChecked: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .font(.caption2)
                .frame(width: RowLayout.checkmarkColumnWidth, alignment: .leading)
                .foregroundStyle(isChecked ? Color.accentColor : Color.secondary)
            Text(label)
                .font(.caption)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
    }
}

struct SelectionCheckboxRow: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                Text(label)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .frame(width: RowLayout.labelColumnWidth, alignment: .leading)
            Text(value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: RowLayout.valueColumnWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
        .font(.caption)
    }
}

struct StatRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)").monospacedDigit()
        }
        .font(.caption)
    }
}

struct StatTextRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .frame(width: RowLayout.labelColumnWidth, alignment: .leading)
            Text("\(value)")
                .monospacedDigit()
                .frame(width: RowLayout.valueColumnWidth, alignment: .leading)
            Spacer(minLength: 0)
        }
        .font(.caption)
    }
}
