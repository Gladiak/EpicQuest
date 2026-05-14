import SwiftUI
#if os(macOS)
import AppKit
#endif

#if os(macOS)
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
#endif

@main
struct EpicQuestApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: UIConstants.windowWidth, height: UIConstants.windowHeight)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .newItem) {
                Divider()
                Button("New Game") {
                    NotificationCenter.default.post(name: .progressQuestStartNewGame, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
            CommandMenu("Developer") {
                Button("Decrease Speed") {
                    NotificationCenter.default.post(name: .progressQuestDecreaseGameSpeed, object: nil)
                }
                .keyboardShortcut("-", modifiers: [.command, .option])

                Button("Increase Speed") {
                    NotificationCenter.default.post(name: .progressQuestIncreaseGameSpeed, object: nil)
                }
                .keyboardShortcut("+", modifiers: [.command, .option])

                Divider()

                Button("Reset Speed (Default)") {
                    NotificationCenter.default.post(name: .progressQuestResetGameSpeed, object: nil)
                }
                .keyboardShortcut("0", modifiers: [.command, .option])
            }
        }
    }
}
