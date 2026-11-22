import Foundation
import AVFoundation
import AudioToolbox
import SwiftUI
import UserNotifications
import Combine

/// Глобальний сервіс для таймера відпочинку.
/// Використовує AVAudioSession + Background Audio Mode щоб гарантовано
/// програвати звук на iPhone навіть коли екран заблоковано.
@MainActor
final class RestTimerService: ObservableObject {
    static let shared = RestTimerService()
    
    @Published var isRunning: Bool = false
    @Published var totalSeconds: Int = 0
    @Published var remainingSeconds: Int = 0
    @Published var isAlerting: Bool = false
    
    @Published var activeContext: ActiveTimerContext? = nil
    var onComplete: ((ActiveTimerContext) -> Void)? = nil
    
    private var timer: Timer? = nil
    private var alertTimer: Timer? = nil
    private var startedAt: Date? = nil
    private var endsAt: Date? = nil
    private var silentPlayer: AVAudioPlayer? = nil
    
    struct ActiveTimerContext: Equatable {
        let setId: UUID
        let exerciseId: UUID
        let workoutId: UUID
        let weekId: UUID
    }
    
    private var pendingSound: TimerSound = .beep
    private var pendingHaptics: Bool = true
    private var pendingAlertMode: TimerAlertMode = .soundAndVibration
    
