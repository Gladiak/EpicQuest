import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @State private var game = GameState()
    @Environment(\.scenePhase) private var scenePhase

    private var isRunningPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            if game.phase == .characterCreation {
                CharacterCreationView(game: $game)
            } else {
                GameView(game: $game)
            }
        }
        .frame(width: UIConstants.windowSize, height: UIConstants.windowSize)
        .navigationTitle("EpicQuest - \(game.character.name)")
        .onAppear {
            guard !isRunningPreview else { return }

            game.restoreIfPossible()
            game.startTimerIfNeeded()

            #if os(macOS)
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
            }
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressQuestStartNewGame)) { _ in
            game.resetToNewCharacter()
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressQuestIncreaseGameSpeed)) { _ in
            game.increaseGameSpeed()
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressQuestDecreaseGameSpeed)) { _ in
            game.decreaseGameSpeed()
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressQuestResetGameSpeed)) { _ in
            game.resetGameSpeedToDefault()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background {
                game.saveCurrentGame()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
