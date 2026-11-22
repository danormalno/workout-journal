import SwiftUI

enum TrainingRoute: Hashable, Codable {
    case week(UUID)
    case workout(weekId: UUID, workoutId: UUID)
}

struct WeeksListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    @State private var editingWeek: Week? = nil
    @State private var editingNumberText: String = ""
    @State private var editingNameText: String = ""
    @State private var editingCycleOverrideText: String = ""
    @State private var weekToDelete: Week? = nil
    @State private var showTools: Bool = false
    @State private var navigationPath: [TrainingRoute] = []
    @State private var restoredNavigation = false
    @AppStorage("willwin_training_navigation") private var savedNavigation = Data()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                theme.background.ignoresSafeArea()
                WallpaperBackground()
                if appState.data.weeks.isEmpty {
                    emptyState
                } else {
                    weeksList
                }
            }
            .navigationTitle(s.weeks)
            .navigationDestination(for: TrainingRoute.self) { route in
                switch route {
                case .week(let id):
                    if appState.currentWeek(id: id) != nil { WorkoutsListView(weekId: id) }
                case .workout(let weekId, let workoutId):
                    if appState.currentWorkout(weekId: weekId, workoutId: workoutId) != nil {
                        WorkoutDetailView(weekId: weekId, workoutId: workoutId)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showTools = true
                    } label: {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundStyle(theme.accent)
                    }
                }
                if !appState.data.weeks.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .foregroundStyle(theme.accent)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation { appState.addWeek() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(theme.accent)
                    }
                    .accessibilityIdentifier("addWeek")
                }
            }
            .navigationDestination(isPresented: $showTools) {
                ToolsHubView()
            }
            .sheet(item: $editingWeek) { week in
                editSheet(for: week)
            }
            .alert(s.confirmDelete, isPresented: Binding(
                get: { weekToDelete != nil },
                set: { if !$0 { weekToDelete = nil } }
            )) {
                Button(s.cancel, role: .cancel) { weekToDelete = nil }
                Button(s.delete, role: .destructive) {
                    if let w = weekToDelete {
                        withAnimation { appState.deleteWeek(w) }
                    }
                    weekToDelete = nil
                }
            } message: {
                Text(s.deleteWeekMessage)
            }
        }
        .onAppear {
            guard !restoredNavigation else { return }
            restoredNavigation = true
            let saved = (try? JSONDecoder().decode([TrainingRoute].self, from: savedNavigation)) ?? []
            navigationPath = Array(saved.prefix { route in
                switch route {
                case .week(let id): return appState.currentWeek(id: id) != nil
                case .workout(let weekId, let workoutId):
                    return appState.currentWorkout(weekId: weekId, workoutId: workoutId) != nil
                }
            })
        }
        .onChange(of: navigationPath) { _, path in
            savedNavigation = (try? JSONEncoder().encode(path)) ?? Data()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text(s.noWeeksYet)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
            Button {
                withAnimation { appState.addWeek() }
            } label: {
                Label(s.addWeek, systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var weeksList: some View {
        List {
            ForEach(appState.data.weeks) { week in
                NavigationLink(value: TrainingRoute.week(week.id)) {
                    weekRow(week)
                }
                .accessibilityIdentifier("weekRow-\(week.id)")
                .listRowBackground(theme.cardBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        weekToDelete = week
                    } label: {
                        Label(s.delete, systemImage: "trash")
                    }
                    Button {
                        withAnimation { appState.duplicateWeek(week) }
                    } label: {
                        Label(s.duplicate, systemImage: "doc.on.doc")
                    }
                    .tint(theme.accent)
                }
                .contextMenu {
                    Button {
                        editingNumberText = "\(week.number)"
                        editingNameText = week.customName
                        editingCycleOverrideText = week.cycleSizeOverride.map { "\($0)" } ?? ""
                        editingWeek = week
                    } label: {
                        Label(s.rename, systemImage: "pencil")
                    }
                    Button {
                        withAnimation { appState.duplicateWeek(week) }
                    } label: {
                        Label(s.duplicate, systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) {
                        weekToDelete = week
                    } label: {
                        Label(s.delete, systemImage: "trash")
                    }
                }
            }
            .onMove { source, destination in
                appState.moveWeek(from: source, to: destination)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.background)
    }
    
    private func weekRow(_ week: Week) -> some View {
        HStack(spacing: 14) {
            Text("\(week.number)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accent)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                if !week.customName.isEmpty {
                    Text(week.customName)
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text("\(s.week) \(week.number) · \(week.workouts.count) \(s.workouts.lowercased())")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                } else {
                    Text("\(s.week) \(week.number)")
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Text("\(week.workouts.count) \(s.workouts.lowercased())")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
                if let override = week.cycleSizeOverride {
                    Text("\(s.cycle): \(override)")
                        .font(.caption2)
                        .foregroundStyle(theme.accent)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func editSheet(for week: Week) -> some View {
        NavigationStack {
            Form {
                Section(s.weekNumber) {
                    TextField(s.weekNumber, text: $editingNumberText)
                        .keyboardType(.numberPad)
                }
                Section(s.nameOptional) {
                    TextField(s.nameOptional, text: $editingNameText)
                }
                Section {
                    HStack {
                        Text(s.cycleSizeOverride)
                        Spacer()
                        TextField("—", text: $editingCycleOverrideText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                } footer: {
                    Text(s.cycleSizeOverrideHelp)
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .navigationTitle(s.rename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { editingWeek = nil }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.save) {
                        if let n = Int(editingNumberText), n > 0 {
                            appState.updateWeekNumber(week, to: n)
                        }
                        appState.updateWeekName(week, to: editingNameText)
                        let trimmedCycle = editingCycleOverrideText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedCycle.isEmpty {
                            appState.updateWeekCycleSizeOverride(week, to: nil)
                        } else if let v = Int(trimmedCycle), v > 0 {
                            appState.updateWeekCycleSizeOverride(week, to: v)
                        }
                        editingWeek = nil
                    }
                    .bold()
                }
            }
        }
        .presentationDetents([.height(440)])
    }
}
