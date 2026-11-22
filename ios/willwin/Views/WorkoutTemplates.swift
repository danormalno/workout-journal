import SwiftUI
import Combine

// MARK: - Модель

struct TemplateExercise: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var muscleGroupRaw: String? = nil
    var sets: Int = 3

    var muscleGroup: MuscleGroup? {
        muscleGroupRaw.flatMap { MuscleGroup(rawValue: $0) }
    }
}

struct WorkoutTemplate: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var exercises: [TemplateExercise] = []
    var createdAt: Date = Date()
}

// MARK: - Сховище (UserDefaults, окремо від AppData)

final class TemplateStore: ObservableObject {
    static let shared = TemplateStore()
    @Published private(set) var templates: [WorkoutTemplate] = []
    private let key = "willwin_templates_v1"

    private init() { load() }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) else { return }
        templates = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func upsert(_ t: WorkoutTemplate) {
        if let idx = templates.firstIndex(where: { $0.id == t.id }) {
            templates[idx] = t
        } else {
            templates.append(t)
        }
        persist()
    }

    func remove(at offsets: IndexSet) {
        templates.remove(atOffsets: offsets)
        persist()
    }
}

// MARK: - Список шаблонів

struct TemplatesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @StateObject private var store = TemplateStore.shared

    @State private var editingTemplate: WorkoutTemplate? = nil
    @State private var applyTarget: WorkoutTemplate? = nil
    @State private var appliedNote: String? = nil
    @State private var showAppliedAlert = false

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                // Готові програми — завжди вгорі
                Section {
                    NavigationLink {
                        ProgramCatalogView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "books.vertical.fill")
                                .foregroundStyle(theme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(catalogTitle)
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundStyle(theme.textPrimary)
                                Text(catalogSubtitle)
                                    .font(.caption2)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                }

                // Власні шаблони
                Section(myTemplatesTitle) {
                    if store.templates.isEmpty {
                        Text(emptyText)
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    } else {
                        ForEach(store.templates) { t in
                            Button {
                                editingTemplate = t
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(t.name)
                                            .font(.subheadline).fontWeight(.semibold)
                                            .foregroundStyle(theme.textPrimary)
                                        Text("\(t.exercises.count) \(exercisesWord)")
                                            .font(.caption2)
                                            .foregroundStyle(theme.textSecondary)
                                    }
                                    Spacer()
                                    Button {
                                        applyTarget = t
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(theme.accent)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .onDelete { store.remove(at: $0) }
                    }
                    Button {
                        editingTemplate = WorkoutTemplate(name: "", exercises: [TemplateExercise()])
                    } label: {
                        Label(newTemplateLabel, systemImage: "plus")
                            .foregroundStyle(theme.accent)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingTemplate = WorkoutTemplate(name: "", exercises: [TemplateExercise()])
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .sheet(item: $editingTemplate) { t in
            TemplateEditorView(initial: t) { updated in store.upsert(updated) }
                .environmentObject(appState)
                .environment(\.strings, s)
                .environment(\.appTheme, theme)
        }
        .sheet(item: $applyTarget) { t in
            TemplateApplySheet(
                template: t,
                onApply: { week in apply(t, to: week) },
                onApplyNewWeek: { applyToNewWeek(t) }
            )
            .environmentObject(appState)
            .environment(\.strings, s)
            .environment(\.appTheme, theme)
        }
        .alert(appliedNote ?? "", isPresented: $showAppliedAlert) {
            Button(s.done, role: .cancel) { }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.on.square")
                .font(.system(size: 54))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text(emptyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 32)
            Button {
                editingTemplate = WorkoutTemplate(name: "", exercises: [TemplateExercise()])
            } label: {
                Label(newTemplateLabel, systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Застосування

    private func apply(_ t: WorkoutTemplate, to week: Week) {
        appState.addWorkout(to: week)
        guard let wk = appState.currentWeek(id: week.id),
              let newWorkout = wk.workouts.last else { return }
        addExercises(t, workoutId: newWorkout.id, weekId: week.id)
        appliedNote = appliedText
        showAppliedAlert = true
    }

    private func applyToNewWeek(_ t: WorkoutTemplate) {
        appState.addWeek()
        guard let week = appState.data.weeks.last else { return }
        apply(t, to: week)
    }

    private func addExercises(_ t: WorkoutTemplate, workoutId: UUID, weekId: UUID) {
        for te in t.exercises where !te.name.trimmingCharacters(in: .whitespaces).isEmpty {
            var ex = Exercise(name: te.name, muscleGroup: te.muscleGroup)
            ex.sets = (0..<max(1, te.sets)).map { _ in ExerciseSet() }
            appState.addExercise(ex, toWorkoutId: workoutId, inWeekId: weekId)
        }
    }

    // MARK: - Локалізація

    private var screenTitle: String {
        L("Шаблони", "Templates", "Шаблоны", "Plantillas", "Vorlagen", "Modèles", "Modelos", "Szablony", "Modelli")
    }
    private var catalogTitle: String {
        L("Готові програми", "Built-in programs", "Готовые программы", "Programas listos", "Fertige Programme",
          "Programmes prêts", "Programas prontos", "Gotowe programy", "Programmi pronti")
    }
    private var catalogSubtitle: String {
        L("Чоловічі, жіночі, для спини — обери й застосуй",
          "Men's, women's, back-safe — pick and apply",
          "Мужские, женские, для спины — выбери и применяй",
          "Para hombres, mujeres y espalda — elige y aplica",
          "Männer, Frauen, rückenschonend — wählen und anwenden",
          "Hommes, femmes, dos — choisir et appliquer",
          "Masculinos, femininos, para costas — escolha e aplique",
          "Męskie, damskie, dla pleców — wybierz i zastosuj",
          "Uomo, donna, schiena — scegli e applica")
    }
    private var myTemplatesTitle: String {
        L("Мої шаблони", "My templates", "Мои шаблоны", "Mis plantillas", "Meine Vorlagen",
          "Mes modèles", "Meus modelos", "Moje szablony", "I miei modelli")
    }
    private var exercisesWord: String {
        L("вправ", "exercises", "упражнений", "ejercicios", "Übungen", "exercices", "exercícios", "ćwiczeń", "esercizi")
    }
    private var newTemplateLabel: String {
        L("Новий шаблон", "New template", "Новый шаблон", "Nueva plantilla", "Neue Vorlage",
          "Nouveau modèle", "Novo modelo", "Nowy szablon", "Nuovo modello")
    }
    private var emptyText: String {
        L("Створи шаблон тренування й застосовуй його в один тап.",
          "Create a workout template and apply it in one tap.",
          "Создай шаблон тренировки и применяй в один тап.",
          "Crea una plantilla y aplícala con un toque.",
          "Erstelle eine Vorlage und wende sie mit einem Tipp an.",
          "Crée un modèle et applique-le en un tap.",
          "Crie um modelo e aplique num toque.",
          "Utwórz szablon i zastosuj jednym dotknięciem.",
          "Crea un modello e applicalo con un tocco.")
    }
    private var appliedText: String {
        L("Шаблон застосовано ✓", "Template applied ✓", "Шаблон применён ✓", "Plantilla aplicada ✓",
          "Vorlage angewendet ✓", "Modèle appliqué ✓", "Modelo aplicado ✓", "Szablon zastosowany ✓", "Modello applicato ✓")
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
}

// MARK: - Редактор шаблону

struct TemplateEditorView: View {
    @State private var template: WorkoutTemplate
    let onSave: (WorkoutTemplate) -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @Environment(\.dismiss) var dismiss

    init(initial: WorkoutTemplate, onSave: @escaping (WorkoutTemplate) -> Void) {
        _template = State(initialValue: initial)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                Form {
                    Section(nameTitle) {
                        TextField(namePlaceholder, text: $template.name)
                    }
                    Section(exercisesTitle) {
                        ForEach($template.exercises) { $ex in
                            VStack(alignment: .leading, spacing: 8) {
                                TextField(exNamePlaceholder, text: $ex.name)
                                    .font(.subheadline)
                                HStack {
                                    Picker("", selection: Binding(
                                        get: { ex.muscleGroupRaw ?? "" },
                                        set: { ex.muscleGroupRaw = $0.isEmpty ? nil : $0 }
                                    )) {
                                        Text("—").tag("")
                                        ForEach(MuscleGroup.displayOrder, id: \.self) { g in
                                            Text(s.muscleGroupName(g)).tag(g.rawValue)
                                        }
                                    }
                                    .labelsHidden()
                                    Spacer()
                                    Stepper("\(setsLabel): \(ex.sets)", value: $ex.sets, in: 1...10)
                                        .fixedSize()
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .onDelete { template.exercises.remove(atOffsets: $0) }

                        Button {
                            template.exercises.append(TemplateExercise())
                        } label: {
                            Label(addExerciseLabel, systemImage: "plus")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(editorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.save) {
                        var t = template
                        t.exercises = t.exercises.filter {
                            !$0.name.trimmingCharacters(in: .whitespaces).isEmpty
                        }
                        onSave(t)
                        dismiss()
                    }
                    .bold()
                    .disabled(template.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(s.done) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                        to: nil, from: nil, for: nil)
                    }.bold()
                }
            }
        }
    }

    private var editorTitle: String {
        L("Шаблон", "Template", "Шаблон", "Plantilla", "Vorlage", "Modèle", "Modelo", "Szablon", "Modello")
    }
    private var nameTitle: String {
        L("Назва", "Name", "Название", "Nombre", "Name", "Nom", "Nome", "Nazwa", "Nome")
    }
    private var namePlaceholder: String {
        L("Напр. Груди + трицепс", "e.g. Chest + triceps", "Напр. Грудь + трицепс", "Ej. Pecho + tríceps",
          "z.B. Brust + Trizeps", "ex. Pecs + triceps", "ex. Peito + tríceps", "np. Klatka + triceps", "es. Petto + tricipiti")
    }
    private var exercisesTitle: String {
        L("Вправи", "Exercises", "Упражнения", "Ejercicios", "Übungen", "Exercices", "Exercícios", "Ćwiczenia", "Esercizi")
    }
    private var exNamePlaceholder: String {
        L("Назва вправи", "Exercise name", "Название упражнения", "Nombre del ejercicio", "Übungsname",
          "Nom de l'exercice", "Nome do exercício", "Nazwa ćwiczenia", "Nome esercizio")
    }
    private var setsLabel: String {
        L("Підходи", "Sets", "Подходы", "Series", "Sätze", "Séries", "Séries", "Serie", "Serie")
    }
    private var addExerciseLabel: String {
        L("Додати вправу", "Add exercise", "Добавить упражнение", "Añadir ejercicio", "Übung hinzufügen",
          "Ajouter un exercice", "Adicionar exercício", "Dodaj ćwiczenie", "Aggiungi esercizio")
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
}

// MARK: - Вибір тижня для застосування

struct TemplateApplySheet: View {
    let template: WorkoutTemplate
    let onApply: (Week) -> Void
    let onApplyNewWeek: () -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                List {
                    Section(chooseWeekTitle) {
                        ForEach(appState.data.weeks) { week in
                            Button {
                                onApply(week); dismiss()
                            } label: {
                                HStack {
                                    Text(weekLabel(week)).foregroundStyle(theme.textPrimary)
                                    Spacer()
                                    Text("\(week.workouts.count)").foregroundStyle(theme.textSecondary)
                                }
                            }
                        }
                        Button {
                            onApplyNewWeek(); dismiss()
                        } label: {
                            Label(newWeekLabel, systemImage: "plus")
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("\(applyTitle): \(template.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.cancel) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func weekLabel(_ week: Week) -> String {
        week.customName.isEmpty ? "\(s.week) \(week.number)" : week.customName
    }
    private var chooseWeekTitle: String {
        L("Куди додати", "Where to add", "Куда добавить", "Dónde añadir", "Wohin hinzufügen",
          "Où ajouter", "Onde adicionar", "Gdzie dodać", "Dove aggiungere")
    }
    private var newWeekLabel: String {
        L("Новий тиждень", "New week", "Новая неделя", "Nueva semana", "Neue Woche",
          "Nouvelle semaine", "Nova semana", "Nowy tydzień", "Nuova settimana")
    }
    private var applyTitle: String {
        L("Застосувати", "Apply", "Применить", "Aplicar", "Anwenden", "Appliquer", "Aplicar", "Zastosuj", "Applica")
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
}
