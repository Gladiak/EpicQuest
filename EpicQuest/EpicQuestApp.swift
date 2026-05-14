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

    private let fixedSize = CGSize(width: 760, height: 760)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: fixedSize.width, height: fixedSize.height)
        }
        .defaultSize(width: fixedSize.width, height: fixedSize.height)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Divider()
                Button("New Game") {
                    NotificationCenter.default.post(name: .progressQuestStartNewGame, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
    }
}
