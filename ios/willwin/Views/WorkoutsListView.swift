import SwiftUI

struct WorkoutsListView: View {
    let weekId: UUID
    
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    @State private var editingWorkout: Workout? = nil
    @State private var editingNumberText: String = ""
    @State private var editingNameText: String = ""
    @State private var workoutToDelete: Workout? = nil
    @State private var showMaxAlert: Bool = false
    
    private var week: Week? {
        appState.currentWeek(id: weekId)
    }
    
    private var navigationTitle: String {
        guard let w = week else { return "" }
        if !w.customName.isEmpty {
            return w.customName
        }
        return "\(s.week) \(w.number)"
    }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            WallpaperBackground()
            
            if let w = week {
                if w.workouts.isEmpty {
                    emptyState(for: w)
                } else {
                    workoutsList(for: w)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addWorkoutAction()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                }
                .accessibilityIdentifier("addWorkout")
            }
            if let w = week, !w.workouts.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .sheet(item: $editingWorkout) { workout in
            editSheet(for: workout)
        }
        .alert(s.confirmDelete, isPresented: Binding(
            get: { workoutToDelete != nil },
            set: { if !$0 { workoutToDelete = nil } }
        )) {
            Button(s.cancel, role: .cancel) { workoutToDelete = nil }
            Button(s.delete, role: .destructive) {
                if let wo = workoutToDelete, let w = week {
                    withAnimation { appState.deleteWorkout(wo, from: w) }
                }
                workoutToDelete = nil
            }
        } message: {
            Text(s.deleteWorkoutMessage)
        }
        .alert(s.maxWorkoutsReached, isPresented: $showMaxAlert) {
            Button(s.done, role: .cancel) { }
        }
    }
    
    private func addWorkoutAction() {
        guard let w = week else { return }
        if w.workouts.count >= AppState.maxWorkoutsPerWeek {
            showMaxAlert = true
            return
        }
        withAnimation { appState.addWorkout(to: w) }
    }
    
    // MARK: - Empty state
    
    private func emptyState(for w: Week) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text(s.noWorkoutsYet)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
            Button {
                withAnimation { appState.addWorkout(to: w) }
            } label: {
                Label(s.addWorkout, systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // MARK: - Список тренувань
    
    private func workoutsList(for w: Week) -> some View {
        List {
            ForEach(w.workouts) { workout in
                NavigationLink(value: TrainingRoute.workout(weekId: weekId, workoutId: workout.id)) {
                    workoutRow(workout)
                }
                .accessibilityIdentifier("workoutRow-\(workout.id)")
                .listRowBackground(theme.cardBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        workoutToDelete = workout
                    } label: {
                        Label(s.delete, systemImage: "trash")
                    }
                    Button {
                        withAnimation { appState.duplicateWorkout(workout, in: w) }
                    } label: {
                        Label(s.duplicate, systemImage: "doc.on.doc")
                    }
                    .tint(theme.accent)
                }
                .contextMenu {
                    Button {
                        editingNumberText = "\(workout.number)"
                        editingNameText = workout.customName
                        editingWorkout = workout
                    } label: {
                        Label(s.rename, systemImage: "pencil")
                    }
                    Button {
                        withAnimation { appState.duplicateWorkout(workout, in: w) }
                    } label: {
                        Label(s.duplicate, systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) {
                        workoutToDelete = workout
                    } label: {
                        Label(s.delete, systemImage: "trash")
                    }
                }
            }
            .onMove { source, destination in
                appState.moveWorkout(from: source, to: destination, in: w)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.background)
    }
    
    private func workoutRow(_ workout: Workout) -> some View {
        HStack(spacing: 14) {
            Text("\(workout.number)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accent)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                if !workout.customName.isEmpty {
                    Text(workout.customName)
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text("\(s.workout) \(workout.number) · \(formattedDate(workout.date))")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                } else {
                    Text("\(s.workout) \(workout.number)")
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text(formattedDate(workout.date))
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Edit sheet
    
    private func editSheet(for workout: Workout) -> some View {
        NavigationStack {
            Form {
                Section(s.workoutNumber) {
                    TextField(s.workoutNumber, text: $editingNumberText)
                        .keyboardType(.numberPad)
                }
                Section(s.nameOptional) {
                    TextField(s.nameOptional, text: $editingNameText)
                }
            }
            .navigationTitle(s.rename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { editingWorkout = nil }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.save) {
                        if let n = Int(editingNumberText), n > 0, let w = week {
                            appState.updateWorkoutNumber(workout, in: w, to: n)
                        }
                        if let w = week {
                            appState.updateWorkoutName(workout, in: w, to: editingNameText)
                        }
                        editingWorkout = nil
                    }
                    .bold()
                }
            }
        }
        .presentationDetents([.height(320)])
    }
}