    // MARK: - Public API
    
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { granted, error in
            if let error = error {
                print("Помилка дозволу нотифікацій: \(error)")
            } else {
                print("Дозвіл на нотифікації: \(granted)")
            }
        }
    }
    
    func start(seconds: Int, context: ActiveTimerContext, sound: TimerSound, haptics: Bool, alertMode: TimerAlertMode) {
        stop()
        totalSeconds = seconds
        remainingSeconds = seconds
        activeContext = context
        startedAt = Date()
        endsAt = Date().addingTimeInterval(TimeInterval(seconds))
        isRunning = true
        isAlerting = false
        pendingSound = sound
        pendingHaptics = haptics
        pendingAlertMode = alertMode
        
        // Активуємо аудіо сесію та починаємо тихе фонове відтворення.
        // Це утримує процес активним і дозволяє грати звук коли екран заблоковано.
        activateAudioSession()
        startSilentBackgroundAudio()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        
        scheduleBackgroundNotifications(totalSeconds: seconds, alertMode: alertMode)
    }
    
    private func tick() {
        guard isRunning, !isAlerting, let endsAt = endsAt else { return }
        let remaining = Int(endsAt.timeIntervalSinceNow.rounded(.up))
        remainingSeconds = max(0, remaining)
        if remaining <= 0 {
            startAlerting()
        }
    }
    
    private func startAlerting() {
        guard !isAlerting else { return }
        isAlerting = true
        remainingSeconds = 0
        
        timer?.invalidate()
        timer = nil
        
        // Граємо одразу
        playAlert()
        
        // Повторюємо кожні 1.5 сек
        alertTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.playAlert()
            }
        }
    }
    
    private func playAlert() {
        guard isAlerting else { return }
        
        switch pendingAlertMode {
        case .soundAndVibration:
            // Звук грає завжди (через активну аудіо-сесію) — навіть коли екран заблоковано
            playSound(pendingSound)
            if pendingHaptics { playHaptics() }
        case .vibrationOnly:
            // Тільки вібрація
            if pendingHaptics {
                playHaptics()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    func confirmAlert() {
        guard isAlerting else { return }
        let context = activeContext
        stop()
        if let ctx = context {
            onComplete?(ctx)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        alertTimer?.invalidate()
        alertTimer = nil
        isRunning = false
        isAlerting = false
        startedAt = nil
        endsAt = nil
        
        stopSilentBackgroundAudio()
        deactivateAudioSession()
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: notificationIdentifiers())
        center.removeDeliveredNotifications(withIdentifiers: notificationIdentifiers())
    }
    
    func cancelAndClear() {
        stop()
        activeContext = nil
        totalSeconds = 0
        remainingSeconds = 0
    }
    
    func refreshFromBackground() {
        guard isRunning, let endsAt = endsAt else { return }
        let remaining = Int(endsAt.timeIntervalSinceNow.rounded(.up))
        remainingSeconds = max(0, remaining)
        if remaining <= 0, !isAlerting {
            startAlerting()
        }
    }
    
    // MARK: - Audio Session
    
    private func activateAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback категорія дозволяє грати звук навіть коли екран заблоковано
            // .duckOthers — притишити фонову музику під час нашого сигналу
            try session.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            print("Не вдалось активувати AVAudioSession: \(error)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Не вдалось деактивувати AVAudioSession: \(error)")
        }
    }
    
    /// Запускає тихе фонове аудіо щоб підтримати фонову роботу та гарантувати звук на iPhone
    private func startSilentBackgroundAudio() {
        guard silentPlayer == nil else { return }
        
        // Генеруємо короткий тихий аудіо буфер у пам'яті (не потрібен файл у бандлі)
        guard let url = makeSilentAudioURL() else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1  // нескінченний loop
            player.volume = 0.01       // майже тихо, але активний
            player.prepareToPlay()
            player.play()
            self.silentPlayer = player
        } catch {
            print("Не вдалось запустити тихий аудіо: \(error)")
        }
    }
    
    private func stopSilentBackgroundAudio() {
        silentPlayer?.stop()
        silentPlayer = nil
    }
    
    /// Створює тимчасовий тихий WAV-файл у tmp-папці
    private func makeSilentAudioURL() -> URL? {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("silence.wav")
        
        if FileManager.default.fileExists(atPath: tmpURL.path) {
            return tmpURL
        }
        
        // 1 секунда тиші, 8000 Hz моно 16-бітна PCM
        let sampleRate: Int32 = 8000
        let durationSeconds: Int = 1
        let numSamples = Int(sampleRate) * durationSeconds
        let dataSize = numSamples * 2
        let fileSize = 44 + dataSize
        
        var data = Data()
        // WAV header
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46])  // "RIFF"
        data.append(contentsOf: withUnsafeBytes(of: UInt32(fileSize - 8).littleEndian) { Array($0) })
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45])  // "WAVE"
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20])  // "fmt "
        data.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })  // subchunk size
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })   // PCM
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })   // mono
        data.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate * 2).littleEndian) { Array($0) })  // byte rate
        data.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) })   // block align
        data.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) })  // bits per sample
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61])  // "data"
        data.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Array($0) })
        // sample data (зероS = тиша)
        data.append(Data(count: dataSize))
        
        do {
            try data.write(to: tmpURL)
            return tmpURL
        } catch {
            print("Не вдалось записати тимчасовий WAV: \(error)")
            return nil
        }
    }
    
    // MARK: - Звук
    
    private func playSound(_ sound: TimerSound) {
        switch sound {
        case .none: return
        case .beep: AudioServicesPlaySystemSound(1057)
        case .bell: AudioServicesPlaySystemSound(1013)
        case .chime: AudioServicesPlaySystemSound(1304)
        case .ding: AudioServicesPlaySystemSound(1054)
        }
    }
    
    private func playHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func preview(sound: TimerSound) {
        // Для прев'ю активуємо аудіо сесію тимчасово
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        playSound(sound)
    }
    
    // MARK: - Локальні нотифікації для фону (резерв на випадок коли AVAudioSession не спрацює)
    
    private func notificationIdentifiers() -> [String] {
        var ids: [String] = []
        for m in [60, 30, 10, 5, 4, 3, 2, 1] {
            ids.append("rest_timer_countdown_\(m)")
        }
        for i in 0..<10 {
            ids.append("rest_timer_repeat_\(i)")
        }
        return ids
    }
    
    private func scheduleBackgroundNotifications(totalSeconds: Int, alertMode: TimerAlertMode) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: notificationIdentifiers())
        
        let lang = Persistence.shared.load().settings.language
        let withSound = (alertMode == .soundAndVibration)
        
        for moment in [60, 30, 10, 5, 4, 3, 2, 1] {
            let triggerInterval = totalSeconds - moment
            guard triggerInterval > 0 else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = localizedCountdownTitle(for: lang)
            content.body = localizedCountdownBody(seconds: moment, for: lang)
            content.sound = nil
            content.interruptionLevel = .active
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(triggerInterval), repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "rest_timer_countdown_\(moment)",
                content: content, trigger: trigger
            )
            center.add(request) { _ in }
        }
        
        for i in 0..<10 {
            let offset = i * 2
            let triggerInterval = totalSeconds + offset
            
            let content = UNMutableNotificationContent()
            content.title = localizedTitle(for: lang)
            content.body = localizedBody(for: lang)
            content.interruptionLevel = .timeSensitive
            content.sound = withSound ? .default : nil
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(triggerInterval), repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "rest_timer_repeat_\(i)",
                content: content, trigger: trigger
            )
            center.add(request) { _ in }
        }
    }
    
    // MARK: - Локалізація
    
    private func localizedTitle(for lang: AppLanguage?) -> String {
        switch lang {
        case .en: return "Rest finished"
        case .ru: return "Отдых завершён"
        case .es: return "Descanso terminado"
        case .de: return "Pause beendet"
        case .fr: return "Repos terminé"
        case .pt: return "Descanso terminado"
        case .pl: return "Odpoczynek zakończony"
        case .it: return "Riposo finito"
        default: return "Відпочинок завершено"
        }
    }
    
    private func localizedBody(for lang: AppLanguage?) -> String {
        switch lang {
        case .en: return "Tap Go! to continue"
        case .ru: return "Нажми Go! чтобы продолжить"
        case .es: return "Toca Go! para continuar"
        case .de: return "Tippe Go! um fortzufahren"
        case .fr: return "Appuie sur Go! pour continuer"
        case .pt: return "Toque Go! para continuar"
        case .pl: return "Stuknij Go! aby kontynuować"
        case .it: return "Tocca Go! per continuare"
        default: return "Тапни Go! щоб продовжити"
        }
    }
    
    private func localizedCountdownTitle(for lang: AppLanguage?) -> String {
        switch lang {
        case .en: return "Rest timer"
        case .ru: return "Таймер отдыха"
        case .es: return "Temporizador de descanso"
        case .de: return "Pausentimer"
        case .fr: return "Minuteur de repos"
        case .pt: return "Cronômetro de descanso"
        case .pl: return "Timer odpoczynku"
        case .it: return "Timer di riposo"
        default: return "Таймер відпочинку"
        }
    }
    
    private func localizedCountdownBody(seconds: Int, for lang: AppLanguage?) -> String {
        switch lang {
        case .en: return "\(seconds) sec remaining"
        case .ru: return "Осталось \(seconds) сек"
        case .es: return "\(seconds) seg restantes"
        case .de: return "\(seconds) Sek übrig"
        case .fr: return "\(seconds) sec restantes"
        case .pt: return "\(seconds) seg restantes"
        case .pl: return "Pozostało \(seconds) sek"
        case .it: return "\(seconds) sec rimasti"
        default: return "Залишилось \(seconds) сек"
        }
    }
}
