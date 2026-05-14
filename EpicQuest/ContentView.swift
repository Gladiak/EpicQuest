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
            backgroundLayer

            mainContent
        }
        .frame(minWidth: UIConstants.windowWidth, minHeight: UIConstants.windowHeight)
        .navigationTitle("EpicQuest - \(game.character.name)")
        .onAppear {
            guard !isRunningPreview else { return }

            game.restoreIfPossible()
            game.startTimerIfNeeded()

            #if os(macOS)
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    let contentSize = NSSize(width: UIConstants.windowWidth, height: UIConstants.windowHeight)
                    window.setContentSize(contentSize)
                    window.contentMinSize = contentSize
                    window.makeKeyAndOrderFront(nil)
                }
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

    private var mainContent: some View {
        Group {
            if game.phase == .characterCreation {
                CharacterCreationView(game: $game)
            } else {
                GameView(game: $game)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    LiquidGlassPalette.backgroundTop,
                    LiquidGlassPalette.backgroundMid,
                    LiquidGlassPalette.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.03),
                    .clear
                ],
                center: .topLeading,
                startRadius: 60,
                endRadius: 420
            )
            .blur(radius: 10)
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.02),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 80,
                endRadius: 460
            )
            .blur(radius: 12)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
