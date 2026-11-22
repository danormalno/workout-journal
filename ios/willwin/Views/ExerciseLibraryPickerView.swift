import SwiftUI

/// Pop-up екран для вибору вправи з бази або створення власної.
struct ExerciseLibraryPickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    @Environment(\.dismiss) var dismiss
    
    /// Callback при виборі вправи — повертає готовий Exercise
    let onSelect: (Exercise) -> Void
    
    enum ViewMode: String, CaseIterable {
        case alphabetical
        case byGroup
    }
    
    @State private var searchText: String = ""
    @State private var viewMode: ViewMode = .byGroup
    @State private var selectedGroup: MuscleGroup? = nil  // nil = всі
    @State private var showingCustomSheet: Bool = false
    @State private var customName: String = ""
    @State private var customGroup: MuscleGroup = .other
    
    private var language: AppLanguage? {
        appState.data.settings.language
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Перемикач режиму
                    Picker("", selection: $viewMode) {
                        Text(s.byMuscleGroup).tag(ViewMode.byGroup)
                        Text(s.alphabetical).tag(ViewMode.alphabetical)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    // Фільтр по групах (тільки у режимі by group)
                    if viewMode == .byGroup {
                        groupFilter
                    }
                    
                    // Список вправ
                    contentList
                }
            }
            .navigationTitle(s.exerciseLibrary)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: s.searchExercises)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        customName = searchText
                        showingCustomSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingCustomSheet) {
                customExerciseSheet
            }
        }
    }
    
    // MARK: - Фільтр по групах
    
    private var groupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                groupChip(group: nil, label: s.allGroups)
                ForEach(MuscleGroup.displayOrder, id: \.self) { g in
                    groupChip(group: g, label: s.muscleGroupName(g))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
    
    private func groupChip(group: MuscleGroup?, label: String) -> some View {
        let isSelected = (selectedGroup == group)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedGroup = group
            }
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? theme.accent : theme.cardBackground)
                .foregroundStyle(isSelected ? .white : theme.textPrimary)
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Список вправ
    
    private var contentList: some View {
        let filteredLibrary = filteredLibraryExercises()
        let myExercises = filteredCustomNames()
        
        return List {
            // Мої кастомні вправи (показуємо тільки якщо в режимі alphabetical або шукаємо)
            if !myExercises.isEmpty && (viewMode == .alphabetical || !searchText.isEmpty || selectedGroup == nil) {
                Section(s.myExercises) {
                    ForEach(myExercises, id: \.self) { name in
                        Button {
                            selectCustomName(name)
                        } label: {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(theme.textSecondary)
                                Text(name)
                                    .foregroundStyle(theme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(theme.textSecondary.opacity(0.5))
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    }
                }
            }
            
            // Бібліотека
            if viewMode == .byGroup {
                let grouped = Dictionary(grouping: filteredLibrary, by: { $0.muscleGroup })
                ForEach(MuscleGroup.displayOrder, id: \.self) { group in
                    if let items = grouped[group], !items.isEmpty {
                        Section(s.muscleGroupName(group)) {
                            ForEach(items.sorted(by: { $0.localizedName(for: language) < $1.localizedName(for: language) })) { ex in
                                libraryRow(ex)
                            }
                        }
                    }
                }
            } else {
                let sorted = filteredLibrary.sorted { $0.localizedName(for: language) < $1.localizedName(for: language) }
                Section {
                    ForEach(sorted) { ex in
                        libraryRow(ex)
                    }
                }
            }
            
            // Якщо нічого не знайдено і є пошук — пропонуємо створити
            if filteredLibrary.isEmpty && myExercises.isEmpty && !searchText.isEmpty {
                Section {
                    Button {
                        customName = searchText
                        showingCustomSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(theme.accent)
                            VStack(alignment: .leading) {
                                Text(s.createAsCustom)
                                    .foregroundStyle(theme.textPrimary)
                                    .fontWeight(.medium)
                                Text("\"\(searchText)\"")
                                    .font(.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                    .listRowBackground(theme.cardBackground)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.background)
    }
    
    private func libraryRow(_ ex: LibraryExercise) -> some View {
        Button {
            selectLibraryExercise(ex)
        } label: {
            HStack {
                Text(ex.localizedName(for: language))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(theme.textSecondary.opacity(0.5))
                    .font(.caption)
            }
        }
        .listRowBackground(theme.cardBackground)
        .accessibilityIdentifier("libraryExercise-\(ex.id)")
    }
    
    // MARK: - Фільтрація
    
    private func filteredLibraryExercises() -> [LibraryExercise] {
        var result = ExerciseLibrary.all
        if !searchText.isEmpty {
            result = ExerciseLibrary.search(searchText, language: language)
        }
        if viewMode == .byGroup, let g = selectedGroup {
            result = result.filter { $0.muscleGroup == g }
        }
        return result
    }
    
    private func filteredCustomNames() -> [String] {
        let names = appState.customExerciseNames
        if searchText.isEmpty {
            return names
        }
        let q = searchText.lowercased()
        return names.filter { $0.lowercased().contains(q) }
    }
    
    // MARK: - Вибір
    
    private func selectLibraryExercise(_ libEx: LibraryExercise) {
        let exercise = Exercise(
            name: libEx.localizedName(for: language),
            muscleGroup: libEx.muscleGroup,
            sets: [ExerciseSet()]
        )
        onSelect(exercise)
        dismiss()
    }
    
    private func selectCustomName(_ name: String) {
        // Зберігаємо у постійний список — якщо вже є, метод просто нічого не зробить
        appState.addCustomExercise(name: name, muscleGroup: nil)
        let exercise = Exercise(name: name, muscleGroup: nil, sets: [ExerciseSet()])
        onSelect(exercise)
        dismiss()
    }
    
    // MARK: - Sheet для нової вправи
    
    private var customExerciseSheet: some View {
        NavigationStack {
            Form {
                Section(s.exerciseName) {
                    TextField(s.exerciseName, text: $customName)
                        .autocorrectionDisabled()
                }
                Section(s.muscleGroup) {
                    Picker(s.muscleGroup, selection: $customGroup) {
                        ForEach(MuscleGroup.displayOrder, id: \.self) { g in
                            Text(s.muscleGroupName(g)).tag(g)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle(s.addCustomExercise)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { showingCustomSheet = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.save) {
                        let trimmed = customName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        // Зберігаємо в постійний список кастомних вправ
                        appState.addCustomExercise(name: trimmed, muscleGroup: customGroup)
                        let ex = Exercise(name: trimmed, muscleGroup: customGroup, sets: [ExerciseSet()])
                        showingCustomSheet = false
                        onSelect(ex)
                        dismiss()
                    }
                    .bold()
                    .disabled(customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
