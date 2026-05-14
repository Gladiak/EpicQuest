import SwiftUI

enum UIConstants {
    static let windowSize: CGFloat = 760
}

extension Notification.Name {
    static let progressQuestStartNewGame = Notification.Name("progressQuestStartNewGame")
    static let progressQuestIncreaseGameSpeed = Notification.Name("progressQuestIncreaseGameSpeed")
    static let progressQuestDecreaseGameSpeed = Notification.Name("progressQuestDecreaseGameSpeed")
    static let progressQuestResetGameSpeed = Notification.Name("progressQuestResetGameSpeed")
}
