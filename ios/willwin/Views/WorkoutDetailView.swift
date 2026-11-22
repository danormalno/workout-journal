import SwiftUI

struct WorkoutDetailView: View {
    let weekId: UUID
    let workoutId: UUID
    
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    private enum ExercisePickerMode: Identifiable {
        case add
        case replace(UUID)

        var id: String {
            switch self {
            case .add: return "add"
            case .replace(let id): return id.uuidString
            }
        }
    }
    @State private var exercisePicker: ExercisePickerMode?
    @State private var showingCardioPicker: Bool = false
    @State private var showingMaxExercisesAlert: Bool = false
    @State private var showingMaxCardioAlert: Bool = false
    
    @State private var notesText: String = ""
    
    private var workout: Workout? {
        appState.currentWorkout(weekId: weekId, workoutId: workoutId)
    }
    
    private var workoutTitle: String {
        guard let w = workout else { return "" }
        if !w.customName.isEmpty { return w.customName }
        return "\(s.workout) \(w.number)"
    }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            WallpaperBackground()
            
            if let w = workout {
                ScrollView {
                    VStack(spacing: 16) {
                        // Порівняння з минулим однотипним тренуванням
                        if let target = previousComparableTonnage(), target > 0 {
                            beatLastBanner(current: w.tonnage, target: target)
                        }

                        // Список вправ і блоків
                        exerciseItemsSection(workout: w)
                        
                        // Кнопка додати вправу (тільки одна тепер)
                        addExerciseButton(workout: w)
                        
                        // Кардіо після
                        cardioAfterSection(items: w.cardioAfter)
                        
                        // Тоннаж тренування
                        if w.tonnage > 0 {
                            tonnageTotalView(tonnage: w.tonnage)
                        }
                        
                        // Коментар
                        notesSection
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationTitle(workoutTitle)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $exercisePicker) { mode in
            ExerciseLibraryPickerView { exercise in
                switch mode {
                case .add:
                    appState.addExercise(exercise, toWorkoutId: workoutId, inWeekId: weekId)
                case .replace(let id):
                    appState.replaceExercise(with: exercise, exerciseId: id, workoutId: workoutId, weekId: weekId)
                }
            }
        }
        .sheet(isPresented: $showingCardioPicker) {
            CardioLibraryPickerView { cardio in
                appState.addCardio(cardio, position: .after, workoutId: workoutId, weekId: weekId)
            }
        }
        .alert(s.maxExercisesReached, isPresented: $showingMaxExercisesAlert) {
            Button(s.done, role: .cancel) { }
        }
        .alert(s.maxCardioReached, isPresented: $showingMaxCardioAlert) {
            Button(s.done, role: .cancel) { }
        }
        .onAppear {
            notesText = workout?.notes ?? ""
        }
    }
    
    // MARK: - Кардіо після
    
    @ViewBuilder
    private func cardioAfterSection(items: [Cardio]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(s.cardioAfter)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.textSecondary)
                    .textCase(.uppercase)
                    .readableOnWallpaper()
                Spacer()
                Button {
                    if items.count >= AppState.maxCardioPerSection {
                        showingMaxCardioAlert = true
                    } else {
                        showingCardioPicker = true
                    }
                } label: {
                    Label(s.addCardio, systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(theme.accent)
                }
            }
            
            ForEach(items) { cardio in
                CardioCard(
                    cardio: cardio,
                    position: .after,
                    weekId: weekId,
                    workoutId: workoutId
                )
            }
        }
    }
    
    // MARK: - Вправи і блоки
    
    @ViewBuilder
    private func exerciseItemsSection(workout w: Workout) -> some View {
        if w.items.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 50))
                    .foregroundStyle(theme.textSecondary.opacity(0.4))
                    .readableOnWallpaper()
                Text(s.noExercisesYet)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.textSecondary)
                    .readableOnWallpaper()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else {
            VStack(spacing: 12) {
                ForEach(w.items) { item in
                    switch item {
                    case .exercise(let ex):
                        ExerciseCard(
                            exercise: ex,
                            weekId: weekId,
                            workoutId: workoutId,
                            onDelete: {
                                appState.deleteWorkoutItem(itemId: ex.id, workoutId: workoutId, weekId: weekId)
                            },
                            onReplace: { exercisePicker = .replace(ex.id) }
                        )
                    case .block(let b):
                        blockDividerView(block: b)
                    }
                }
            }
        }
    }
    
    private func blockDividerView(block: ExerciseBlock) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(theme.textSecondary.opacity(0.3)).frame(height: 1)
            Text(block.name.isEmpty ? "—" : block.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            Rectangle().fill(theme.textSecondary.opacity(0.3)).frame(height: 1)
            Menu {
                Button(role: .destructive) {
                    appState.deleteWorkoutItem(itemId: block.id, workoutId: workoutId, weekId: weekId)
                } label: {
                    Label(s.delete, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(theme.textSecondary)
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Кнопка додати вправу
    
    private func addExerciseButton(workout w: Workout) -> some View {
        Button {
            if w.exerciseCount >= AppState.maxExercisesPerWorkout {
                showingMaxExercisesAlert = true
            } else {
                exercisePicker = .add
            }
        } label: {
            Label(s.addExercise, systemImage: "plus")
                .font(.subheadline)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(theme.accent.opacity(0.15))
                .foregroundStyle(theme.accent)
                .clipShape(Capsule())
        }
        .accessibilityIdentifier("addExercise")
    }
    
    // MARK: - Тоннаж
    
    // MARK: - «Перевершити минуле тренування»

    private func tonnageTotalView(tonnage: Double) -> some View {
        HStack {
            Text(s.tonnage)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text("\(Int(tonnage)) \(s.kg)")
                .font(.headline)
                .foregroundStyle(theme.accent)
        }
        .padding(14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    /// Тоннаж найсвіжішого попереднього однотипного тренування (>0), яке варто перевершити.
    private func previousComparableTonnage() -> Double? {
        guard let current = workout else { return nil }
        let chrono = CyclesEngine.chronologicalWorkouts(from: appState.data) // старі → нові

        // Якщо поточне вже в історії — шукаємо лише раніші за нього; інакше — всю історію.
        let upperBound: Int
        if let idx = chrono.firstIndex(where: { $0.workout.id == current.id }) {
            upperBound = idx
        } else {
            upperBound = chrono.count
        }

        var j = upperBound - 1
        while j >= 0 {
            let w = chrono[j].workout
            if w.id != current.id, isComparable(w, current), w.tonnage > 0 {
                return w.tonnage
            }
            j -= 1
        }
        return nil
    }

    /// Однотипні, якщо збігається назва тренування або набір вправ.
    private func isComparable(_ a: Workout, _ b: Workout) -> Bool {
        let na = a.customName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let nb = b.customName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !na.isEmpty && na == nb { return true }
        let sa = exerciseSignature(a)
        let sb = exerciseSignature(b)
        return !sa.isEmpty && sa == sb
    }

    private func exerciseSignature(_ w: Workout) -> String {
        let names = w.exercises
            .map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        return Set(names).sorted().joined(separator: "|")
    }

    @ViewBuilder
    private func beatLastBanner(current: Double, target: Double) -> some View {
        let beaten = current >= target
        let remaining = max(0, target - current)
        HStack(spacing: 12) {
            Image(systemName: beaten ? "trophy.fill" : "chart.line.uptrend.xyaxis")
                .font(.title3)
                .foregroundStyle(beaten ? Color.green : theme.accent)
            VStack(alignment: .leading, spacing: 2) {
                if beaten {
                    Text(beatenTitle)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                    Text("+\(Int(current - target)) \(s.kg) " + overPrevWord)
                        .font(.caption2)
                        .foregroundStyle(theme.textSecondary)
                } else {
                    Text(remainingPrefix + " +\(Int(remaining)) \(s.kg)")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(theme.textPrimary)
                    Text("\(lastTimeWord): \(Int(target)) \(s.kg)")
                        .font(.caption2)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            Spacer()
        }
        .padding(14)
        .background((beaten ? Color.green : theme.accent).opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var remainingPrefix: String {
        L("До рекорду минулого разу ще", "To beat last time, add", "До рекорда прошлого раза ещё",
          "Para superar la última vez, suma", "Um die letzte Einheit zu schlagen, noch",
          "Pour battre la dernière fois, encore", "Para superar a última vez, mais",
          "Aby pobić poprzedni raz, jeszcze", "Per battere l'ultima volta, ancora")
    }
    private var beatenTitle: String {
        L("Минуле тренування перевершено ✓", "Last workout beaten ✓", "Прошлая тренировка превзойдена ✓",
          "Entrenamiento anterior superado ✓", "Letztes Workout übertroffen ✓", "Dernière séance battue ✓",
          "Treino anterior superado ✓", "Poprzedni trening pobity ✓", "Allenamento precedente superato ✓")
    }
    private var overPrevWord: String {
        L("над минулим", "over last time", "над прошлым", "sobre la última vez", "über letztes Mal",
          "par rapport à la dernière fois", "sobre a última vez", "względem poprzedniego", "rispetto all'ultima volta")
    }
    private var lastTimeWord: String {
        L("Минулого разу", "Last time", "Прошлый раз", "La última vez", "Letztes Mal",
          "La dernière fois", "Da última vez", "Poprzednio", "L'ultima volta")
    }

    private func L(_ uk: String, _ en: String, _ ru: String, _ es: String, _ de: String,
                   _ fr: String, _ pt: String, _ pl: String, _ it: String) -> String {
        switch appState.data.settings.language {
        case .en: return en
        case .ru: return ru
        case .es: return es
        case .de: return de
        case .fr: return fr
        case .pt: return pt
        case .pl: return pl
        case .it: return it
        default:  return uk
        }
    }
    
    // MARK: - Коментар
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(s.notesTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)
                .readableOnWallpaper()
            
            ZStack(alignment: .topLeading) {
                if notesText.isEmpty {
                    Text(s.notesPlaceholder)
                        .foregroundStyle(theme.textSecondary.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $notesText)
                    .accessibilityIdentifier("workoutNotes")
                    .scrollContentBackground(.hidden)
                    .background(theme.background)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minHeight: 100)
                    .onChange(of: notesText) { _, newVal in
                        appState.updateWorkoutNotes(weekId: weekId, workoutId: workoutId, notes: newVal)
                    }
            }
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
