import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let weekId: UUID
    let workoutId: UUID
    let onDelete: () -> Void
    let onReplace: () -> Void
    
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    @ObservedObject private var timerService = RestTimerService.shared

    private var replaceTitle: String {
        switch appState.data.settings.language {
        case .en: return "Replace exercise"
        case .ru: return "Заменить упражнение"
        case .es: return "Cambiar ejercicio"
        case .de: return "Übung ersetzen"
        case .fr: return "Remplacer l’exercice"
        case .pt: return "Substituir exercício"
        case .pl: return "Zamień ćwiczenie"
        case .it: return "Sostituisci esercizio"
        default: return "Замінити вправу"
        }
    }

    private var addSetTitle: String {
        switch appState.data.settings.language {
        case .en: return "Add set"
        case .ru: return "Добавить подход"
        case .es: return "Añadir serie"
        case .de: return "Satz hinzufügen"
        case .fr: return "Ajouter une série"
        case .pt: return "Adicionar série"
        case .pl: return "Dodaj serię"
        case .it: return "Aggiungi serie"
        default: return "Додати підхід"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    if let g = exercise.muscleGroup {
                        Text(s.muscleGroupName(g))
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                Spacer()
                if exercise.tonnage > 0 {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(Int(exercise.tonnage))")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundStyle(theme.accent)
                        Text(s.tonnage.lowercased() + " (\(s.kg))")
                            .font(.caption2).foregroundStyle(theme.textSecondary)
                    }
                }
                Menu {
                    Button {
                        ToolbarTarget.shared.dismissKeyboard()
                        onReplace()
                    } label: {
                        Label(replaceTitle, systemImage: "arrow.triangle.2.circlepath")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label(s.delete, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(theme.textSecondary)
                }
                .accessibilityIdentifier("exerciseMenu-\(exercise.id)")
            }
            
            if let last = lastSet() {
                Button {
                    fillWithLast(last)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption)
                            .foregroundStyle(theme.accent)
                        Text("↳ \(last.weight == 0 ? "0" : formatWeight(last.weight)) \(s.kg) × \(last.reps)")
                            .font(.caption2).fontWeight(.medium)
                            .foregroundStyle(theme.textPrimary)
                        Text(fillHint)
                            .font(.caption2)
                            .foregroundStyle(theme.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(theme.accent.opacity(0.10))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
            setsGrid
        }
        .padding(14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    /// Останній заповнений підхід цієї вправи з минулих тренувань (поки поточні підходи порожні).
    private func lastSet() -> ExerciseSet? {
        guard !exercise.sets.contains(where: { $0.isFilled }) else { return nil }
        return appState.lastSetForExercise(name: exercise.name)
    }

    /// Підставити вагу й повтори з минулого тренування в перший підхід.
    private func fillWithLast(_ last: ExerciseSet) {
        guard var newSet = exercise.sets.first else { return }
        newSet.weight = last.weight
        newSet.reps = last.reps
        appState.updateSet(newSet, atIndex: 0, exerciseId: exercise.id, workoutId: workoutId, weekId: weekId)
    }

    private var fillHint: String {
        switch appState.data.settings.language {
        case .en: return "· tap to fill"
        case .ru: return "· тап"
        case .es: return "· toca"
        case .de: return "· tippen"
        case .fr: return "· toucher"
        case .pt: return "· toque"
        case .pl: return "· dotknij"
        case .it: return "· tocca"
        default:  return "· тап"
        }
    }

    private func formatWeight(_ value: Double) -> String {
        if value == floor(value) { return "\(Int(value))" }
        return String(format: "%.1f", value)
    }
    
    private var setsGrid: some View {
        let canAddMore = exercise.sets.count < AppState.maxSetsPerExercise
        let lastIsFilled = exercise.sets.last?.isFilled ?? false
        let showPlus = canAddMore && lastIsFilled
        let columns = [GridItem(.adaptive(minimum: 110, maximum: 140), spacing: 8)]
        
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { idx, set in
                ZStack(alignment: .topTrailing) {
                    SetMiniEditor(
                        setIndex: idx,
                        set: set,
                        exerciseId: exercise.id,
                        workoutId: workoutId,
                        weekId: weekId
                    )
                    if idx == exercise.sets.count - 1 && showPlus {
                        Button {
                            appState.addSet(exerciseId: exercise.id, workoutId: workoutId, weekId: weekId)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(theme.accent)
                                .background(theme.cardBackground.clipShape(Circle()))
                        }
                        .buttonStyle(.plain)
                        .offset(x: 8, y: -8)
                        .accessibilityLabel(addSetTitle)
                        .accessibilityIdentifier("addSet-\(exercise.id)")
                    }
                }
            }
        }
    }
}

struct SetMiniEditor: View {
    let setIndex: Int
    let set: ExerciseSet
    let exerciseId: UUID
    let workoutId: UUID
    let weekId: UUID
    
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    @ObservedObject private var timerService = RestTimerService.shared
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var showingTimerSheet: Bool = false
    @State private var showingDeleteConfirmation = false
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case weight, reps }
    
    /// Чи активний таймер для цього конкретного підходу
    private var isThisTimerActive: Bool {
        guard let ctx = timerService.activeContext else { return false }
        return ctx.setId == set.id && ctx.exerciseId == exerciseId && ctx.workoutId == workoutId
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                TextField("0", text: $weightText)
                    .focused($focusedField, equals: .weight)
                    .accessibilityIdentifier("setWeight-\(set.id)")
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 30)
                    .font(.system(size: 16, weight: .semibold))
                    .onChange(of: weightText) { _, newVal in
                        commitWeight(newVal)
                    }
                
                Text("×")
                    .foregroundStyle(theme.textSecondary)
                    .font(.system(size: 14))
                
                TextField("0", text: $repsText)
                    .focused($focusedField, equals: .reps)
                    .accessibilityIdentifier("setReps-\(set.id)")
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 30)
                    .font(.system(size: 16, weight: .semibold))
                    .onChange(of: repsText) { _, newVal in
                        commitReps(newVal)
                    }
            }
            
            HStack(spacing: 4) {
                Text("#\(setIndex + 1)")
                    .font(.system(size: 10))
                    .foregroundStyle(theme.textSecondary)
                
                Spacer(minLength: 0)
                
                // Кнопка таймера — показуємо тільки якщо підхід заповнений
                if set.isFilled {
                    Button {
                        if isThisTimerActive && timerService.isRunning {
                            // Зупинити
                            timerService.cancelAndClear()
                        } else {
                            showingTimerSheet = true
                        }
                    } label: {
                        if isThisTimerActive && timerService.isRunning {
                            Text(formatTime(timerService.remainingSeconds))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(theme.accent)
                        } else if let rest = set.restSeconds, rest > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "timer")
                                    .font(.system(size: 9))
                                Text(formatTime(rest))
                                    .font(.system(size: 9))
                            }
                            .foregroundStyle(theme.textSecondary)
                        } else {
                            Image(systemName: "timer")
                                .font(.system(size: 11))
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                }
                
                Button(role: .destructive) {
                    focusedField = nil
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("\(s.delete) · \(s.sets) #\(setIndex + 1)")
                .accessibilityIdentifier("deleteSet-\(set.id)")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onAppear { syncFromModel() }
        .onChange(of: set) { _, _ in syncFromModel() }
        .onChange(of: focusedField) { _, _ in syncFromModel() }
        .onReceive(NotificationCenter.default.publisher(for: KeyboardToolbar.dismissRequested)) { _ in
            focusedField = nil
        }
        .alert(s.confirmDelete, isPresented: $showingDeleteConfirmation) {
            Button(s.cancel, role: .cancel) { }
            Button(s.delete, role: .destructive) {
                appState.deleteSet(setId: set.id, exerciseId: exerciseId, workoutId: workoutId, weekId: weekId)
            }
        } message: {
            Text("\(s.sets) #\(setIndex + 1)")
        }
        .sheet(isPresented: $showingTimerSheet) {
            TimerSelectionSheet { seconds in
                startTimer(seconds: seconds)
            }
            .environmentObject(appState)
            .environment(\.strings, s)
            .environment(\.appTheme, theme)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let sec = seconds % 60
        if m > 0 {
            return String(format: "%d:%02d", m, sec)
        }
        return "\(sec)\(s.sec.prefix(1))"
    }
    
    private func startTimer(seconds: Int) {
        let ctx = RestTimerService.ActiveTimerContext(
            setId: set.id,
            exerciseId: exerciseId,
            workoutId: workoutId,
            weekId: weekId
        )
        // Налаштувати callback збереження
        timerService.onComplete = { context in
            appState.setSetRestSeconds(
                seconds,
                setId: context.setId,
                exerciseId: context.exerciseId,
                workoutId: context.workoutId,
                weekId: context.weekId
            )
        }
        timerService.start(
            seconds: seconds,
            context: ctx,
            sound: appState.data.settings.timerSound,
            haptics: appState.data.settings.hapticsEnabled,
            alertMode: appState.data.settings.timerAlertMode
        )
    }
    
    private func syncFromModel() {
        // Не стирати десятковий роздільник, поки користувач набирає, наприклад, 12,5.
        if focusedField != .weight {
            weightText = set.weight == 0 ? "" : set.weight.formatted(.number.grouping(.never))
        }
        if focusedField != .reps { repsText = set.reps == 0 ? "" : "\(set.reps)" }
    }
    
    private func commitWeight(_ text: String) {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = normalized.isEmpty ? 0 : Double(normalized),
              value.isFinite, value >= 0, value <= 1_000_000 else { return }
        guard value != set.weight else { return }
        var newSet = set
        newSet.weight = value
        appState.updateSet(newSet, atIndex: setIndex, exerciseId: exerciseId, workoutId: workoutId, weekId: weekId)
    }
    
    private func commitReps(_ text: String) {
        guard let value = text.isEmpty ? 0 : Int(text), value >= 0, value <= 1_000_000 else { return }
        guard value != set.reps else { return }
        var newSet = set
        newSet.reps = value
        appState.updateSet(newSet, atIndex: setIndex, exerciseId: exerciseId, workoutId: workoutId, weekId: weekId)
    }
}

/// Sheet для вибору тривалості таймера (пресети + кастом)
struct TimerSelectionSheet: View {
    let onStart: (Int) -> Void
    
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    @Environment(\.dismiss) var dismiss
    
    @State private var customMinutes: String = "0"
    @State private var customSeconds: String = "30"
    
    private let presets = [60, 90, 120, 180, 240, 300]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(s.restAfterSet)
                        .font(.title3).fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                        .padding(.horizontal, 16)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                        ForEach(presets, id: \.self) { sec in
                            Button {
                                onStart(sec)
                                dismiss()
                            } label: {
                                VStack(spacing: 2) {
                                    Text(formatTime(sec))
                                        .font(.title3).fontWeight(.bold)
                                        .foregroundStyle(theme.accent)
                                }
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(theme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(s.restCustom)
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(theme.textSecondary).textCase(.uppercase)
                        
                        HStack(spacing: 8) {
                            TextField("0", text: $customMinutes)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.title2)
                                .padding(.vertical, 10)
                                .frame(width: 70)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            Text(s.min).foregroundStyle(theme.textSecondary)
                            
                            TextField("30", text: $customSeconds)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.title2)
                                .padding(.vertical, 10)
                                .frame(width: 70)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            Text(s.sec).foregroundStyle(theme.textSecondary)
                            
                            Spacer()
                            
                            Button {
                                let m = Int(customMinutes) ?? 0
                                let sec = Int(customSeconds) ?? 0
                                let total = m * 60 + sec
                                if total > 0 {
                                    onStart(total)
                                    dismiss()
                                }
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding(.top, 16)
            }
            .navigationTitle(s.restTimer)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.cancel) { dismiss() }
                }
            }
        }
        .presentationDetents([.height(420)])
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let sec = seconds % 60
        if m > 0 && sec > 0 {
            return "\(m):\(String(format: "%02d", sec))"
        } else if m > 0 {
            return "\(m) \(s.min)"
        } else {
            return "\(sec) \(s.sec)"
        }
    }
}
