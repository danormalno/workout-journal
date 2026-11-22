import Foundation

// MARK: - Підхід
struct ExerciseSet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var weight: Double = 0
    var reps: Int = 0
    var restSeconds: Int? = nil
    
    var isFilled: Bool { reps > 0 }
    var tonnage: Double { weight * Double(reps) }
}

// MARK: - М'язові групи
enum MuscleGroup: String, Codable, CaseIterable, Hashable {
    case chest, back, shoulders, biceps, triceps, legs, abs, cardio, other
    static let displayOrder: [MuscleGroup] = [
        .chest, .back, .shoulders, .biceps, .triceps, .legs, .abs, .cardio, .other
    ]
}

// MARK: - Вправа
struct Exercise: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
    var muscleGroup: MuscleGroup? = nil
    var sets: [ExerciseSet] = [ExerciseSet()]
    
    var tonnage: Double { sets.reduce(0) { $0 + $1.tonnage } }
    var maxWeight: Double { sets.map { $0.weight }.max() ?? 0 }
    
    var bestSet: ExerciseSet? {
        sets.filter { $0.isFilled }.max(by: { a, b in
            if a.weight != b.weight { return a.weight < b.weight }
            return a.reps < b.reps
        })
    }
    
    var totalReps: Int { sets.reduce(0) { $0 + $1.reps } }
}

// MARK: - Розділювач
struct ExerciseBlock: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
}

enum WorkoutItem: Identifiable, Codable, Hashable {
    case exercise(Exercise)
    case block(ExerciseBlock)
    
    var id: UUID {
        switch self {
        case .exercise(let e): return e.id
        case .block(let b): return b.id
        }
    }
}

// MARK: - Кардіо
struct Cardio: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
    var minutes: Int = 0
}

enum CardioPosition: String, Codable {
    case before, after
}

// MARK: - Тренування
struct Workout: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var number: Int = 1
    var customName: String = ""
    var date: Date = Date()
    var notes: String = ""
    var items: [WorkoutItem] = []
    var cardioBefore: [Cardio] = []
    var cardioAfter: [Cardio] = []
    
    var tonnage: Double {
        items.reduce(0.0) { sum, item in
            if case .exercise(let e) = item { return sum + e.tonnage }
            return sum
        }
    }
    
    var exerciseCount: Int {
        items.filter { if case .exercise = $0 { return true }; return false }.count
    }
    
    var exercises: [Exercise] {
        items.compactMap { if case .exercise(let e) = $0 { return e } else { return nil } }
    }
    
    var hasData: Bool {
        if !cardioBefore.isEmpty && cardioBefore.contains(where: { $0.minutes > 0 }) { return true }
        if !cardioAfter.isEmpty && cardioAfter.contains(where: { $0.minutes > 0 }) { return true }
        return exercises.contains(where: { $0.sets.contains(where: { $0.isFilled }) })
    }
}

// MARK: - Тиждень
struct Week: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var number: Int = 1
    var customName: String = ""
    var workouts: [Workout] = []
    var cycleSizeOverride: Int? = nil
    
    var tonnage: Double { workouts.reduce(0) { $0 + $1.tonnage } }
}

// MARK: - Вага
struct BodyWeightEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var weight: Double = 0
    var date: Date? = Date()
}

// MARK: - Налаштування
enum AppLanguage: String, Codable, CaseIterable {
    case uk, en, ru, es, de, fr, pt, pl, it
}

enum ColorScheme: String, Codable, CaseIterable {
    case system, light, dark
}

enum WeightUnit: String, Codable, CaseIterable {
    case kg, lb
}

enum TimerSound: String, Codable, CaseIterable {
    case beep, bell, chime, ding, none
    
    var displayKey: String { rawValue }
}

/// Скільки тижнів показувати на графіку прогресу за замовчуванням.
enum ProgressChartRange: String, Codable, CaseIterable {
    case weeks8       // ~2 місяці
    case weeks16      // ~4 місяці
    case allTime
    
    var weeksToShow: Int? {
        switch self {
        case .weeks8: return 8
        case .weeks16: return 16
        case .allTime: return nil
        }
    }
}

enum TimerAlertMode: String, Codable, CaseIterable {
    case soundAndVibration  // звук + вібрація (за замовчуванням)
    case vibrationOnly       // тільки вібрація
}

struct AppSettings: Codable {
    var language: AppLanguage? = nil
    var colorScheme: ColorScheme = .system
    var weightUnit: WeightUnit = .kg
    var timerSound: TimerSound = .beep
    var hapticsEnabled: Bool = true
    var timerAlertMode: TimerAlertMode = .soundAndVibration
    var defaultCycleSize: Int = 3
    var defaultRestSeconds: Int = 90
    var progressChartRange: ProgressChartRange = .weeks8
}

// MARK: - Кастомна вправа (збережена користувачем)
struct CustomExercise: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
    var muscleGroup: MuscleGroup? = nil
    var createdAt: Date = Date()
}

// MARK: - Кореневі дані
struct AppData: Codable {
    var weeks: [Week] = []
    var bodyWeights: [BodyWeightEntry] = []
    var customExercises: [CustomExercise] = []
    var settings: AppSettings = AppSettings()
    var schemaVersion: Int = 7
}
