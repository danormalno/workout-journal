//
//  willwinTests.swift
//  willwinTests
//
//  Created by Володимир Борисенко on 27.05.2026.
//

import Testing
import Foundation
@testable import willwin

@MainActor
struct willwinTests {
    private func fixture(saveDelay: TimeInterval = 1) -> (AppState, Persistence, URL, Week, Workout, Exercise) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("willwin-test-\(UUID()).json")
        let persistence = Persistence(fileURL: url)
        let state = AppState(persistence: persistence, saveDelay: saveDelay)
        let exercise = Exercise(name: "Bench press", muscleGroup: .chest, sets: [
            ExerciseSet(weight: 20, reps: 8, restSeconds: 60),
            ExerciseSet(weight: 25, reps: 6, restSeconds: 90)
        ])
        // Поточний формат JSON зберігає ISO-8601 дати з точністю до секунди.
        let workout = Workout(date: Date(timeIntervalSince1970: 1_700_000_000), items: [.exercise(exercise)])
        let week = Week(workouts: [workout])
        state.data.weeks = [week]
        return (state, persistence, url, week, workout, exercise)
    }

    @Test func replacementPreservesSetsIDsAndHistoricalWorkouts() throws {
        let (state, _, url, week, workout, exercise) = fixture()
        defer { state.saveNow(); try? FileManager.default.removeItem(at: url) }
        var previous = workout
        previous.id = UUID()
        state.data.weeks[0].workouts.append(previous)
        state.replaceExercise(with: Exercise(name: "Row", muscleGroup: .back), exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        let updated = try #require(state.currentWorkout(weekId: week.id, workoutId: workout.id)?.exercises.first)
        #expect(updated.id == exercise.id)
        #expect(updated.name == "Row")
        #expect(updated.muscleGroup == .back)
        #expect(updated.sets == exercise.sets)
        #expect(state.currentWorkout(weekId: week.id, workoutId: previous.id) == previous)
        state.saveNow()
        let reloaded = AppState(persistence: Persistence(fileURL: url))
        #expect(reloaded.data.weeks == state.data.weeks)
    }

    @Test func deleteEverySetAndAddAgain() throws {
        let (state, _, url, week, workout, exercise) = fixture()
        defer { state.saveNow(); try? FileManager.default.removeItem(at: url) }
        for set in exercise.sets {
            state.deleteSet(setId: set.id, exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        }
        #expect(state.currentWorkout(weekId: week.id, workoutId: workout.id)?.exercises.first?.sets.isEmpty == true)
        state.addSet(exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        let sets = try #require(state.currentWorkout(weekId: week.id, workoutId: workout.id)?.exercises.first?.sets)
        #expect(sets.count == 1)
        #expect(sets[0].reps == 0)
        #expect(!exercise.sets.contains(where: { $0.id == sets[0].id }))
    }

    @Test func deletingEarlierSetKeepsEditsAndRestAttachedToCorrectID() throws {
        let (state, _, url, week, workout, exercise) = fixture()
        defer { state.saveNow(); try? FileManager.default.removeItem(at: url) }
        state.deleteSet(setId: exercise.sets[0].id, exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        var remaining = exercise.sets[1]
        remaining.weight = 35
        // Старий індекс уже не існує, але ID залишився тим самим.
        state.updateSet(remaining, atIndex: 1, exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        state.setSetRestSeconds(120, setId: remaining.id, exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        state.updateSet(exercise.sets[0], atIndex: 0, exerciseId: exercise.id, workoutId: workout.id, weekId: week.id)
        let sets = try #require(state.currentWorkout(weekId: week.id, workoutId: workout.id)?.exercises.first?.sets)
        #expect(sets.count == 1)
        #expect(sets[0].id == remaining.id)
        #expect(sets[0].weight == 35)
        #expect(sets[0].restSeconds == 120)
    }

    @Test func autosaveIsNotPostponedByContinuousEditing() async throws {
        let (state, persistence, url, week, workout, _) = fixture(saveDelay: 0.03)
        defer { state.saveNow(); try? FileManager.default.removeItem(at: url) }
        var savedWhileEditing = false
        for index in 0..<30 {
            state.updateWorkoutNotes(weekId: week.id, workoutId: workout.id, notes: "Edit \(index)")
            try await Task.sleep(for: .milliseconds(10))
            if !persistence.load().weeks.isEmpty { savedWhileEditing = true }
        }
        #expect(savedWhileEditing)
        state.saveNow()
        #expect(persistence.load().weeks == state.data.weeks)
        #expect(!state.saveFailed)
    }

    @Test func immediateSaveAndFailureRecovery() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("willwin-test-\(UUID())")
        let url = directory.appendingPathComponent("data.json")
        let persistence = Persistence(fileURL: url)
        let state = AppState(persistence: persistence)
        defer { state.saveNow(); try? FileManager.default.removeItem(at: directory) }
        state.addWeek()
        state.saveNow()
        #expect(state.saveFailed)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        state.saveNow()
        #expect(!state.saveFailed)
        #expect(persistence.load().weeks == state.data.weeks)
    }

    @Test func trainingNavigationRoundTrips() throws {
        let weekID = UUID()
        let path: [TrainingRoute] = [.week(weekID), .workout(weekId: weekID, workoutId: UUID())]
        #expect(try JSONDecoder().decode([TrainingRoute].self, from: JSONEncoder().encode(path)) == path)
    }

}
