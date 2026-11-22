import Foundation
import Combine
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var data: AppData {
        didSet { scheduleAutoSave() }
    }
    
    private var saveTimer: Timer?
    private let saveDelay: TimeInterval
    private let persistence: Persistence
    private var hasUnsavedChanges = false
    @Published private(set) var saveFailed = false
    
    init(persistence: Persistence? = nil, saveDelay: TimeInterval = 1) {
        let persistence = persistence ?? .shared
        self.persistence = persistence
        self.saveDelay = saveDelay
        self.data = persistence.load()
    }
    
    // MARK: - Автозбереження
    
    private func scheduleAutoSave() {
        hasUnsavedChanges = true
        // Не відкладати запис при кожному натисканні клавіші.
        guard saveTimer == nil else { return }
        let timer = Timer(timeInterval: saveDelay, repeats: false) { [weak self] _ in
            // Захоплюємо self слабко і викликаємо через MainActor
            Task { @MainActor [weak self] in
                self?.saveNow()
            }
        }
        saveTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func saveNow() {
        saveTimer?.invalidate()
        saveTimer = nil
        guard hasUnsavedChanges else { return }
        saveFailed = !persistence.save(data)
        hasUnsavedChanges = saveFailed
        if saveFailed { scheduleAutoSave() }
    }
    
    // MARK: - Тижні
    
    func addWeek() {
        let nextNumber = (data.weeks.map { $0.number }.max() ?? 0) + 1
        data.weeks.append(Week(number: nextNumber, workouts: []))
    }
    
    func duplicateWeek(_ week: Week) {
        let nextNumber = (data.weeks.map { $0.number }.max() ?? 0) + 1
        var copy = week
        copy.id = UUID()
        copy.number = nextNumber
        copy.workouts = copy.workouts.map { regenerateWorkoutIDs($0) }
        data.weeks.append(copy)
    }
    
    func deleteWeek(_ week: Week) {
        data.weeks.removeAll { $0.id == week.id }
    }
    
    func updateWeekNumber(_ week: Week, to newNumber: Int) {
        guard let idx = data.weeks.firstIndex(where: { $0.id == week.id }) else { return }
        data.weeks[idx].number = newNumber
    }
    
    func updateWeekName(_ week: Week, to newName: String) {
        guard let idx = data.weeks.firstIndex(where: { $0.id == week.id }) else { return }
        data.weeks[idx].customName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateWeekCycleSizeOverride(_ week: Week, to value: Int?) {
        guard let idx = data.weeks.firstIndex(where: { $0.id == week.id }) else { return }
        if let v = value, v > 0 {
            data.weeks[idx].cycleSizeOverride = v
        } else {
            data.weeks[idx].cycleSizeOverride = nil
        }
    }
    
    func moveWeek(from source: IndexSet, to destination: Int) {
        data.weeks.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Тренування
    
    static let maxWorkoutsPerWeek = 14
    static let maxExercisesPerWorkout = 10
    static let maxSetsPerExercise = 10
    static let maxCardioPerSection = 3
    
    private func weekIndex(_ week: Week) -> Int? {
        data.weeks.firstIndex(where: { $0.id == week.id })
    }
    
    private func indices(weekId: UUID, workoutId: UUID) -> (Int, Int)? {
        guard let wIdx = data.weeks.firstIndex(where: { $0.id == weekId }) else { return nil }
        guard let woIdx = data.weeks[wIdx].workouts.firstIndex(where: { $0.id == workoutId }) else { return nil }
        return (wIdx, woIdx)
    }
    
    func addWorkout(to week: Week) {
        guard let wIdx = weekIndex(week) else { return }
        guard data.weeks[wIdx].workouts.count < AppState.maxWorkoutsPerWeek else { return }
        let nextNumber = (data.weeks[wIdx].workouts.map { $0.number }.max() ?? 0) + 1
        data.weeks[wIdx].workouts.append(Workout(number: nextNumber, date: Date()))
    }
    
    func duplicateWorkout(_ workout: Workout, in week: Week) {
        guard let wIdx = weekIndex(week) else { return }
        guard data.weeks[wIdx].workouts.count < AppState.maxWorkoutsPerWeek else { return }
        let nextNumber = (data.weeks[wIdx].workouts.map { $0.number }.max() ?? 0) + 1
        var copy = regenerateWorkoutIDs(workout)
        copy.number = nextNumber
        copy.date = Date()
        data.weeks[wIdx].workouts.append(copy)
    }
    
    func deleteWorkout(_ workout: Workout, from week: Week) {
        guard let wIdx = weekIndex(week) else { return }
        data.weeks[wIdx].workouts.removeAll { $0.id == workout.id }
    }
    
    func updateWorkoutNumber(_ workout: Workout, in week: Week, to newNumber: Int) {
        guard let wIdx = weekIndex(week) else { return }
        guard let woIdx = data.weeks[wIdx].workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        data.weeks[wIdx].workouts[woIdx].number = newNumber
    }
    
    func updateWorkoutName(_ workout: Workout, in week: Week, to newName: String) {
        guard let wIdx = weekIndex(week) else { return }
        guard let woIdx = data.weeks[wIdx].workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        data.weeks[wIdx].workouts[woIdx].customName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateWorkoutNotes(weekId: UUID, workoutId: UUID, notes: String) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        data.weeks[w].workouts[wo].notes = notes
    }
    
    func updateWorkoutDate(weekId: UUID, workoutId: UUID, date: Date) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        data.weeks[w].workouts[wo].date = date
    }
    
    func moveWorkout(from source: IndexSet, to destination: Int, in week: Week) {
        guard let wIdx = weekIndex(week) else { return }
        data.weeks[wIdx].workouts.move(fromOffsets: source, toOffset: destination)
    }
    
    func currentWeek(id: UUID) -> Week? {
        data.weeks.first(where: { $0.id == id })
    }
    
    func currentWorkout(weekId: UUID, workoutId: UUID) -> Workout? {
        currentWeek(id: weekId)?.workouts.first(where: { $0.id == workoutId })
    }
    
    // MARK: - Вправи / блоки / підходи
    
    func addExercise(_ exercise: Exercise, toWorkoutId workoutId: UUID, inWeekId weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        guard data.weeks[w].workouts[wo].exerciseCount < AppState.maxExercisesPerWorkout else { return }
        data.weeks[w].workouts[wo].items.append(.exercise(exercise))
    }
    
    func addBlock(_ block: ExerciseBlock, toWorkoutId workoutId: UUID, inWeekId weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        data.weeks[w].workouts[wo].items.append(.block(block))
    }
    
    func deleteWorkoutItem(itemId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        data.weeks[w].workouts[wo].items.removeAll { $0.id == itemId }
    }
    
    func moveWorkoutItems(from source: IndexSet, to destination: Int, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        data.weeks[w].workouts[wo].items.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateExerciseName(_ name: String, exerciseId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        let items = data.weeks[w].workouts[wo].items
        guard let idx = items.firstIndex(where: { $0.id == exerciseId }) else { return }
        if case .exercise(var ex) = items[idx] {
            ex.name = name
            data.weeks[w].workouts[wo].items[idx] = .exercise(ex)
        }
    }

    /// Змінити лише вправу в цьому тренуванні, зберігши ID, підходи та минулі тренування.
    func replaceExercise(with replacement: Exercise, exerciseId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo, idx) = exerciseIndices(exerciseId: exerciseId, workoutId: workoutId, weekId: weekId),
              case .exercise(var exercise) = data.weeks[w].workouts[wo].items[idx] else { return }
        exercise.name = replacement.name
        exercise.muscleGroup = replacement.muscleGroup
        data.weeks[w].workouts[wo].items[idx] = .exercise(exercise)
    }
    
    func updateBlockName(_ name: String, blockId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        let items = data.weeks[w].workouts[wo].items
        guard let idx = items.firstIndex(where: { $0.id == blockId }) else { return }
        if case .block(var b) = items[idx] {
            b.name = name
            data.weeks[w].workouts[wo].items[idx] = .block(b)
        }
    }
    
    private func exerciseIndices(exerciseId: UUID, workoutId: UUID, weekId: UUID) -> (Int, Int, Int)? {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return nil }
        guard let exIdx = data.weeks[w].workouts[wo].items.firstIndex(where: { $0.id == exerciseId }) else { return nil }
        return (w, wo, exIdx)
    }
    
    func updateSet(_ set: ExerciseSet, atIndex setIdx: Int, exerciseId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo, exIdx) = exerciseIndices(exerciseId: exerciseId, workoutId: workoutId, weekId: weekId) else { return }
        if case .exercise(var ex) = data.weeks[w].workouts[wo].items[exIdx] {
            guard let index = ex.sets.firstIndex(where: { $0.id == set.id }) else { return }
            ex.sets[index] = set
            data.weeks[w].workouts[wo].items[exIdx] = .exercise(ex)
        }
    }
    
    func addSet(exerciseId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo, exIdx) = exerciseIndices(exerciseId: exerciseId, workoutId: workoutId, weekId: weekId) else { return }
        if case .exercise(var ex) = data.weeks[w].workouts[wo].items[exIdx] {
            guard ex.sets.count < AppState.maxSetsPerExercise else { return }
            var newSet = ExerciseSet()
            if let last = ex.sets.last, last.isFilled {
                newSet.reps = last.reps
                newSet.weight = last.weight
            }
            ex.sets.append(newSet)
            data.weeks[w].workouts[wo].items[exIdx] = .exercise(ex)
        }
    }
    
    func deleteSet(setId: UUID, exerciseId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo, exIdx) = exerciseIndices(exerciseId: exerciseId, workoutId: workoutId, weekId: weekId) else { return }
        if case .exercise(var ex) = data.weeks[w].workouts[wo].items[exIdx] {
            guard let setIdx = ex.sets.firstIndex(where: { $0.id == setId }) else { return }
            ex.sets.remove(at: setIdx)
            if RestTimerService.shared.activeContext?.setId == setId {
                RestTimerService.shared.cancelAndClear()
            }
            data.weeks[w].workouts[wo].items[exIdx] = .exercise(ex)
        }
    }
    
    // MARK: - Кардіо (тільки after зараз, але залишаю обидва методи для сумісності)
    
    func addCardio(_ cardio: Cardio, position: CardioPosition, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        switch position {
        case .before:
            guard data.weeks[w].workouts[wo].cardioBefore.count < AppState.maxCardioPerSection else { return }
            data.weeks[w].workouts[wo].cardioBefore.append(cardio)
        case .after:
            guard data.weeks[w].workouts[wo].cardioAfter.count < AppState.maxCardioPerSection else { return }
            data.weeks[w].workouts[wo].cardioAfter.append(cardio)
        }
    }
    
    func updateCardio(_ cardio: Cardio, position: CardioPosition, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        switch position {
        case .before:
            if let i = data.weeks[w].workouts[wo].cardioBefore.firstIndex(where: { $0.id == cardio.id }) {
                data.weeks[w].workouts[wo].cardioBefore[i] = cardio
            }
        case .after:
            if let i = data.weeks[w].workouts[wo].cardioAfter.firstIndex(where: { $0.id == cardio.id }) {
                data.weeks[w].workouts[wo].cardioAfter[i] = cardio
            }
        }
    }
    
    func deleteCardio(id: UUID, position: CardioPosition, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        switch position {
        case .before:
            data.weeks[w].workouts[wo].cardioBefore.removeAll { $0.id == id }
        case .after:
            data.weeks[w].workouts[wo].cardioAfter.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Кастомні назви
    
    /// Список кастомних вправ для пікера. Об'єднує:
    /// 1. Збережені вручну (data.customExercises) — пріоритет, не зникають
    /// 2. Згадані в тренуваннях але ще не збережені (для зворотньої сумісності)
    var customExerciseNames: [String] {
        var seen: Set<String> = []
        var result: [String] = []
        
        // 1. Спочатку збережені кастомні вправи
        for custom in data.customExercises {
            let trimmed = custom.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let lower = trimmed.lowercased()
            if !seen.contains(lower) {
                seen.insert(lower)
                result.append(trimmed)
            }
        }
        
        // 2. Потім додаємо ті що з тренувань, які ще не збережені і не в бібліотеці
        for week in data.weeks {
            for workout in week.workouts {
                for item in workout.items {
                    if case .exercise(let ex) = item {
                        let trimmed = ex.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { continue }
                        let lower = trimmed.lowercased()
                        if seen.contains(lower) { continue }
                        let inLibrary = ExerciseLibrary.all.contains { libEx in
                            libEx.names.values.contains(where: { $0.lowercased() == lower })
                        }
                        if !inLibrary {
                            seen.insert(lower)
                            result.append(trimmed)
                        }
                    }
                }
            }
        }
        return result.sorted()
    }
    
    var customCardioNames: [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for week in data.weeks {
            for workout in week.workouts {
                let allCardio = workout.cardioBefore + workout.cardioAfter
                for c in allCardio {
                    let trimmed = c.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { continue }
                    let lower = trimmed.lowercased()
                    let inLibrary = CardioLibrary.all.contains { libC in
                        libC.names.values.contains(where: { $0.lowercased() == lower })
                    }
                    if !inLibrary && !seen.contains(lower) {
                        seen.insert(lower)
                        result.append(trimmed)
                    }
                }
            }
        }
        return result.sorted()
    }
    
    // MARK: - Останнє значення для вправи (підказка)
    
    /// Шукає останню (за хронологією) ExerciseSet з ненульовою вагою або повторами для заданої назви вправи
    func lastSetForExercise(name: String) -> ExerciseSet? {
        let target = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !target.isEmpty else { return nil }
        // Обходимо тренування в хронологічному порядку у зворотньому
        let all = CyclesEngine.chronologicalWorkouts(from: data).reversed()
        for (workout, _) in all {
            for ex in workout.exercises {
                let exName = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if exName == target, let best = ex.sets.last(where: { $0.isFilled }) {
                    return best
                }
            }
        }
        return nil
    }
    
    // MARK: - Helper
    
    private func regenerateWorkoutIDs(_ workout: Workout) -> Workout {
        var w = workout
        w.id = UUID()
        w.items = workout.items.map { item in
            switch item {
            case .exercise(var ex):
                ex.id = UUID()
                ex.sets = ex.sets.map { s in var ns = s; ns.id = UUID(); return ns }
                return .exercise(ex)
            case .block(var b):
                b.id = UUID()
                return .block(b)
            }
        }
        w.cardioBefore = workout.cardioBefore.map { c in var nc = c; nc.id = UUID(); return nc }
        w.cardioAfter = workout.cardioAfter.map { c in var nc = c; nc.id = UUID(); return nc }
        return w
    }
    
    // MARK: - Налаштування
    
    func setLanguage(_ lang: AppLanguage) {
        data.settings.language = lang
    }
    
    func setDefaultCycleSize(_ value: Int) {
        data.settings.defaultCycleSize = max(1, value)
    }
    
    // MARK: - Вага тіла
    
    func addBodyWeightEntry(weight: Double) {
        let entry = BodyWeightEntry(weight: weight, date: Date())
        data.bodyWeights.append(entry)
        data.bodyWeights.sort { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
    }
    
    func deleteBodyWeightEntry(_ id: UUID) {
        data.bodyWeights.removeAll { $0.id == id }
    }
    
    func updateBodyWeightEntry(_ id: UUID, weight: Double, date: Date?) {
        guard let idx = data.bodyWeights.firstIndex(where: { $0.id == id }) else { return }
        data.bodyWeights[idx].weight = weight
        data.bodyWeights[idx].date = date
        data.bodyWeights.sort { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
    }
    
    // MARK: - Експорт/Імпорт
    
    func exportData() -> URL? {
        // Збережемо актуальний стан і повернемо URL файлу
        saveNow()
        return Persistence.shared.exportFileURL()
    }
    
    func importData(from url: URL) -> Bool {
        guard let imported = Persistence.shared.importFrom(url: url) else { return false }
        self.data = imported
        saveNow()
        return true
    }
}

// MARK: - Розширення для Ітерації 5
extension AppState {
    func setTimerSound(_ sound: TimerSound) {
        data.settings.timerSound = sound
    }
    
    func setHapticsEnabled(_ enabled: Bool) {
        data.settings.hapticsEnabled = enabled
    }
    
    func setTimerAlertMode(_ mode: TimerAlertMode) {
        data.settings.timerAlertMode = mode
    }
    
    func setDefaultRestSeconds(_ value: Int) {
        data.settings.defaultRestSeconds = max(5, value)
    }
    
    func setProgressChartRange(_ range: ProgressChartRange) {
        data.settings.progressChartRange = range
    }
    
    // MARK: - Кастомні вправи
    
    /// Додає кастомну вправу до збереженого списку.
    /// Якщо вправа з таким ім'ям вже існує — не дублює.
    func addCustomExercise(name: String, muscleGroup: MuscleGroup?) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Перевіряємо, що такої назви ще нема (case-insensitive)
        let normalized = trimmed.lowercased()
        if data.customExercises.contains(where: { $0.name.lowercased() == normalized }) {
            return
        }
        
        let exercise = CustomExercise(name: trimmed, muscleGroup: muscleGroup, createdAt: Date())
        data.customExercises.append(exercise)
    }
    
    /// Всі вправи з тренувань, які НЕ є в базі ExerciseLibrary і НЕ збережені як customExercises.
    /// Використовується щоб запропонувати "забути" або додати в збережені.
    func allExerciseNamesFromWorkouts() -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for week in data.weeks {
            for workout in week.workouts {
                for ex in workout.exercises {
                    let key = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !key.isEmpty && !seen.contains(key) {
                        seen.insert(key)
                        result.append(ex.name)
                    }
                }
            }
        }
        return result
    }
    
    func setColorScheme(_ scheme: ColorScheme) {
        data.settings.colorScheme = scheme
    }
    
    /// Зберегти фактичний час відпочинку для підходу
    func setSetRestSeconds(_ seconds: Int, setId: UUID, exerciseId: UUID, workoutId: UUID, weekId: UUID) {
        guard let (w, wo) = indices(weekId: weekId, workoutId: workoutId) else { return }
        guard let exIdx = data.weeks[w].workouts[wo].items.firstIndex(where: { $0.id == exerciseId }) else { return }
        if case .exercise(var ex) = data.weeks[w].workouts[wo].items[exIdx] {
            guard let setIdx = ex.sets.firstIndex(where: { $0.id == setId }) else { return }
            ex.sets[setIdx].restSeconds = seconds
            data.weeks[w].workouts[wo].items[exIdx] = .exercise(ex)
        }
    }
}
