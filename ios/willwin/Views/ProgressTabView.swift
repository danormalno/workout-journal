import SwiftUI
import Charts

struct ProgressTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    enum Mode: String, CaseIterable {
        case cycles
        case exercise
    }
    
    @State private var mode: Mode = .cycles
    @State private var selectedExerciseName: String = ""
    
    private var cycles: [TrainingCycle] {
        CyclesEngine.buildCycles(from: appState.data)
    }
    
    /// Усі унікальні назви вправ із даних
    private var allExerciseNames: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for week in appState.data.weeks {
            for workout in week.workouts {
                for ex in workout.exercises {
                    let trimmed = ex.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let lower = trimmed.lowercased()
                    if !trimmed.isEmpty && !seen.contains(lower) {
                        seen.insert(lower)
                        result.append(trimmed)
                    }
                }
            }
        }
        return result.sorted()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                WallpaperBackground()
                
                VStack(spacing: 0) {
                    Picker("", selection: $mode) {
                        Text(s.progressByCycles).tag(Mode.cycles)
                        Text(s.progressByExercise).tag(Mode.exercise)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    ScrollView {
                        Group {
                            if mode == .cycles {
                                cyclesModeContent
                            } else {
                                exerciseModeContent
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(s.progress)
        }
    }
    
    // MARK: - Режим циклів
    
    @ViewBuilder
    private var cyclesModeContent: some View {
        let cs = cycles
        if cs.count < 2 {
            needMoreCyclesView
        } else {
            let current = cs[cs.count - 1]
            let previous = cs[cs.count - 2]
            let comparison = CyclesEngine.compare(current: current, previous: previous)
            cycleComparisonView(comparison: comparison)
        }
    }
    
    private var needMoreCyclesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundStyle(theme.textSecondary.opacity(0.4))
            Text(s.needMoreCyclesToCompare)
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
                .multilineTextAlignment(.center)
            Text(s.needMoreCyclesHint)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
    
    private func cycleComparisonView(comparison: CycleComparison) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            cycleHeader(current: comparison.current, previous: comparison.previous)
            tonnageOverall(comparison: comparison)
            summaryStats(comparison: comparison)
            exercisesList(comparison: comparison)
        }
    }
    
    private func cycleHeader(current: TrainingCycle, previous: TrainingCycle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(s.cycleComparison)
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(theme.textPrimary)
            Text("\(s.cycle) \(current.index) vs \(s.cycle) \(previous.index)")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
    }
    
    private func tonnageOverall(comparison: CycleComparison) -> some View {
        let isUp = comparison.tonnageChange > 0
        let isDown = comparison.tonnageChange < 0
        let color: Color = isUp ? .green : (isDown ? theme.danger : theme.textSecondary)
        let icon = isUp ? "arrow.up.right" : (isDown ? "arrow.down.right" : "arrow.right")
        
        return VStack(alignment: .leading, spacing: 6) {
            Text(s.totalTonnageChange)
                .font(.caption).foregroundStyle(theme.textSecondary).textCase(.uppercase)
            HStack(spacing: 8) {
                Text("\(Int(comparison.current.tonnage)) \(s.kg)")
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(theme.textPrimary)
                Image(systemName: icon).foregroundStyle(color)
                Text(formatPercent(comparison.tonnagePercent))
                    .font(.subheadline).fontWeight(.semibold).foregroundStyle(color)
            }
            Text("\(s.previousCycle): \(Int(comparison.previous.tonnage)) \(s.kg)")
                .font(.caption).foregroundStyle(theme.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func summaryStats(comparison: CycleComparison) -> some View {
        HStack(spacing: 10) {
            statBox(value: "\(comparison.improvedCount)", label: s.exercisesImproved, color: .green)
            statBox(value: "\(comparison.declinedCount)", label: s.exercisesDeclined, color: theme.danger)
            statBox(value: "\(comparison.totalCount - comparison.improvedCount - comparison.declinedCount)",
                    label: s.exercisesNoChange, color: theme.textSecondary)
        }
    }
    
    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2).fontWeight(.bold).foregroundStyle(color)
            Text(label).font(.caption2).multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .padding(.vertical, 8)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    @ViewBuilder
    private func exercisesList(comparison: CycleComparison) -> some View {
        if comparison.exerciseComparisons.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 30))
                    .foregroundStyle(theme.textSecondary.opacity(0.5))
                Text(s.noCommonExercises)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 24)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text(s.progressByExercise)
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(theme.textSecondary).textCase(.uppercase)
                ForEach(comparison.exerciseComparisons) { comp in
                    exerciseProgressRow(comp)
                }
            }
        }
    }
    
    private func exerciseProgressRow(_ comp: ExerciseComparison) -> some View {
        let (icon, color, mainText, detailText): (String, Color, String, String) = {
            switch comp.progressType {
            case .weightUp(let from, let to, let pct):
                return ("arrow.up.right", .green,
                        "\(formatWeight(from)) → \(formatWeight(to)) \(s.kg)",
                        "\(s.weightProgressed) (+\(formatPercent(pct)))")
            case .repsUp(let weight, let fromReps, let toReps, let pct):
                let w = weight > 0 ? "\(formatWeight(weight)) \(s.kg) × " : ""
                return ("arrow.up.right", .green,
                        "\(w)\(fromReps) → \(toReps) \(s.reps)",
                        "\(s.repsProgressed) (+\(formatPercent(pct)))")
            case .tonnageUp(let from, let to, let pct):
                return ("arrow.up.right", .green,
                        "\(Int(from)) → \(Int(to)) \(s.kg)",
                        "\(s.tonnageProgressed) (+\(formatPercent(pct)))")
            case .weightDown(let from, let to, let pct):
                return ("arrow.down.right", theme.danger,
                        "\(formatWeight(from)) → \(formatWeight(to)) \(s.kg)",
                        "−\(formatPercent(pct))")
            case .repsDown(let weight, let fromReps, let toReps, let pct):
                let w = weight > 0 ? "\(formatWeight(weight)) \(s.kg) × " : ""
                return ("arrow.down.right", theme.danger,
                        "\(w)\(fromReps) → \(toReps) \(s.reps)",
                        "−\(formatPercent(pct))")
            case .tonnageDown(let from, let to, let pct):
                return ("arrow.down.right", theme.danger,
                        "\(Int(from)) → \(Int(to)) \(s.kg)",
                        "−\(formatPercent(pct))")
            case .noChange:
                return ("arrow.right", theme.textSecondary, s.noChange, "")
            }
        }()
        
        return HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(color).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(comp.name).font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(theme.textPrimary)
                Text(mainText).font(.caption).foregroundStyle(theme.textSecondary)
                if !detailText.isEmpty {
                    Text(detailText).font(.caption2).foregroundStyle(color)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    // MARK: - Режим "по вправі"
    
    @ViewBuilder
    private var exerciseModeContent: some View {
        let names = allExerciseNames
        
        if names.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "dumbbell")
                    .font(.system(size: 50))
                    .foregroundStyle(theme.textSecondary.opacity(0.4))
                Text(s.noExercisesYet)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                // Селектор вправи
                Menu {
                    ForEach(names, id: \.self) { name in
                        Button(name) {
                            selectedExerciseName = name
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedExerciseName.isEmpty ? s.exerciseName : selectedExerciseName)
                            .font(.headline)
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(theme.textSecondary)
                    }
                    .padding(14)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                if !selectedExerciseName.isEmpty {
                    exerciseProgressChart(for: selectedExerciseName)
                }
            }
            .onAppear {
                if selectedExerciseName.isEmpty, let first = names.first {
                    selectedExerciseName = first
                }
            }
        }
    }
    
    /// Графік прогресу по конкретній вправі — горизонтальний скрол, показуємо останні N тижнів
    private func exerciseProgressChart(for name: String) -> some View {
        let target = name.lowercased()
        
        struct DataPoint: Identifiable, Hashable {
            let id = UUID()
            let weekNumber: Int
            let maxWeight: Double
            let tonnage: Double
        }
        
        // Збираємо ВСІ точки
        var allPoints: [DataPoint] = []
        let sortedWeeks = appState.data.weeks.sorted { $0.number < $1.number }
        for week in sortedWeeks {
            var maxWeight: Double = 0
            var tonnage: Double = 0
            var found = false
            for workout in week.workouts {
                for ex in workout.exercises {
                    let exName = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if exName == target {
                        maxWeight = max(maxWeight, ex.maxWeight)
                        tonnage += ex.tonnage
                        found = true
                    }
                }
            }
            if found {
                allPoints.append(DataPoint(weekNumber: week.number, maxWeight: maxWeight, tonnage: tonnage))
            }
        }
        
        // Визначаємо вікно показу — скільки тижнів вміщується на екрані
        let visibleCount = appState.data.settings.progressChartRange.weeksToShow
        // Ширина однієї точки на графіку
        let pointWidth: CGFloat = 50
        // Загальна ширина графіка: усі точки × pointWidth, якщо більше за visibleCount
        let totalWidth: CGFloat
        if let visible = visibleCount, allPoints.count > visible {
            totalWidth = CGFloat(allPoints.count) * pointWidth
        } else {
            // Якщо точок менше ніж visibleCount, або allTime — розтягуємо на екран
            totalWidth = max(CGFloat(allPoints.count) * pointWidth, 320)
        }
        
        return VStack(alignment: .leading, spacing: 16) {
            if allPoints.count < 2 {
                Text(s.needMoreCyclesHint)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                // Графік ваги
                VStack(alignment: .leading, spacing: 8) {
                    Text(s.weight + " (\(s.kg))")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(theme.textSecondary).textCase(.uppercase)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(allPoints) { p in
                                LineMark(
                                    x: .value("Week", p.weekNumber),
                                    y: .value("Weight", p.maxWeight)
                                )
                                .foregroundStyle(theme.accent)
                                .interpolationMethod(.catmullRom)
                                PointMark(
                                    x: .value("Week", p.weekNumber),
                                    y: .value("Weight", p.maxWeight)
                                )
                                .foregroundStyle(theme.accent)
                                .annotation(position: .top, alignment: .center, spacing: 2) {
                                    Text(formatWeight(p.maxWeight))
                                        .font(.system(size: 9))
                                        .foregroundStyle(theme.textSecondary)
                                }
                            }
                            .frame(width: totalWidth, height: 180)
                            .chartXAxis {
                                AxisMarks(values: allPoints.map { $0.weekNumber }) { value in
                                    if let v = value.as(Int.self) {
                                        AxisValueLabel { Text("\(s.week) \(v)").font(.caption2) }
                                    }
                                    AxisGridLine().foregroundStyle(theme.textSecondary.opacity(0.2))
                                }
                            }
                            .id("weight-chart")
                        }
                        .onAppear {
                            // Скролимо в кінець (останні тижні)
                            DispatchQueue.main.async {
                                proxy.scrollTo("weight-chart", anchor: .trailing)
                            }
                        }
                    }
                }
                .padding(14)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // Графік тоннажу
                VStack(alignment: .leading, spacing: 8) {
                    Text(s.tonnage)
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(theme.textSecondary).textCase(.uppercase)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            Chart(allPoints) { p in
                                BarMark(
                                    x: .value("Week", "\(s.week) \(p.weekNumber)"),
                                    y: .value("Tonnage", p.tonnage)
                                )
                                .foregroundStyle(theme.accent.opacity(0.7))
                            }
                            .frame(width: totalWidth, height: 160)
                            .id("tonnage-chart")
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                proxy.scrollTo("tonnage-chart", anchor: .trailing)
                            }
                        }
                    }
                }
                .padding(14)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatPercent(_ value: Double) -> String {
        let abs = Swift.abs(value)
        if abs >= 100 { return "\(Int(abs))%" }
        return String(format: "%.1f%%", abs)
    }
    
    private func formatWeight(_ value: Double) -> String {
        if value == floor(value) { return "\(Int(value))" }
        return String(format: "%.1f", value)
    }
}
