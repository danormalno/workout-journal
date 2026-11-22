import SwiftUI

@main
struct willwinApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Встановлюємо кнопку "Готово" на всі цифрові клавіатури
        let lang = Persistence.shared.load().settings.language
        let doneTitle = Strings.current(for: lang).done
        KeyboardToolbar.install(doneTitle: doneTitle)
        
        // Запитуємо дозвіл на нотифікації (для таймера у фоні)
        RestTimerService.requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    appState.saveNow()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    appState.saveNow()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // При поверненні з фону — оновити стан таймера
                Task { @MainActor in
                    RestTimerService.shared.refreshFromBackground()
                }
            }
        }
    }
}
