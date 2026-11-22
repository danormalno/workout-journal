import SwiftUI

/// Pop-up екран для вибору кардіо з бази або створення власного.
struct CardioLibraryPickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    @Environment(\.dismiss) var dismiss
    
    let onSelect: (Cardio) -> Void
    
    @State private var searchText: String = ""
    @State private var showingCustomSheet: Bool = false
    @State private var customName: String = ""
    
    private var language: AppLanguage? {
        appState.data.settings.language
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                contentList
            }
            .navigationTitle(s.cardioLibrary)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: s.searchCardio)
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
                customCardioSheet
            }
        }
    }
    
    private var contentList: some View {
        let filtered = CardioLibrary.search(searchText, language: language)
        let custom = filteredCustomNames()
        
        return List {
            if !custom.isEmpty {
                Section(s.myExercises) {
                    ForEach(custom, id: \.self) { name in
                        Button {
                            onSelect(Cardio(name: name, minutes: 0))
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(theme.textSecondary)
                                Text(name).foregroundStyle(theme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(theme.textSecondary.opacity(0.5)).font(.caption)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    }
                }
            }
            
            Section(s.cardioLibrary) {
                ForEach(filtered.sorted(by: { $0.localizedName(for: language) < $1.localizedName(for: language) })) { c in
                    Button {
                        onSelect(Cardio(name: c.localizedName(for: language), minutes: 0))
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "figure.run")
                                .foregroundStyle(theme.accent)
                            Text(c.localizedName(for: language)).foregroundStyle(theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(theme.textSecondary.opacity(0.5)).font(.caption)
                        }
                    }
                    .listRowBackground(theme.cardBackground)
                }
            }
            
            if filtered.isEmpty && custom.isEmpty && !searchText.isEmpty {
                Section {
                    Button {
                        customName = searchText
                        showingCustomSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").foregroundStyle(theme.accent)
                            VStack(alignment: .leading) {
                                Text(s.createAsCustom).foregroundStyle(theme.textPrimary).fontWeight(.medium)
                                Text("\"\(searchText)\"").font(.caption).foregroundStyle(theme.textSecondary)
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
    
    private func filteredCustomNames() -> [String] {
        let names = appState.customCardioNames
        if searchText.isEmpty { return names }
        let q = searchText.lowercased()
        return names.filter { $0.lowercased().contains(q) }
    }
    
    private var customCardioSheet: some View {
        NavigationStack {
            Form {
                Section(s.cardioName) {
                    TextField(s.cardioName, text: $customName)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(s.addCustomCardio)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { showingCustomSheet = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.save) {
                        let trimmed = customName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        showingCustomSheet = false
                        onSelect(Cardio(name: trimmed, minutes: 0))
                        dismiss()
                    }
                    .bold()
                    .disabled(customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}
