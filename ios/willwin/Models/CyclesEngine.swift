import Foundation

/// Один цикл — послідовний набір тренувань.
struct TrainingCycle: Identifiable, Hashable {
    var id: UUID = UUID()
    let index: Int          // порядковий номер циклу (1, 2, 3...)
    let workouts: [Workout]  // тренування у порядку виконання
    let weekNumbers: [Int]   // в яких тижнях лежать ці тренування (для відображення)
    
    var tonnage: Double {
        workouts.reduce(0) { $0 + $1.tonnage }
    }
    
    /// Найкращий результат для кожної унікальної назви вправи в цьому циклі
    func bestSetsByExercise() -> [String: (best: ExerciseSet, exerciseName: String, muscleGroup: MuscleGroup?)] {
        var result: [String: (best: ExerciseSet, exerciseName: String, muscleGroup: MuscleGroup?)] = [:]
        for workout in workouts {
            for ex in workout.exercises {
                let key = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty, let best = ex.bestSet else { continue }
                if let existing = result[key] {
                    // Беремо кращий: більша вага, при рівній — більше повторів
                    if best.weight > existing.best.weight ||
                       (best.weight == existing.best.weight && best.reps > existing.best.reps) {
                        result[key] = (best, ex.name, ex.muscleGroup)
                    }
                } else {
                    result[key] = (best, ex.name, ex.muscleGroup)
                }
            }
        }
        return result
    }
    
    /// Сумарний тоннаж для кожної вправи
    func totalTonnageByExercise() -> [String: Double] {
        var result: [String: Double] = [:]
        for workout in workouts {
            for ex in workout.exercises {
                let key = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty else { continue }
                result[key, default: 0] += ex.tonnage
            }
        }
        return result
    }
}

/// Тип прогресу у вправі при порівнянні циклів
enum ExerciseProgressType {
    case weightUp(from: Double, to: Double, percent: Double)
    case repsUp(weight: Double, fromReps: Int, toReps: Int, percent: Double)
    case tonnageUp(from: Double, to: Double, percent: Double)
    case noChange
    case weightDown(from: Double, to: Double, percent: Double)
    case repsDown(weight: Double, fromReps: Int, toReps: Int, percent: Double)
    case tonnageDown(from: Double, to: Double, percent: Double)
}

/// Деталь по одній вправі при порівнянні
struct ExerciseComparison: Identifiable, Hashable {
    var id: String { name.lowercased() }
    let name: String
    let muscleGroup: MuscleGroup?
    let progressType: ExerciseProgressType
    
    var isImprovement: Bool {
        switch progressType {
        case .weightUp, .repsUp, .tonnageUp: return true
        default: return false
        }
    }
    
    var isDecline: Bool {
        switch progressType {
        case .weightDown, .repsDown, .tonnageDown: return true
        default: return false
        }
    }
    
    // Для Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: ExerciseComparison, rhs: ExerciseComparison) -> Bool {
        lhs.name == rhs.name
    }
}

/// Підсумок порівняння двох циклів
struct CycleComparison {
    let current: TrainingCycle
    let previous: TrainingCycle
    let tonnageChange: Double          // current.tonnage - previous.tonnage
    let tonnagePercent: Double          // % зміни
    let exerciseComparisons: [ExerciseComparison]
    
    var improvedCount: Int {
        exerciseComparisons.filter { $0.isImprovement }.count
    }
    
    var declinedCount: Int {
        exerciseComparisons.filter { $0.isDecline }.count
    }
    
    var totalCount: Int {
        exerciseComparisons.count
    }
}

/// Помічник для побудови циклів і порівнянь.
enum CyclesEngine {
    
    /// Витягнути всі тренування з даними у хронологічному порядку через всі тижні.
    /// Тренування ОДНОГО тижня впорядковуємо по номеру тренування.
    static func chronologicalWorkouts(from data: AppData) -> [(workout: Workout, weekNumber: Int)] {
        var result: [(workout: Workout, weekNumber: Int)] = []
        // Тижні в порядку як в data.weeks (не по номеру — користувач міг переставити)
        for week in data.weeks {
            let sorted = week.workouts.sorted(by: { $0.number < $1.number })
            for w in sorted where w.hasData {
                result.append((w, week.number))
            }
        }
        return result
    }
    
