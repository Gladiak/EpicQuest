import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @State private var game = GameState()

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
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
