import Foundation

/// Розумна прогресія ваги.
/// Правило (подвійна прогресія / лінійна):
///  • Минулого разу виконав усі цільові повтори на робочій вазі  → +крок (progress)
///  • Виконав не повністю                                         → повтори ту саму вагу (hold)
///  • Застій двічі поспіль на тій самій вазі                      → делоад ~10% (deload)
enum ProgressionEngine {

    enum Kind { case progress, hold, deload }

    struct Suggestion {
        let weight: Double
        let reps: Int
        let kind: Kind
    }

    /// Крок збільшення ваги залежно від групи м'язів.
    /// Великі/базові — 2.5 кг, ізоляція дрібних груп — 1.25 кг.
    static func increment(for mg: MuscleGroup?) -> Double {
        switch mg {
        case .biceps, .triceps, .shoulders, .abs: return 1.25
        default: return 2.5
        }
    }

    /// Головна підказка.
    /// - target: цільові повтори (з префілу програми). 0 = невідомо → беремо з минулої сесії.
    static func suggest(exerciseName: String,
                        target: Int,
                        muscleGroup: MuscleGroup?,
                        appState: AppState) -> Suggestion? {
        let sessions = lastSessions(name: exerciseName, appState: appState, limit: 2)
        guard let last = sessions.first, !last.isEmpty else { return nil }

        let topWeight = last.map { $0.weight }.max() ?? 0
        guard topWeight > 0 else { return nil }

        let working = last.filter { $0.weight == topWeight }
        let tgt = target > 0 ? target : (working.map { $0.reps }.max() ?? 0)
        guard tgt > 0 else { return nil }

        let inc = increment(for: muscleGroup)
        let allHit = working.allSatisfy { $0.reps >= tgt }

        if allHit {
            return Suggestion(weight: topWeight + inc, reps: tgt, kind: .progress)
        }

        // Перевірка застою: попередня сесія на тій самій вазі теж без цілі → делоад
        if sessions.count >= 2 {
            let prev = sessions[1]
            let prevTop = prev.map { $0.weight }.max() ?? 0
            if prevTop == topWeight {
                let prevWorking = prev.filter { $0.weight == topWeight }
                let prevAllHit = prevWorking.allSatisfy { $0.reps >= tgt }
                if !prevAllHit {
                    let deloaded = roundToStep(topWeight * 0.9, step: inc)
                    return Suggestion(weight: max(deloaded, inc), reps: tgt, kind: .deload)
                }
            }
        }

        return Suggestion(weight: topWeight, reps: tgt, kind: .hold)
    }

    /// Останні N сесій (масиви заповнених підходів) для вправи за назвою, найновіші першими.
    static func lastSessions(name: String, appState: AppState, limit: Int) -> [[ExerciseSet]] {
        let target = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !target.isEmpty else { return [] }

        var result: [[ExerciseSet]] = []
        for entry in CyclesEngine.chronologicalWorkouts(from: appState.data).reversed() {
            for ex in entry.workout.exercises
            where ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == target {
                let filled = ex.sets.filter { $0.isFilled && $0.weight > 0 }
                if !filled.isEmpty {
                    result.append(filled)
                    if result.count >= limit { return result }
                }
            }
        }
        return result
    }

    static func roundToStep(_ v: Double, step: Double) -> Double {
        guard step > 0 else { return v }
        return (v / step).rounded() * step
    }
}