    /// Побудувати цикли із заданими розмірами.
    /// Складно: розмір циклу може бути різним на різних тижнях.
    /// Спрощено: беремо глобальний розмір (або перевизначений для конкретного тижня першого тренування циклу).
    static func buildCycles(from data: AppData) -> [TrainingCycle] {
        let chronological = chronologicalWorkouts(from: data)
        guard !chronological.isEmpty else { return [] }
        
        let defaultSize = max(1, data.settings.defaultCycleSize)
        // Карта: weekNumber → cycleSizeOverride
        let overrides: [Int: Int] = Dictionary(uniqueKeysWithValues:
            data.weeks.compactMap { w in
                if let s = w.cycleSizeOverride, s > 0 { return (w.number, s) }
                return nil
            }
        )
        
        var cycles: [TrainingCycle] = []
        var buffer: [(Workout, Int)] = []
        var cycleIndex = 1
        var currentSize: Int = defaultSize
        
        for item in chronological {
            if buffer.isEmpty {
                // початок нового циклу — визначаємо його розмір по першому тренуванню
                currentSize = overrides[item.weekNumber] ?? defaultSize
            }
            buffer.append(item)
            if buffer.count >= currentSize {
                let cycle = TrainingCycle(
                    index: cycleIndex,
                    workouts: buffer.map { $0.0 },
                    weekNumbers: Array(Set(buffer.map { $0.1 })).sorted()
                )
                cycles.append(cycle)
                cycleIndex += 1
                buffer.removeAll()
            }
        }
        
        // Незавершений цикл також показуємо (якщо хоч одне тренування)
        if !buffer.isEmpty {
            let cycle = TrainingCycle(
                index: cycleIndex,
                workouts: buffer.map { $0.0 },
                weekNumbers: Array(Set(buffer.map { $0.1 })).sorted()
            )
            cycles.append(cycle)
        }
        
        return cycles
    }
    
    /// Порівняти два цикли.
    static func compare(current: TrainingCycle, previous: TrainingCycle) -> CycleComparison {
        let currentBest = current.bestSetsByExercise()
        let previousBest = previous.bestSetsByExercise()
        let currentTonnage = current.totalTonnageByExercise()
        let previousTonnage = previous.totalTonnageByExercise()
        
        var comparisons: [ExerciseComparison] = []
        
        // Тільки спільні вправи (як ти просив)
        let commonKeys = Set(currentBest.keys).intersection(Set(previousBest.keys))
        
        for key in commonKeys {
            guard let cur = currentBest[key], let prev = previousBest[key] else { continue }
            
            let progressType: ExerciseProgressType
            
            // Логіка вибору типу прогресу:
            // 1) Якщо вага зросла → weightUp
            // 2) Якщо вага рівна але повтори зросли → repsUp
            // 3) Інакше дивимось тоннаж
            // (аналогічно для зниження)
            
            if cur.best.weight > prev.best.weight {
                let percent = prev.best.weight > 0 ? (cur.best.weight - prev.best.weight) / prev.best.weight * 100 : 100
                progressType = .weightUp(from: prev.best.weight, to: cur.best.weight, percent: percent)
            } else if cur.best.weight < prev.best.weight {
                let percent = prev.best.weight > 0 ? (prev.best.weight - cur.best.weight) / prev.best.weight * 100 : 0
                progressType = .weightDown(from: prev.best.weight, to: cur.best.weight, percent: percent)
            } else if cur.best.reps > prev.best.reps {
                let percent = prev.best.reps > 0 ? Double(cur.best.reps - prev.best.reps) / Double(prev.best.reps) * 100 : 100
                progressType = .repsUp(weight: cur.best.weight, fromReps: prev.best.reps, toReps: cur.best.reps, percent: percent)
            } else if cur.best.reps < prev.best.reps {
                let percent = prev.best.reps > 0 ? Double(prev.best.reps - cur.best.reps) / Double(prev.best.reps) * 100 : 0
                progressType = .repsDown(weight: cur.best.weight, fromReps: prev.best.reps, toReps: cur.best.reps, percent: percent)
            } else {
                // Найкращий підхід ідентичний — порівнюємо загальний тоннаж по вправі
                let curT = currentTonnage[key] ?? 0
                let prevT = previousTonnage[key] ?? 0
                if curT > prevT {
                    let percent = prevT > 0 ? (curT - prevT) / prevT * 100 : 100
                    progressType = .tonnageUp(from: prevT, to: curT, percent: percent)
                } else if curT < prevT {
                    let percent = prevT > 0 ? (prevT - curT) / prevT * 100 : 0
                    progressType = .tonnageDown(from: prevT, to: curT, percent: percent)
                } else {
                    progressType = .noChange
                }
            }
            
            comparisons.append(ExerciseComparison(
                name: cur.exerciseName,
                muscleGroup: cur.muscleGroup,
                progressType: progressType
            ))
        }
        
        // Сортування: спочатку покращення (по %), потім без змін, потім зниження
        comparisons.sort { a, b in
            func rank(_ c: ExerciseComparison) -> Int {
                if c.isImprovement { return 0 }
                if c.isDecline { return 2 }
                return 1
            }
            return rank(a) < rank(b)
        }
        
        let tonChange = current.tonnage - previous.tonnage
        let tonPercent = previous.tonnage > 0 ? tonChange / previous.tonnage * 100 : 0
        
        return CycleComparison(
            current: current,
            previous: previous,
            tonnageChange: tonChange,
            tonnagePercent: tonPercent,
            exerciseComparisons: comparisons
        )
    }
}
