import SwiftUI

enum UIConstants {
    static let windowWidth: CGFloat = 840
    static let windowHeight: CGFloat = 820
}

enum LiquidGlassPalette {
    static let backgroundTop = Color(red: 0.17, green: 0.17, blue: 0.18)
    static let backgroundMid = Color(red: 0.15, green: 0.15, blue: 0.16)
    static let backgroundBottom = Color(red: 0.13, green: 0.13, blue: 0.14)

    static let panelTop = Color(red: 0.28, green: 0.29, blue: 0.32)
    static let panelBottom = Color(red: 0.23, green: 0.24, blue: 0.27)
    static let panelStroke = Color.white.opacity(0.16)
    static let panelInnerStroke = Color.white.opacity(0.06)

    static let primaryText = Color.white.opacity(0.93)
    static let secondaryText = Color.white.opacity(0.72)
    static let mutedText = Color.white.opacity(0.52)

    static let sectionIconTop = Color.white.opacity(0.34)
    static let sectionIconBottom = Color.white.opacity(0.16)
    static let sectionIconGlyph = Color.white.opacity(0.9)

    static let accentBright = Color.white.opacity(0.88)
    static let accentMedium = Color.white.opacity(0.72)
    static let accentSoft = Color.white.opacity(0.58)
    static let accentDim = Color.white.opacity(0.44)

    static let accentCyan = Color(red: 0.55, green: 0.88, blue: 0.97)
    static let accentBlue = Color(red: 0.60, green: 0.73, blue: 0.96)
    static let accentPurple = Color(red: 0.76, green: 0.66, blue: 0.94)
    static let accentOrange = Color(red: 0.97, green: 0.73, blue: 0.53)
    static let accentGreen = Color(red: 0.59, green: 0.84, blue: 0.64)
    static let accentRed = Color(red: 0.95, green: 0.58, blue: 0.62)
    static let accentMagenta = Color(red: 0.86, green: 0.61, blue: 0.93)
}

extension Notification.Name {
    static let progressQuestStartNewGame = Notification.Name("progressQuestStartNewGame")
    static let progressQuestIncreaseGameSpeed = Notification.Name("progressQuestIncreaseGameSpeed")
    static let progressQuestDecreaseGameSpeed = Notification.Name("progressQuestDecreaseGameSpeed")
    static let progressQuestResetGameSpeed = Notification.Name("progressQuestResetGameSpeed")
}
