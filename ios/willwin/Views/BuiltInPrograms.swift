import SwiftUI

// =====================================================================
// MARK: - Багатомовний рядок
// =====================================================================

struct LocStr: Hashable {
    var uk, en, ru, es, de, fr, pt, pl, it: String

    init(_ uk: String, _ en: String, _ ru: String, _ es: String, _ de: String,
         _ fr: String, _ pt: String, _ pl: String, _ it: String) {
        self.uk = uk; self.en = en; self.ru = ru; self.es = es; self.de = de
        self.fr = fr; self.pt = pt; self.pl = pl; self.it = it
    }

    /// Однакова назва для всіх мов (для власних імен на кшталт "PHUL", "nSuns").
    static func same(_ v: String) -> LocStr { LocStr(v, v, v, v, v, v, v, v, v) }

    func s(_ lang: AppLanguage?) -> String {
        switch lang {
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

// =====================================================================
// MARK: - Елемент програмного дня
// =====================================================================

struct ProgItem: Hashable {
    enum Kind: Hashable { case exercise, block, cardio }

    var kind: Kind
    var exId: String = ""              // id з ExerciseLibrary або CardioLibrary
    var customName: LocStr? = nil      // якщо вправи нема в бібліотеці
    var customMuscle: MuscleGroup = .other
    var sets: Int = 3
    var reps: Int = 0                  // цільові повтори (проставляються), вага = 0
    var scheme: String = ""            // напр. "5×5", "3×8–12", "4×5 @75%", "AMRAP"
    var blockTitle: LocStr? = nil      // для роздільника
    var minutes: Int = 0               // для кардіо

    // Вправа з бібліотеки
    static func ex(_ id: String, _ sets: Int, _ reps: Int, _ scheme: String) -> ProgItem {
        ProgItem(kind: .exercise, exId: id, sets: sets, reps: reps, scheme: scheme)
    }
    // Власна вправа (нема в бібліотеці)
    static func custom(_ name: LocStr, _ mg: MuscleGroup, _ sets: Int, _ reps: Int, _ scheme: String) -> ProgItem {
        ProgItem(kind: .exercise, customName: name, customMuscle: mg, sets: sets, reps: reps, scheme: scheme)
    }
    // Роздільник / секція
    static func block(_ title: LocStr) -> ProgItem {
        ProgItem(kind: .block, blockTitle: title)
    }
    // Кардіо
    static func cardio(_ id: String, _ minutes: Int, _ scheme: String) -> ProgItem {
        ProgItem(kind: .cardio, exId: id, scheme: scheme, minutes: minutes)
    }

    func resolvedName(_ lang: AppLanguage?) -> String {
        if let c = customName { return c.s(lang) }
        if kind == .cardio {
            return CardioLibrary.all.first { $0.id == exId }?.localizedName(for: lang) ?? exId
        }
        return ExerciseLibrary.all.first { $0.id == exId }?.localizedName(for: lang) ?? exId
    }

    func resolvedMuscle() -> MuscleGroup {
        if customName != nil { return customMuscle }
        return ExerciseLibrary.all.first { $0.id == exId }?.muscleGroup ?? .other
    }
}

struct ProgramDay: Hashable {
    var title: LocStr
    var items: [ProgItem]
}

// =====================================================================
// MARK: - Готова програма
// =====================================================================

enum ProgramGender: Hashable { case men, women, any }

enum ProgramCategory: String, CaseIterable, Hashable {
    case beginner, bodybuilding, powerlifting, powerbuilding
    case weightlifting, crossfit, cutting, peakcycle
    case glutes, strength, backsafe

    var title: LocStr {
        switch self {
        case .beginner:      return LocStr("Новачок","Beginner","Новичок","Principiante","Anfänger","Débutant","Iniciante","Początkujący","Principiante")
        case .bodybuilding:  return LocStr("Бодібілдинг","Bodybuilding","Бодибилдинг","Culturismo","Bodybuilding","Bodybuilding","Musculação","Kulturystyka","Bodybuilding")
        case .powerlifting:  return LocStr("Пауерліфтинг","Powerlifting","Пауэрлифтинг","Powerlifting","Kraftdreikampf","Powerlifting","Powerlifting","Trójbój siłowy","Powerlifting")
        case .powerbuilding: return LocStr("Павербілдинг","Powerbuilding","Пауэрбилдинг","Powerbuilding","Powerbuilding","Powerbuilding","Powerbuilding","Powerbuilding","Powerbuilding")
        case .weightlifting: return LocStr("Важка атлетика","Weightlifting","Тяжёлая атлетика","Halterofilia","Gewichtheben","Haltérophilie","Levantamento olímpico","Podnoszenie ciężarów","Sollevamento pesi")
        case .crossfit:      return LocStr("Кросфіт","CrossFit","Кроссфит","CrossFit","CrossFit","CrossFit","CrossFit","CrossFit","CrossFit")
        case .cutting:       return LocStr("Сушка","Cutting","Сушка","Definición","Definitionsphase","Sèche","Definição","Redukcja","Definizione")
        case .peakcycle:     return LocStr("Піковий цикл","Peak Cycle","Пиковый цикл","Ciclo de pico","Peak-Zyklus","Cycle de pic","Ciclo de pico","Cykl szczytowy","Ciclo di picco")
        case .glutes:        return LocStr("Сідниці / ноги","Glutes / Legs","Ягодицы / ноги","Glúteos / piernas","Gesäß / Beine","Fessiers / jambes","Glúteos / pernas","Pośladki / nogi","Glutei / gambe")
        case .strength:      return LocStr("Сила","Strength","Сила","Fuerza","Kraft","Force","Força","Siła","Forza")
        case .backsafe:      return LocStr("Безпечно для спини","Back-safe","Безопасно для спины","Seguro para espalda","Rückenschonend","Sécurité dos","Seguro para costas","Bezpieczne dla pleców","Sicuro per la schiena")
        }
    }
}

enum ProgramLevel: Hashable { case beginner, intermediate, advanced
    var title: LocStr {
        switch self {
        case .beginner:     return LocStr("Новачок","Beginner","Новичок","Principiante","Anfänger","Débutant","Iniciante","Początkujący","Principiante")
        case .intermediate: return LocStr("Середній","Intermediate","Средний","Intermedio","Mittel","Intermédiaire","Intermediário","Średnio zaawansowany","Intermedio")
        case .advanced:     return LocStr("Просунутий","Advanced","Продвинутый","Avanzado","Fortgeschritten","Avancé","Avançado","Zaawansowany","Avanzato")
        }
    }
}

struct BuiltInProgram: Identifiable, Hashable {
    let id: String
    let name: LocStr
    let desc: LocStr        // "що це і кому"
    var tip: LocStr = LocStr("","","","","","","","","")  // підказка в нотатки
    let gender: ProgramGender
    let category: ProgramCategory
    let level: ProgramLevel
    var days: Int           // тренувань на тиждень
    let schedule: [ProgramDay]
}

// =====================================================================
// MARK: - Каталог (дані в розширеннях нижче)
// =====================================================================

enum BuiltInPrograms {
    static var all: [BuiltInProgram] {
        menBeginner + menBodybuilding + menPowerlifting + menPowerbuilding
        + menWeightlifting + menCrossfit + menCutting + peakCycle
        + womenBeginner + womenGlutes + womenStrength + womenCutting
        + backSafe
    }

    static func programs(gender: ProgramGender, category: ProgramCategory) -> [BuiltInProgram] {
        all.filter { $0.gender == gender && $0.category == category }
            .sorted { $0.days < $1.days }
    }

    static func categories(for gender: ProgramGender) -> [ProgramCategory] {
        var seen: [ProgramCategory] = []
        for p in all where p.gender == gender {
            if !seen.contains(p.category) { seen.append(p.category) }
        }
        return seen
    }
}

// =====================================================================
// MARK: - Локалізовані назви днів / секцій (для повторного використання)
// =====================================================================

enum PL {
    static let fullBody  = LocStr("Повне тіло","Full Body","Всё тело","Cuerpo completo","Ganzkörper","Corps entier","Corpo inteiro","Całe ciało","Corpo intero")
    static let upper     = LocStr("Верх","Upper","Верх","Superior","Oberkörper","Haut du corps","Superior","Góra","Parte alta")
    static let lower     = LocStr("Низ","Lower","Низ","Inferior","Unterkörper","Bas du corps","Inferior","Dół","Parte bassa")
    static let push      = LocStr("Поштовх (груди/плечі/трицепс)","Push (chest/shoulders/triceps)","Жим (грудь/плечи/трицепс)","Empuje","Drücken","Poussée","Empurrar","Push","Spinta")
    static let pull      = LocStr("Тяга (спина/біцепс)","Pull (back/biceps)","Тяга (спина/бицепс)","Tirón","Ziehen","Tirage","Puxar","Pull","Trazione")
    static let legs      = LocStr("Ноги","Legs","Ноги","Piernas","Beine","Jambes","Pernas","Nogi","Gambe")
    static let chestDay  = LocStr("Груди","Chest","Грудь","Pecho","Brust","Pectoraux","Peito","Klatka","Petto")
    static let backDay   = LocStr("Спина","Back","Спина","Espalda","Rücken","Dos","Costas","Plecy","Schiena")
    static let shoulderDay = LocStr("Плечі","Shoulders","Плечи","Hombros","Schultern","Épaules","Ombros","Barki","Spalle")
    static let armsDay   = LocStr("Руки","Arms","Руки","Brazos","Arme","Bras","Braços","Ramiona","Braccia")
    static let glutesDay = LocStr("Сідниці / ноги","Glutes / Legs","Ягодицы / ноги","Glúteos / piernas","Gesäß / Beine","Fessiers / jambes","Glúteos / pernas","Pośladki / nogi","Glutei / gambe")
    static let lowerHard = LocStr("Низ (важко)","Lower (hard)","Низ (тяжело)","Inferior (fuerte)","Unterkörper (hart)","Bas (intense)","Inferior (forte)","Dół (mocno)","Parte bassa (dura)")
    static let upperLight = LocStr("Верх (легко, тонус)","Upper (light/tone)","Верх (легко, тонус)","Superior (ligero)","Oberkörper (leicht)","Haut (léger)","Superior (leve)","Góra (lekko)","Parte alta (leggera)")
    static let dayA      = LocStr("День A","Day A","День A","Día A","Tag A","Jour A","Dia A","Dzień A","Giorno A")
    static let dayB      = LocStr("День B","Day B","День B","Día B","Tag B","Jour B","Dia B","Dzień B","Giorno B")
    static let day1      = LocStr("День 1","Day 1","День 1","Día 1","Tag 1","Jour 1","Dia 1","Dzień 1","Giorno 1")
    static let day2      = LocStr("День 2","Day 2","День 2","Día 2","Tag 2","Jour 2","Dia 2","Dzień 2","Giorno 2")
    static let day3      = LocStr("День 3","Day 3","День 3","Día 3","Tag 3","Jour 3","Dia 3","Dzień 3","Giorno 3")
    static let cardioDay = LocStr("Кардіо / HIIT","Cardio / HIIT","Кардио / HIIT","Cardio / HIIT","Cardio / HIIT","Cardio / HIIT","Cardio / HIIT","Cardio / HIIT","Cardio / HIIT")
    static let conditioning = LocStr("Кондиція (меткон)","Conditioning (metcon)","Кондиция (меткон)","Acondicionamiento","Konditionierung","Conditionnement","Condicionamento","Kondycja","Condizionamento")
    static let core      = LocStr("Кор","Core","Кор","Core","Core","Core","Core","Core","Core")
    static let finisher  = LocStr("Фінішер","Finisher","Финишер","Finisher","Finisher","Finisher","Finisher","Finisher","Finisher")
    static let warmup    = LocStr("Розминка","Warm-up","Разминка","Calentamiento","Aufwärmen","Échauffement","Aquecimento","Rozgrzewka","Riscaldamento")
    static let snatchDay = LocStr("Ривок","Snatch","Рывок","Arrancada","Reißen","Arraché","Arranco","Rwanie","Strappo")
    static let cjDay     = LocStr("Поштовх (підйом на груди + поштовх)","Clean & Jerk","Толчок","Cargada y envión","Stoßen","Épaulé-jeté","Arremesso","Podrzut","Slancio")

    // Власні вправи, яких нема в бібліотеці
    static let birdDog   = LocStr("Bird-dog (собака-птах)","Bird-dog","Bird-dog","Bird-dog","Bird-Dog","Bird-dog","Bird-dog","Bird-dog","Bird-dog")
    static let curlUp    = LocStr("Curl-up (за Макґіллом)","McGill Curl-up","Скручивание по Макгиллу","Curl-up de McGill","McGill Curl-up","Curl-up McGill","Curl-up McGill","McGill Curl-up","Curl-up McGill")
    static let powerClean = LocStr("Взяття на груди (power clean)","Power Clean","Взятие на грудь","Cargada de potencia","Umsetzen","Épaulé debout","Clean de potência","Zarzut na klatkę","Girata in piedi")
    static let pushPress = LocStr("Швунг жимовий (push press)","Push Press","Швунг жимовой","Push press","Push Press","Push press","Push press","Push press","Spinta in spinta")
    static let overheadSquat = LocStr("Присід зі штангою над головою","Overhead Squat","Присед со штангой над головой","Sentadilla sobre cabeza","Überkopfkniebeuge","Squat overhead","Agachamento overhead","Przysiad nad głową","Squat sopra la testa")
    static let snatchPull = LocStr("Ривкова тяга","Snatch Pull","Рывковая тяга","Tirón de arrancada","Reißzug","Tirage arraché","Puxada de arranco","Ciąg rwaniowy","Tirata strappo")
    static let cleanPull  = LocStr("Тяга поштовхова","Clean Pull","Толчковая тяга","Tirón de cargada","Umsetzzug","Tirage épaulé","Puxada de clean","Ciąg zarzutowy","Tirata girata")
    static let powerSnatch = LocStr("Ривок у стійку (power snatch)","Power Snatch","Рывок в стойку","Arrancada de potencia","Power Snatch","Arraché debout","Arranco de potência","Rwanie w stójkę","Strappo in piedi")
}

// =====================================================================
// MARK: - UI: Каталог
// =====================================================================

struct ProgramCatalogView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                Section {
                    genderRow(.men,   icon: "figure.strengthtraining.traditional",
                              title: LocStr("Чоловіки","Men","Мужчины","Hombres","Männer","Hommes","Homens","Mężczyźni","Uomini"))
                    genderRow(.women, icon: "figure.cooldown",
                              title: LocStr("Жінки","Women","Женщины","Mujeres","Frauen","Femmes","Mulheres","Kobiety","Donne"))
                }
                Section {
                    NavigationLink {
                        ProgramListView(gender: .any, category: .backsafe)
                    } label: {
                        Label(ProgramCategory.backsafe.title.s(lang), systemImage: "bandage")
                            .foregroundStyle(theme.textPrimary)
                    }
                } footer: {
                    Text(LocStr(
                        "Для тих, хто має проблеми зі спиною. Перед початком — консультація лікаря/фізіотерапевта.",
                        "For people with back issues. Consult a doctor/physiotherapist before starting.",
                        "Для тех, у кого проблемы со спиной. Перед началом — консультация врача/физиотерапевта.",
                        "Para personas con problemas de espalda. Consulta a un médico antes de empezar.",
                        "Für Personen mit Rückenproblemen. Vorher Arzt/Physiotherapeut konsultieren.",
                        "Pour les personnes ayant des problèmes de dos. Consultez un médecin avant de commencer.",
                        "Para quem tem problemas nas costas. Consulte um médico antes de começar.",
                        "Dla osób z problemami z plecami. Przed startem skonsultuj się z lekarzem.",
                        "Per chi ha problemi alla schiena. Consulta un medico prima di iniziare."
                    ).s(lang))
                    .font(.caption2)
                    .foregroundStyle(theme.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(LocStr("Готові програми","Built-in Programs","Готовые программы","Programas listos",
                                 "Fertige Programme","Programmes prêts","Programas prontos","Gotowe programy","Programmi pronti").s(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func genderRow(_ g: ProgramGender, icon: String, title: LocStr) -> some View {
        NavigationLink {
            GenderCategoriesView(gender: g, genderTitle: title)
        } label: {
            Label(title.s(lang), systemImage: icon).foregroundStyle(theme.textPrimary)
        }
    }
}

struct GenderCategoriesView: View {
    let gender: ProgramGender
    let genderTitle: LocStr
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                ForEach(BuiltInPrograms.categories(for: gender), id: \.self) { cat in
                    NavigationLink {
                        ProgramListView(gender: gender, category: cat)
                    } label: {
                        HStack {
                            Text(cat.title.s(lang)).foregroundStyle(theme.textPrimary)
                            Spacer()
                            Text("\(BuiltInPrograms.programs(gender: gender, category: cat).count)")
                                .font(.caption).foregroundStyle(theme.textSecondary)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(genderTitle.s(lang))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgramListView: View {
    let gender: ProgramGender
    let category: ProgramCategory
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @State private var dayFilter: Int = 0   // 0 = всі
    private var lang: AppLanguage? { appState.data.settings.language }

    private var programs: [BuiltInProgram] {
        let base = BuiltInPrograms.programs(gender: gender, category: category)
        return dayFilter == 0 ? base : base.filter { $0.days == dayFilter }
    }
    private var availableDays: [Int] {
        Array(Set(BuiltInPrograms.programs(gender: gender, category: category).map { $0.days })).sorted()
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                if availableDays.count > 1 {
                    Section {
                        Picker(LocStr("Днів на тиждень","Days / week","Дней в неделю","Días / semana","Tage / Woche",
                                      "Jours / semaine","Dias / semana","Dni / tydzień","Giorni / settimana").s(lang),
                               selection: $dayFilter) {
                            Text(LocStr("Усі","All","Все","Todos","Alle","Tous","Todos","Wszystkie","Tutti").s(lang)).tag(0)
                            ForEach(availableDays, id: \.self) { d in Text("\(d)").tag(d) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                Section {
                    ForEach(programs) { p in
                        NavigationLink {
                            ProgramDetailView(program: p)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(p.name.s(lang)).font(.subheadline).fontWeight(.semibold)
                                    .foregroundStyle(theme.textPrimary)
                                Text("\(p.days) \(daysWord) · \(p.level.title.s(lang))")
                                    .font(.caption2).foregroundStyle(theme.accent)
                                Text(p.desc.s(lang)).font(.caption2)
                                    .foregroundStyle(theme.textSecondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(category.title.s(lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var daysWord: String {
        LocStr("дн/тиж","d/wk","дн/нед","d/sem","T/Wo","j/sem","d/sem","dni/tydz","g/sett").s(lang)
    }
}

// =====================================================================
// MARK: - UI: Деталі програми + застосування
// =====================================================================

struct ProgramDetailView: View {
    let program: BuiltInProgram
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    @State private var showApply = false
    @State private var showApplied = false

    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(program.desc.s(lang))
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)

                    ForEach(Array(program.schedule.enumerated()), id: \.offset) { _, day in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(day.title.s(lang))
                                .font(.headline)
                                .foregroundStyle(theme.accent)
                            ForEach(Array(day.items.enumerated()), id: \.offset) { _, item in
                                itemRow(item)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Color.clear.frame(height: 80)
                }
                .padding(16)
            }

            VStack {
                Spacer()
                Button {
                    showApply = true
                } label: {
                    Text(applyLabel)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
            }
        }
        .navigationTitle(program.name.s(lang))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showApply) {
            ProgramApplySheet(program: program) {
                showApplied = true
            }
            .environmentObject(appState)
            .environment(\.strings, s)
            .environment(\.appTheme, theme)
        }
        .alert(appliedText, isPresented: $showApplied) {
            Button(s.done, role: .cancel) { }
        }
    }

    @ViewBuilder
    private func itemRow(_ item: ProgItem) -> some View {
        switch item.kind {
        case .block:
            Text(item.blockTitle?.s(lang).uppercased() ?? "")
                .font(.caption).fontWeight(.bold)
                .foregroundStyle(theme.textSecondary)
                .padding(.top, 4)
        case .exercise, .cardio:
            HStack(alignment: .top) {
                Text("•").foregroundStyle(theme.textSecondary)
                Text(item.resolvedName(lang))
                    .font(.subheadline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text(item.kind == .cardio ? "\(item.minutes) \(s.min) · \(item.scheme)" : item.scheme)
                    .font(.caption).foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var applyLabel: String {
        LocStr("Застосувати програму","Apply program","Применить программу","Aplicar programa","Programm anwenden",
               "Appliquer le programme","Aplicar programa","Zastosuj program","Applica programma").s(lang)
    }
    private var appliedText: String {
        LocStr("Програму додано ✓","Program added ✓","Программа добавлена ✓","Programa añadido ✓","Programm hinzugefügt ✓",
               "Programme ajouté ✓","Programa adicionado ✓","Program dodany ✓","Programma aggiunto ✓").s(lang)
    }
}

struct ProgramApplySheet: View {
    let program: BuiltInProgram
    let onDone: () -> Void

    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @Environment(\.dismiss) var dismiss

    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                List {
                    Section {
                        Button {
                            applyToNewWeek(); finish()
                        } label: {
                            Label(newWeekLabel, systemImage: "plus")
                                .foregroundStyle(theme.accent)
                        }
                    } footer: {
                        Text(LocStr(
                            "Рекомендовано: програма додається окремим тижнем. Повтори проставлені, вагу впишеш сам — наступного разу вона підкаже минулі значення.",
                            "Recommended: the program is added as a new week. Reps are pre-filled; you enter the weight — next time it suggests your last values.",
                            "Рекомендуется: программа добавляется отдельной неделей. Повторы проставлены, вес впишешь сам — в следующий раз он подскажет прошлые значения.",
                            "Recomendado: el programa se añade como semana nueva. Las reps están puestas; tú pones el peso.",
                            "Empfohlen: das Programm wird als neue Woche hinzugefügt. Wiederholungen sind vorgegeben; das Gewicht trägst du ein.",
                            "Recommandé : le programme est ajouté comme nouvelle semaine. Les répétitions sont préremplies ; vous saisissez le poids.",
                            "Recomendado: o programa é adicionado como nova semana. As repetições já vêm preenchidas; você insere o peso.",
                            "Zalecane: program dodawany jako nowy tydzień. Powtórzenia są wpisane; ciężar wpisujesz sam.",
                            "Consigliato: il programma viene aggiunto come nuova settimana. Le ripetizioni sono preimpostate; inserisci il peso."
                        ).s(lang)).font(.caption2).foregroundStyle(theme.textSecondary)
                    }
                    if !appState.data.weeks.isEmpty {
                        Section(existingWeekTitle) {
                            ForEach(appState.data.weeks) { week in
                                Button {
                                    applyProgram(program, to: week); finish()
                                } label: {
                                    HStack {
                                        Text(weekLabel(week)).foregroundStyle(theme.textPrimary)
                                        Spacer()
                                        Text("\(week.workouts.count)").foregroundStyle(theme.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(program.name.s(lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button(s.cancel) { dismiss() } }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func finish() { dismiss(); onDone() }

    private func weekLabel(_ week: Week) -> String {
        week.customName.isEmpty ? "\(s.week) \(week.number)" : week.customName
    }

    // MARK: Логіка застосування

    private func applyToNewWeek(_ p: BuiltInProgram? = nil) {
        let prog = p ?? program
        appState.addWeek()
        guard let week = appState.data.weeks.last else { return }
        // дамо тижню назву програми
        appState.updateWeekName(week, to: prog.name.s(lang))
        if let fresh = appState.data.weeks.last {
            applyProgram(prog, to: fresh)
        }
    }

    private func applyProgram(_ p: BuiltInProgram, to week: Week) {
        for day in p.schedule {
            appState.addWorkout(to: week)
            guard let wk = appState.currentWeek(id: week.id),
                  let wo = wk.workouts.last else { continue }
            appState.updateWorkoutName(wo, in: wk, to: day.title.s(lang))

            var noteLines: [String] = []
            for item in day.items {
                switch item.kind {
                case .exercise:
                    let name = item.resolvedName(lang)
                    var ex = Exercise(name: name, muscleGroup: item.resolvedMuscle())
                    let setCount = min(max(1, item.sets), AppState.maxSetsPerExercise)
                    ex.sets = (0..<setCount).map { _ in ExerciseSet(weight: 0, reps: max(0, item.reps)) }
                    appState.addExercise(ex, toWorkoutId: wo.id, inWeekId: wk.id)
                    noteLines.append("• \(name): \(item.scheme)")
                case .block:
                    let title = item.blockTitle?.s(lang) ?? ""
                    appState.addBlock(ExerciseBlock(name: title), toWorkoutId: wo.id, inWeekId: wk.id)
                    if !title.isEmpty { noteLines.append("— \(title) —") }
                case .cardio:
                    let name = item.resolvedName(lang)
                    appState.addCardio(Cardio(name: name, minutes: item.minutes),
                                       position: .after, workoutId: wo.id, weekId: wk.id)
                    noteLines.append("• \(name): \(item.minutes) \(s.min) · \(item.scheme)")
                }
            }
            let tip = p.tip.s(lang)
            if !tip.isEmpty { noteLines.append(""); noteLines.append(tip) }
            appState.updateWorkoutNotes(weekId: wk.id, workoutId: wo.id,
                                        notes: noteLines.joined(separator: "\n"))
        }
        appState.saveNow()
    }

    private var newWeekLabel: String {
        LocStr("Додати новим тижнем","Add as a new week","Добавить новой неделей","Añadir como semana nueva",
               "Als neue Woche hinzufügen","Ajouter comme nouvelle semaine","Adicionar como nova semana",
               "Dodaj jako nowy tydzień","Aggiungi come nuova settimana").s(lang)
    }
    private var existingWeekTitle: String {
        LocStr("Або в наявний тиждень","Or into an existing week","Или в существующую неделю","O en una semana existente",
               "Oder in eine bestehende Woche","Ou dans une semaine existante","Ou em uma semana existente",
               "Lub do istniejącego tygodnia","O in una settimana esistente").s(lang)
    }
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Новачок
// =====================================================================

extension BuiltInPrograms {
    static let menBeginner: [BuiltInProgram] = [
        BuiltInProgram(
            id: "sl5x5",
            name: .same("StrongLifts 5×5"),
            desc: LocStr(
                "Найпростіший старт: усе тіло 3 рази/тиждень, 5 базових вправ по 5×5, щотренування додаєш вагу. Для тих, хто щойно прийшов у зал.",
                "The simplest start: full body 3×/week, 5 basic lifts of 5×5, add weight every session. For complete beginners.",
                "Самый простой старт: всё тело 3 раза/нед, 5 базовых по 5×5, каждую тренировку добавляешь вес. Для новичков.",
                "El inicio más simple: cuerpo completo 3×/sem, 5 básicos de 5×5, sumas peso cada sesión. Para principiantes.",
                "Der einfachste Start: Ganzkörper 3×/Woche, 5 Grundübungen 5×5, jede Einheit mehr Gewicht. Für Anfänger.",
                "Le départ le plus simple : corps entier 3×/sem, 5 exercices de base en 5×5, ajout de poids à chaque séance.",
                "O começo mais simples: corpo inteiro 3×/sem, 5 básicos de 5×5, adiciona peso a cada treino.",
                "Najprostszy start: całe ciało 3×/tydz, 5 podstawowych po 5×5, co trening dokładasz ciężar.",
                "L'inizio più semplice: corpo intero 3×/sett, 5 esercizi base 5×5, aggiungi peso ogni volta."),
            tip: LocStr("Додавай 2.5 кг щотренування, поки виходить 5×5. Застопорився — скинь вагу на 10%.",
                        "Add 2.5 kg each session while you hit 5×5. Stall — drop 10% and rebuild.",
                        "Добавляй 2.5 кг каждую тренировку, пока получается 5×5. Застопорился — скинь 10%.",
                        "Suma 2.5 kg por sesión mientras logres 5×5. Si te estancas, baja 10%.",
                        "Pro Einheit 2.5 kg mehr, solange 5×5 klappt. Stillstand — 10% reduzieren.",
                        "Ajoute 2.5 kg par séance tant que tu réussis 5×5. Blocage — baisse de 10%.",
                        "Some 2.5 kg por treino enquanto fizer 5×5. Travou — reduza 10%.",
                        "Dokładaj 2.5 kg co trening, póki robisz 5×5. Zastój — zrzuć 10%.",
                        "Aggiungi 2.5 kg ogni volta finché fai 5×5. Stallo — togli 10%."),
            gender: .men, category: .beginner, level: .beginner, days: 3,
            schedule: [
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 5, 5, "5×5"),
                    .ex("bench_press_barbell", 5, 5, "5×5"),
                    .ex("bent_over_row_barbell", 5, 5, "5×5"),
                ]),
                ProgramDay(title: PL.dayB, items: [
                    .ex("squat_back", 5, 5, "5×5"),
                    .ex("overhead_press_barbell", 5, 5, "5×5"),
                    .ex("deadlift", 1, 5, "1×5"),
                ]),
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 5, 5, "5×5"),
                    .ex("bench_press_barbell", 5, 5, "5×5"),
                    .ex("bent_over_row_barbell", 5, 5, "5×5"),
                ]),
            ]),
        BuiltInProgram(
            id: "starting_strength",
            name: .same("Starting Strength"),
            desc: LocStr(
                "Класика сили для новачка: 3 рази/тиждень, акцент на присіді, жимі та становій, мінімум зайвого.",
                "A classic beginner strength plan: 3×/week focused on squat, press and deadlift, nothing extra.",
                "Классика силы для новичка: 3 раза/нед, акцент на приседе, жиме и становой.",
                "Fuerza clásica para principiantes: 3×/sem en sentadilla, press y peso muerto.",
                "Klassisches Kraft-Einsteigerprogramm: 3×/Woche Kniebeuge, Drücken, Kreuzheben.",
                "Force classique débutant : 3×/sem axé squat, développé et soulevé de terre.",
                "Força clássica para iniciante: 3×/sem em agachamento, supino e levantamento terra.",
                "Klasyka siły dla początkujących: 3×/tydz przysiad, wyciskanie, martwy ciąg.",
                "Forza classica per principianti: 3×/sett su squat, distensioni e stacco."),
            gender: .men, category: .beginner, level: .beginner, days: 3,
            schedule: [
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 3, 5, "3×5"),
                    .ex("bench_press_barbell", 3, 5, "3×5"),
                    .ex("deadlift", 1, 5, "1×5"),
                ]),
                ProgramDay(title: PL.dayB, items: [
                    .ex("squat_back", 3, 5, "3×5"),
                    .ex("overhead_press_barbell", 3, 5, "3×5"),
                    .custom(PL.powerClean, .back, 5, 3, "5×3"),
                ]),
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 3, 5, "3×5"),
                    .ex("bench_press_barbell", 3, 5, "3×5"),
                    .ex("deadlift", 1, 5, "1×5"),
                ]),
            ]),
        BuiltInProgram(
            id: "full_body_beginner",
            name: LocStr("Повне тіло (новачок)","Full Body (Beginner)","Всё тело (новичок)","Cuerpo completo (principiante)",
                         "Ganzkörper (Anfänger)","Corps entier (débutant)","Corpo inteiro (iniciante)","Całe ciało (początkujący)","Corpo intero (principiante)"),
            desc: LocStr(
                "М'якший старт із більшою кількістю повторів і тренажерами: усе тіло 3 рази/тиждень, легше вчити техніку.",
                "A gentler start with higher reps and machines: full body 3×/week, easier to learn form.",
                "Более мягкий старт с большим числом повторов и тренажёрами: всё тело 3 раза/нед.",
                "Inicio más suave con más reps y máquinas: cuerpo completo 3×/sem.",
                "Sanfterer Start mit mehr Wiederholungen und Maschinen: Ganzkörper 3×/Woche.",
                "Départ plus doux avec plus de reps et machines : corps entier 3×/sem.",
                "Começo mais suave com mais repetições e máquinas: corpo inteiro 3×/sem.",
                "Łagodniejszy start z większą liczbą powtórzeń i maszynami: całe ciało 3×/tydz.",
                "Avvio più morbido con più ripetizioni e macchine: corpo intero 3×/sett."),
            gender: .men, category: .beginner, level: .beginner, days: 3,
            schedule: [
                ProgramDay(title: PL.fullBody, items: [
                    .ex("squat_back", 3, 8, "3×8"),
                    .ex("bench_press_barbell", 3, 8, "3×8"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("overhead_press_dumbbell", 3, 10, "3×10"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("plank", 3, 0, "30–60 с"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("leg_press", 3, 10, "3×10"),
                    .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("machine_chest_press", 3, 10, "3×10"),
                    .ex("lat_pulldown_close", 3, 10, "3×10"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("calf_raise_standing", 3, 15, "3×15"),
                    .ex("hammer_curl", 3, 12, "3×12"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Бодібілдинг
// =====================================================================

extension BuiltInPrograms {
    static let menBodybuilding: [BuiltInProgram] = [
        BuiltInProgram(
            id: "fb2",
            name: LocStr("Повне тіло (2 дні)","Full Body (2 days)","Всё тело (2 дня)","Cuerpo completo (2 días)",
                         "Ganzkörper (2 Tage)","Corps entier (2 jours)","Corpo inteiro (2 dias)","Całe ciało (2 dni)","Corpo intero (2 giorni)"),
            desc: LocStr(
                "Для дуже зайнятих: усе тіло двічі на тиждень, два різні тренування. Мінімум часу — стабільний прогрес.",
                "For the very busy: full body twice a week, two different sessions. Minimum time, steady progress.",
                "Для очень занятых: всё тело дважды в неделю, две разные тренировки.",
                "Para muy ocupados: cuerpo completo 2×/sem, dos sesiones distintas.",
                "Für sehr Beschäftigte: Ganzkörper 2×/Woche, zwei verschiedene Einheiten.",
                "Pour les très occupés : corps entier 2×/sem, deux séances différentes.",
                "Para muito ocupados: corpo inteiro 2×/sem, dois treinos diferentes.",
                "Dla bardzo zajętych: całe ciało 2×/tydz, dwa różne treningi.",
                "Per i molto impegnati: corpo intero 2×/sett, due sedute diverse."),
            gender: .men, category: .bodybuilding, level: .beginner, days: 2,
            schedule: [
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 3, 8, "3×8"),
                    .ex("bench_press_barbell", 3, 8, "3×8"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("plank", 3, 0, "30–60 с"),
                ]),
                ProgramDay(title: PL.dayB, items: [
                    .ex("deadlift", 3, 5, "3×5"),
                    .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "fb3_hyp",
            name: LocStr("Повне тіло (гіпертрофія, 3 дні)","Full Body (Hypertrophy, 3 days)","Всё тело (гипертрофия, 3 дня)","Cuerpo completo (hipertrofia, 3 días)",
                         "Ganzkörper (Hypertrophie, 3 Tage)","Corps entier (hypertrophie, 3 jours)","Corpo inteiro (hipertrofia, 3 dias)","Całe ciało (hipertrofia, 3 dni)","Corpo intero (ipertrofia, 3 giorni)"),
            desc: LocStr(
                "Часта стимуляція кожної групи 3 рази/тиждень — найкраще для маси при 3 днях. Підходить початківцям і середньому рівню.",
                "Each muscle 3×/week — great for mass on a 3-day schedule. Suits beginners and intermediates.",
                "Частая стимуляция каждой группы 3 раза/нед — отлично для массы на 3 днях.",
                "Cada músculo 3×/sem — ideal para masa con 3 días. Principiantes e intermedios.",
                "Jeder Muskel 3×/Woche — top für Masse bei 3 Tagen. Anfänger und Mittelstufe.",
                "Chaque muscle 3×/sem — idéal pour la masse sur 3 jours. Débutants et intermédiaires.",
                "Cada músculo 3×/sem — ótimo para massa em 3 dias. Iniciantes e intermediários.",
                "Każdy mięsień 3×/tydz — świetne na masę przy 3 dniach. Początkujący i średni.",
                "Ogni muscolo 3×/sett — ottimo per la massa su 3 giorni. Principianti e intermedi."),
            gender: .men, category: .bodybuilding, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.fullBody, items: [
                    .ex("squat_back", 3, 8, "3×8"),
                    .ex("bench_press_barbell", 3, 8, "3×8"),
                    .ex("bent_over_row_barbell", 3, 10, "3×10"),
                    .ex("overhead_press_dumbbell", 3, 10, "3×10"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("hammer_curl", 3, 12, "3×12"),
                    .ex("tricep_overhead_rope", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("deadlift", 3, 5, "3×5"),
                    .ex("machine_chest_press", 3, 10, "3×10"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                    .ex("cable_curl_straight", 3, 12, "3×12"),
                    .ex("tricep_pushdown_straight", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "upper_lower_4",
            name: LocStr("Верх / Низ (4 дні)","Upper / Lower (4 days)","Верх / Низ (4 дня)","Superior / Inferior (4 días)",
                         "Ober / Unter (4 Tage)","Haut / Bas (4 jours)","Superior / Inferior (4 dias)","Góra / Dół (4 dni)","Sopra / Sotto (4 giorni)"),
            desc: LocStr(
                "Золотий баланс об'єму й відновлення: верх і низ двічі на тиждень. Найкращий вибір для середнього рівня.",
                "The golden balance of volume and recovery: upper and lower twice a week. Best pick for intermediates.",
                "Золотой баланс объёма и восстановления: верх и низ дважды в неделю.",
                "Equilibrio ideal de volumen y recuperación: superior e inferior 2×/sem.",
                "Goldene Balance aus Volumen und Erholung: Ober- und Unterkörper 2×/Woche.",
                "L'équilibre idéal volume/récupération : haut et bas 2×/sem.",
                "Equilíbrio ideal de volume e recuperação: superior e inferior 2×/sem.",
                "Złoty balans objętości i regeneracji: góra i dół 2×/tydz.",
                "Equilibrio ideale tra volume e recupero: sopra e sotto 2×/sett."),
            gender: .men, category: .bodybuilding, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.upper, items: [
                    .ex("bench_press_barbell", 4, 8, "4×8"),
                    .ex("bent_over_row_barbell", 4, 8, "4×8"),
                    .ex("seated_dumbbell_press", 3, 10, "3×10"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("squat_back", 4, 8, "4×8"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                    .ex("leg_raise_hanging", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("incline_bench_press_dumbbell", 4, 10, "4×10"),
                    .ex("seated_row_v", 4, 10, "4×10"),
                    .ex("machine_shoulder_press", 3, 10, "3×10"),
                    .ex("pull_up_overhand", 3, 8, "3×8"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("hammer_curl", 3, 12, "3×12"),
                    .ex("skull_crusher_ez", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("deadlift", 4, 5, "4×5"),
                    .ex("squat_front", 3, 8, "3×8"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("calf_raise_seated", 4, 15, "4×15"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                ]),
            ]),
        BuiltInProgram(
            id: "ppl3",
            name: .same("Push / Pull / Legs (3)"),
            desc: LocStr(
                "Мінімалістичний спліт: поштовх, тяга, ноги — кожна група раз на тиждень. Простий і зрозумілий.",
                "Minimalist split: push, pull, legs — each group once a week. Simple and clear.",
                "Минималистичный сплит: жим, тяга, ноги — каждая группа раз в неделю.",
                "Split minimalista: empuje, tirón, piernas — cada grupo 1×/sem.",
                "Minimalistischer Split: Drücken, Ziehen, Beine — jede Gruppe 1×/Woche.",
                "Split minimaliste : poussée, tirage, jambes — chaque groupe 1×/sem.",
                "Split minimalista: empurrar, puxar, pernas — cada grupo 1×/sem.",
                "Minimalistyczny split: push, pull, nogi — każda grupa 1×/tydz.",
                "Split minimalista: spinta, trazione, gambe — ogni gruppo 1×/sett."),
            gender: .men, category: .bodybuilding, level: .beginner, days: 3,
            schedule: [ppPush, ppPull, ppLegs]),
        BuiltInProgram(
            id: "ppl6",
            name: .same("Push / Pull / Legs (6)"),
            desc: LocStr(
                "Два кола поштовх/тяга/ноги: кожна група двічі на тиждень, дуже багато об'єму. Для досвідчених, хто може 6 днів.",
                "Two rounds of push/pull/legs: each group twice a week, lots of volume. For experienced lifters training 6 days.",
                "Два круга жим/тяга/ноги: каждая группа дважды в неделю, много объёма. Для опытных.",
                "Dos rondas de empuje/tirón/piernas: cada grupo 2×/sem, mucho volumen. Para avanzados.",
                "Zwei Runden Push/Pull/Legs: jede Gruppe 2×/Woche, viel Volumen. Für Fortgeschrittene.",
                "Deux tours push/pull/legs : chaque groupe 2×/sem, gros volume. Pour confirmés.",
                "Duas voltas de push/pull/legs: cada grupo 2×/sem, muito volume. Para avançados.",
                "Dwa obroty push/pull/nogi: każda grupa 2×/tydz, dużo objętości. Dla zaawansowanych.",
                "Due giri push/pull/gambe: ogni gruppo 2×/sett, tanto volume. Per esperti."),
            gender: .men, category: .bodybuilding, level: .advanced, days: 6,
            schedule: [ppPush, ppPull, ppLegs, ppPush, ppPull, ppLegs]),
        BuiltInProgram(
            id: "pplul5",
            name: .same("PPLUL (5)"),
            desc: LocStr(
                "Гібрид Push/Pull/Legs + Верх/Низ: усе тіло двічі на тиждень за 5 днів. Сильний варіант для середнього+ рівня.",
                "Hybrid Push/Pull/Legs + Upper/Lower: whole body twice a week over 5 days. Strong pick for intermediate+.",
                "Гибрид Push/Pull/Legs + Верх/Низ: всё тело дважды в неделю за 5 дней.",
                "Híbrido Push/Pull/Legs + Superior/Inferior: todo el cuerpo 2×/sem en 5 días.",
                "Hybrid Push/Pull/Legs + Ober/Unter: ganzer Körper 2×/Woche in 5 Tagen.",
                "Hybride Push/Pull/Legs + Haut/Bas : tout le corps 2×/sem sur 5 jours.",
                "Híbrido Push/Pull/Legs + Superior/Inferior: corpo todo 2×/sem em 5 dias.",
                "Hybryda Push/Pull/Nogi + Góra/Dół: całe ciało 2×/tydz w 5 dni.",
                "Ibrido Push/Pull/Gambe + Sopra/Sotto: tutto il corpo 2×/sett in 5 giorni."),
            gender: .men, category: .bodybuilding, level: .intermediate, days: 5,
            schedule: [
                ppPush, ppPull, ppLegs,
                ProgramDay(title: PL.upper, items: [
                    .ex("bench_press_barbell", 4, 6, "4×6"),
                    .ex("bent_over_row_barbell", 4, 6, "4×6"),
                    .ex("overhead_press_barbell", 3, 8, "3×8"),
                    .ex("pull_up_overhand", 3, 8, "3×8"),
                    .ex("barbell_curl", 3, 10, "3×10"),
                    .ex("close_grip_bench_press", 3, 10, "3×10"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("squat_back", 4, 6, "4×6"),
                    .ex("deadlift", 3, 5, "3×5"),
                    .ex("leg_press", 3, 10, "3×10"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                ]),
            ]),
        BuiltInProgram(
            id: "bro5",
            name: LocStr("Спліт по групах (Bro split)","Body-part split (Bro split)","Сплит по группам (Bro split)","Split por grupos (Bro split)",
                         "Körperteil-Split (Bro split)","Split par groupes (Bro split)","Split por grupos (Bro split)","Split na grupy (Bro split)","Split per gruppi (Bro split)"),
            desc: LocStr(
                "Класика бодібілдингу: одна група м'язів на день, максимальна концентрація й об'єм. Кожна група раз на тиждень.",
                "Bodybuilding classic: one muscle group per day, max focus and volume. Each group once a week.",
                "Классика бодибилдинга: одна группа в день, максимум концентрации и объёма.",
                "Clásico del culturismo: un grupo por día, máximo enfoque y volumen.",
                "Bodybuilding-Klassiker: eine Muskelgruppe pro Tag, maximaler Fokus und Volumen.",
                "Classique du bodybuilding : un groupe par jour, focus et volume maximum.",
                "Clássico da musculação: um grupo por dia, máximo foco e volume.",
                "Klasyka kulturystyki: jedna grupa dziennie, maksymalny fokus i objętość.",
                "Classico del bodybuilding: un gruppo al giorno, massimo focus e volume."),
            gender: .men, category: .bodybuilding, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: PL.chestDay, items: [
                    .ex("bench_press_barbell", 4, 8, "4×8"),
                    .ex("incline_bench_press_dumbbell", 4, 10, "4×10"),
                    .ex("pec_deck", 3, 12, "3×12"),
                    .ex("cable_crossover_mid", 3, 15, "3×15"),
                    .ex("dips_chest", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.backDay, items: [
                    .ex("deadlift", 3, 5, "3×5"),
                    .ex("pull_up_overhand", 4, 8, "4×8"),
                    .ex("bent_over_row_barbell", 4, 8, "4×8"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("straight_arm_pulldown", 3, 15, "3×15"),
                    .ex("shrugs_dumbbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.shoulderDay, items: [
                    .ex("overhead_press_barbell", 4, 8, "4×8"),
                    .ex("seated_dumbbell_press", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 4, 15, "4×15"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("upright_row_barbell", 3, 12, "3×12"),
                    .ex("face_pull", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.legs, items: [
                    .ex("squat_back", 4, 8, "4×8"),
                    .ex("leg_press", 4, 12, "4×12"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("calf_raise_standing", 4, 20, "4×20"),
                ]),
                ProgramDay(title: PL.armsDay, items: [
                    .ex("barbell_curl", 4, 10, "4×10"),
                    .ex("skull_crusher_ez", 4, 10, "4×10"),
                    .ex("hammer_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                    .ex("preacher_curl", 3, 12, "3×12"),
                    .ex("tricep_overhead_rope", 3, 12, "3×12"),
                ]),
            ]),
    ]

    // Спільні дні Push/Pull/Legs для повторного використання
    static let ppPush = ProgramDay(title: PL.push, items: [
        .ex("bench_press_barbell", 4, 8, "4×8"),
        .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
        .ex("overhead_press_barbell", 3, 8, "3×8"),
        .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
        .ex("tricep_pushdown_rope", 3, 12, "3×12"),
        .ex("tricep_overhead_rope", 3, 12, "3×12"),
    ])
    static let ppPull = ProgramDay(title: PL.pull, items: [
        .ex("pull_up_overhand", 4, 8, "4×8"),
        .ex("bent_over_row_barbell", 4, 8, "4×8"),
        .ex("seated_row_v", 3, 10, "3×10"),
        .ex("face_pull", 3, 15, "3×15"),
        .ex("barbell_curl", 3, 10, "3×10"),
        .ex("hammer_curl", 3, 12, "3×12"),
    ])
    static let ppLegs = ProgramDay(title: PL.legs, items: [
        .ex("squat_back", 4, 8, "4×8"),
        .ex("leg_press", 3, 12, "3×12"),
        .ex("romanian_deadlift", 3, 10, "3×10"),
        .ex("leg_extension", 3, 15, "3×15"),
        .ex("leg_curl_seated", 3, 12, "3×12"),
        .ex("calf_raise_standing", 4, 15, "4×15"),
    ])
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Пауерліфтинг
// =====================================================================

extension BuiltInPrograms {
    static let menPowerlifting: [BuiltInProgram] = [
        BuiltInProgram(
            id: "texas_method",
            name: .same("Texas Method"),
            desc: LocStr(
                "Для виходу з новачкового рівня: день об'єму, легкий день і день нового рекорду на 5 повторів. Прогрес — раз на тиждень.",
                "To move past the novice stage: a volume day, a light day, and a new 5-rep PR day. Weekly progress.",
                "Для выхода с новичкового уровня: день объёма, лёгкий день и день нового рекорда на 5 повторов.",
                "Para superar la etapa novata: día de volumen, día ligero y día de nuevo PR a 5 reps.",
                "Um die Anfängerphase zu verlassen: Volumentag, leichter Tag und neuer 5er-PR-Tag.",
                "Pour sortir du stade débutant : jour de volume, jour léger et jour de nouveau PR à 5 reps.",
                "Para sair do nível iniciante: dia de volume, dia leve e dia de novo PR de 5 reps.",
                "By wyjść z poziomu nowicjusza: dzień objętości, lekki dzień i dzień nowego PR na 5 powt.",
                "Per superare la fase da principiante: giorno di volume, giorno leggero e giorno di nuovo PR a 5 rip."),
            tip: LocStr("День 1 — важкий об'єм. День 2 — легко (~80% від дня 1). День 3 — новий 5ПМ.",
                        "Day 1 — heavy volume. Day 2 — light (~80% of day 1). Day 3 — a new 5RM.",
                        "День 1 — тяжёлый объём. День 2 — легко (~80%). День 3 — новый 5ПМ.",
                        "Día 1 — volumen pesado. Día 2 — ligero (~80%). Día 3 — nuevo 5RM.",
                        "Tag 1 — schweres Volumen. Tag 2 — leicht (~80%). Tag 3 — neues 5RM.",
                        "Jour 1 — volume lourd. Jour 2 — léger (~80%). Jour 3 — nouveau 5RM.",
                        "Dia 1 — volume pesado. Dia 2 — leve (~80%). Dia 3 — novo 5RM.",
                        "Dzień 1 — ciężka objętość. Dzień 2 — lekko (~80%). Dzień 3 — nowy 5RM.",
                        "Giorno 1 — volume pesante. Giorno 2 — leggero (~80%). Giorno 3 — nuovo 5RM."),
            gender: .men, category: .powerlifting, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.day1, items: [
                    .ex("squat_back", 5, 5, "5×5 (об'єм)"),
                    .ex("bench_press_barbell", 5, 5, "5×5 (об'єм)"),
                    .ex("bent_over_row_barbell", 3, 8, "3×8"),
                ]),
                ProgramDay(title: PL.day2, items: [
                    .ex("squat_back", 2, 5, "2×5 (легко ~80%)"),
                    .ex("overhead_press_barbell", 3, 5, "3×5"),
                    .ex("lat_pulldown_close", 3, 8, "3×8"),
                    .ex("hyperextension", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.day3, items: [
                    .ex("squat_back", 1, 5, "1×5 (новий PR)"),
                    .ex("bench_press_barbell", 1, 5, "1×5 (новий PR)"),
                    .ex("deadlift", 1, 5, "1×5"),
                ]),
            ]),
        BuiltInProgram(
            id: "madcow_5x5",
            name: .same("Madcow 5×5"),
            desc: LocStr(
                "Наступник StrongLifts: ступінчасте навантаження 5×5 із щотижневою прогресією. Для середнього рівня.",
                "The StrongLifts successor: ramping 5×5 with weekly progression. For intermediates.",
                "Наследник StrongLifts: ступенчатая нагрузка 5×5 с недельной прогрессией.",
                "Sucesor de StrongLifts: 5×5 en rampa con progresión semanal.",
                "Nachfolger von StrongLifts: ansteigende 5×5 mit wöchentlicher Progression.",
                "Successeur de StrongLifts : 5×5 en rampe avec progression hebdomadaire.",
                "Sucessor do StrongLifts: 5×5 em rampa com progressão semanal.",
                "Następca StrongLifts: narastające 5×5 z progresją tygodniową.",
                "Successore di StrongLifts: 5×5 a rampa con progressione settimanale."),
            tip: LocStr("Перші 4 підходи — розминкові сходинки, 5-й — робочий. Додавай вагу щотижня.",
                        "First 4 sets ramp up, the 5th is the work set. Add weight weekly.",
                        "Первые 4 подхода — разминочные ступени, 5-й — рабочий. Прибавляй вес еженедельно.",
                        "Las 4 primeras series suben, la 5ª es la de trabajo. Sube peso cada semana.",
                        "Die ersten 4 Sätze steigern sich, der 5. ist der Arbeitssatz. Wöchentlich steigern.",
                        "Les 4 premières séries montent, la 5e est la série de travail. Ajoute du poids chaque semaine.",
                        "As 4 primeiras séries sobem, a 5ª é a de trabalho. Aumente o peso semanalmente.",
                        "Pierwsze 4 serie narastają, 5. jest robocza. Dokładaj ciężar co tydzień.",
                        "Le prime 4 serie salgono, la 5ª è quella di lavoro. Aumenta il peso ogni settimana."),
            gender: .men, category: .powerlifting, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.day1, items: [
                    .ex("squat_back", 5, 5, "5×5 (рамп)"),
                    .ex("bench_press_barbell", 5, 5, "5×5 (рамп)"),
                    .ex("bent_over_row_barbell", 5, 5, "5×5 (рамп)"),
                ]),
                ProgramDay(title: PL.day2, items: [
                    .ex("squat_back", 4, 5, "4×5 (легко)"),
                    .ex("overhead_press_barbell", 4, 5, "4×5"),
                    .ex("deadlift", 4, 5, "4×5"),
                ]),
                ProgramDay(title: PL.day3, items: [
                    .ex("squat_back", 4, 5, "рамп + PR-сет"),
                    .ex("bench_press_barbell", 4, 5, "рамп + PR-сет"),
                    .ex("bent_over_row_barbell", 4, 5, "4×5"),
                ]),
            ]),
        BuiltInProgram(
            id: "wendler_531",
            name: .same("5/3/1"),
            desc: LocStr(
                "Періодизація від тренувального максимуму: хвилі 5/3/1 на 4 базові рухи + підсобка. Надійний прогрес місяцями.",
                "Periodization from a training max: 5/3/1 waves on the 4 main lifts + accessories. Reliable months-long progress.",
                "Периодизация от тренировочного максимума: волны 5/3/1 на 4 базовых движения + подсобка.",
                "Periodización desde un máximo de entrenamiento: olas 5/3/1 en los 4 básicos + accesorios.",
                "Periodisierung vom Trainingsmax: 5/3/1-Wellen auf 4 Hauptübungen + Zusatz.",
                "Périodisation depuis un max d'entraînement : vagues 5/3/1 sur 4 mouvements + accessoires.",
                "Periodização a partir de um máximo de treino: ondas 5/3/1 nos 4 básicos + acessórios.",
                "Periodyzacja od maksa treningowego: fale 5/3/1 na 4 ruchach + akcesoria.",
                "Periodizzazione dal massimale d'allenamento: onde 5/3/1 sui 4 fondamentali + accessori."),
            tip: LocStr("Рахуй від тренувального максимуму (90% від 1ПМ). Тиждень 1: 65/75/85%×5/5/5+; тижд.2: 70/80/90%×3/3/3+; тижд.3: 75/85/95%×5/3/1+; тижд.4 — розвантаження.",
                        "Use a training max (90% of 1RM). Wk1: 65/75/85%×5/5/5+; Wk2: 70/80/90%×3/3/3+; Wk3: 75/85/95%×5/3/1+; Wk4 deload.",
                        "Считай от тренировочного максимума (90% от 1ПМ). Нед.1: 65/75/85%×5/5/5+; нед.2: 70/80/90%×3; нед.3: 75/85/95%×5/3/1+; нед.4 — разгрузка.",
                        "Usa un máximo de entrenamiento (90% del 1RM). Sem1: 65/75/85%; Sem2: 70/80/90%; Sem3: 75/85/95%; Sem4 descarga.",
                        "Trainingsmax nutzen (90% des 1RM). Wo1: 65/75/85%; Wo2: 70/80/90%; Wo3: 75/85/95%; Wo4 Deload.",
                        "Utilise un max d'entraînement (90% du 1RM). Sem1: 65/75/85%; Sem2: 70/80/90%; Sem3: 75/85/95%; Sem4 décharge.",
                        "Use um máximo de treino (90% do 1RM). Sem1: 65/75/85%; Sem2: 70/80/90%; Sem3: 75/85/95%; Sem4 descarga.",
                        "Użyj maksa treningowego (90% 1RM). Tydz1: 65/75/85%; Tydz2: 70/80/90%; Tydz3: 75/85/95%; Tydz4 deload.",
                        "Usa un massimale d'allenamento (90% del 1RM). Sett1: 65/75/85%; Sett2: 70/80/90%; Sett3: 75/85/95%; Sett4 scarico."),
            gender: .men, category: .powerlifting, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.shoulderDay, items: [
                    .ex("overhead_press_barbell", 3, 5, "5/3/1 (хвиля %)"),
                    .ex("incline_bench_press_dumbbell", 5, 10, "5×10"),
                    .ex("lat_pulldown_wide", 5, 10, "5×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.backDay, items: [
                    .ex("deadlift", 3, 5, "5/3/1 (хвиля %)"),
                    .ex("romanian_deadlift", 5, 10, "5×10"),
                    .ex("leg_curl_lying", 4, 12, "4×12"),
                    .ex("leg_raise_hanging", 4, 12, "4×12"),
                ]),
                ProgramDay(title: PL.chestDay, items: [
                    .ex("bench_press_barbell", 3, 5, "5/3/1 (хвиля %)"),
                    .ex("close_grip_bench_press", 5, 10, "5×10"),
                    .ex("seated_row_v", 5, 10, "5×10"),
                    .ex("tricep_pushdown_rope", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.legs, items: [
                    .ex("squat_back", 3, 5, "5/3/1 (хвиля %)"),
                    .ex("leg_press", 5, 10, "5×10"),
                    .ex("leg_extension", 4, 15, "4×15"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                ]),
            ]),
        BuiltInProgram(
            id: "nsuns_531",
            name: .same("nSuns 5/3/1 LP"),
            desc: LocStr(
                "Високооб'ємна версія 5/3/1 з 8–9 підходами головного руху й щотижневою прогресією. Для просунутих новачків і середніх.",
                "A high-volume 5/3/1 with 8–9 sets of the main lift and weekly progression. For advanced novices and intermediates.",
                "Высокообъёмная версия 5/3/1 с 8–9 подходами главного движения и недельной прогрессией.",
                "Versión de alto volumen de 5/3/1 con 8–9 series del básico y progresión semanal.",
                "Hochvolumige 5/3/1 mit 8–9 Sätzen der Hauptübung und wöchentlicher Progression.",
                "Version à fort volume de 5/3/1 avec 8–9 séries du mouvement principal et progression hebdomadaire.",
                "Versão de alto volume do 5/3/1 com 8–9 séries do básico e progressão semanal.",
                "Wysokoobjętościowa wersja 5/3/1 z 8–9 seriami głównego ruchu i progresją tygodniową.",
                "Versione ad alto volume del 5/3/1 con 8–9 serie del fondamentale e progressione settimanale."),
            tip: LocStr("Головний рух — 8–9 підходів за відсотками, один із них AMRAP. Сильний AMRAP — підвищуй тренувальний максимум.",
                        "Main lift — 8–9 percentage sets, one is an AMRAP. Strong AMRAP — raise your training max.",
                        "Главное движение — 8–9 подходов по процентам, один AMRAP. Сильный AMRAP — поднимай тренировочный максимум.",
                        "Básico — 8–9 series por porcentaje, una AMRAP. AMRAP fuerte — sube el máximo.",
                        "Hauptübung — 8–9 Prozent-Sätze, einer ist AMRAP. Starker AMRAP — Trainingsmax erhöhen.",
                        "Mouvement principal — 8–9 séries en %, une AMRAP. AMRAP fort — augmente le max.",
                        "Básico — 8–9 séries por porcentagem, uma AMRAP. AMRAP forte — suba o máximo.",
                        "Główny ruch — 8–9 serii procentowych, jedna AMRAP. Mocny AMRAP — podnieś maks.",
                        "Fondamentale — 8–9 serie a percentuale, una AMRAP. AMRAP forte — alza il massimale."),
            gender: .men, category: .powerlifting, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: LocStr("Жим + армійський","Bench + OHP","Жим + армейский","Banca + militar","Bank + Schulter","Développé + militaire","Supino + militar","Ławka + żołnierski","Panca + militare"), items: [
                    .ex("bench_press_barbell", 9, 5, "9 підходів (до AMRAP)"),
                    .ex("overhead_press_barbell", 8, 6, "8 підходів"),
                    .ex("tricep_pushdown_rope", 3, 15, "3×15"),
                ]),
                ProgramDay(title: LocStr("Присід + сумо","Squat + Sumo","Присед + сумо","Sentadilla + sumo","Kniebeuge + Sumo","Squat + sumo","Agachamento + sumô","Przysiad + sumo","Squat + sumo"), items: [
                    .ex("squat_back", 9, 5, "9 підходів (до AMRAP)"),
                    .ex("deadlift_sumo", 8, 5, "8 підходів"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Армійський + похила","OHP + Incline","Армейский + наклонный","Militar + inclinado","Schulter + Schräg","Militaire + incliné","Militar + inclinado","Żołnierski + skos","Militare + inclinata"), items: [
                    .ex("overhead_press_barbell", 9, 6, "9 підходів (до AMRAP)"),
                    .ex("incline_bench_press_barbell", 8, 8, "8 підходів"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: LocStr("Станова + фронт","Deadlift + Front","Становая + фронт","Peso muerto + frontal","Kreuzheben + Front","Soulevé + frontal","Terra + frontal","Martwy + frontowy","Stacco + frontale"), items: [
                    .ex("deadlift", 9, 5, "9 підходів (до AMRAP)"),
                    .ex("squat_front", 8, 5, "8 підходів"),
                    .ex("hyperextension", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Жим + вузький","Bench + Close-grip","Жим + узкий","Banca + cerrado","Bank + eng","Développé + serré","Supino + fechado","Ławka + wąski","Panca + stretta"), items: [
                    .ex("bench_press_barbell", 9, 6, "9 підходів (до AMRAP)"),
                    .ex("close_grip_bench_press", 8, 6, "8 підходів"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Павербілдинг
// =====================================================================

extension BuiltInPrograms {
    static let menPowerbuilding: [BuiltInProgram] = [
        BuiltInProgram(
            id: "phul",
            name: .same("PHUL"),
            desc: LocStr(
                "Сила + маса: 2 силові дні (верх/низ) у малих повторах і 2 дні гіпертрофії у великих. Чотири дні на тиждень.",
                "Strength + size: 2 power days (upper/lower) in low reps and 2 hypertrophy days in higher reps. Four days a week.",
                "Сила + масса: 2 силовых дня (верх/низ) и 2 дня гипертрофии. Четыре дня в неделю.",
                "Fuerza + tamaño: 2 días de fuerza (sup./inf.) y 2 de hipertrofia. Cuatro días/sem.",
                "Kraft + Masse: 2 Krafttage (oben/unten) und 2 Hypertrophietage. Vier Tage/Woche.",
                "Force + masse : 2 jours de force (haut/bas) et 2 d'hypertrophie. Quatre jours/sem.",
                "Força + tamanho: 2 dias de força (sup./inf.) e 2 de hipertrofia. Quatro dias/sem.",
                "Siła + masa: 2 dni siły (góra/dół) i 2 dni hipertrofii. Cztery dni/tydz.",
                "Forza + massa: 2 giorni di forza (sopra/sotto) e 2 di ipertrofia. Quattro giorni/sett."),
            gender: .men, category: .powerbuilding, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: LocStr("Верх (сила)","Upper (power)","Верх (сила)","Superior (fuerza)","Ober (Kraft)","Haut (force)","Superior (força)","Góra (siła)","Sopra (forza)"), items: [
                    .ex("bench_press_barbell", 4, 5, "4×3–5"),
                    .ex("bent_over_row_barbell", 4, 5, "4×3–5"),
                    .ex("overhead_press_barbell", 3, 6, "3×5–8"),
                    .ex("pull_up_overhand", 3, 6, "3×6–10"),
                    .ex("close_grip_bench_press", 3, 8, "3×8"),
                    .ex("barbell_curl", 3, 8, "3×8"),
                ]),
                ProgramDay(title: LocStr("Низ (сила)","Lower (power)","Низ (сила)","Inferior (fuerza)","Unter (Kraft)","Bas (force)","Inferior (força)","Dół (siła)","Sotto (forza)"), items: [
                    .ex("squat_back", 4, 5, "4×3–5"),
                    .ex("deadlift", 3, 5, "3×3–5"),
                    .ex("leg_press", 4, 12, "4×10–15"),
                    .ex("leg_curl_lying", 4, 8, "4×8"),
                    .ex("calf_raise_standing", 4, 12, "4×12"),
                ]),
                ProgramDay(title: LocStr("Верх (гіпертрофія)","Upper (hypertrophy)","Верх (гипертрофия)","Superior (hipertrofia)","Ober (Hypertrophie)","Haut (hypertrophie)","Superior (hipertrofia)","Góra (hipertrofia)","Sopra (ipertrofia)"), items: [
                    .ex("incline_bench_press_dumbbell", 4, 10, "4×8–12"),
                    .ex("seated_row_v", 4, 12, "4×10–12"),
                    .ex("machine_shoulder_press", 3, 12, "3×10–12"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Низ (гіпертрофія)","Lower (hypertrophy)","Низ (гипертрофия)","Inferior (hipertrofia)","Unter (Hypertrophie)","Bas (hypertrophie)","Inferior (hipertrofia)","Dół (hipertrofia)","Sotto (ipertrofia)"), items: [
                    .ex("squat_front", 4, 10, "4×8–12"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_extension", 4, 15, "4×15"),
                    .ex("leg_curl_seated", 4, 15, "4×15"),
                    .ex("calf_raise_seated", 4, 15, "4×15"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                ]),
            ]),
        BuiltInProgram(
            id: "phat",
            name: .same("PHAT"),
            desc: LocStr(
                "5 днів сили й гіпертрофії: 2 силові (верх/низ) + 3 дні «пампінгу» (спина/плечі, ноги, груди/руки). Багато роботи на масу.",
                "5 days of power and hypertrophy: 2 power (upper/lower) + 3 pump days (back/shoulders, legs, chest/arms). High mass volume.",
                "5 дней силы и гипертрофии: 2 силовых + 3 «памповых» дня. Много работы на массу.",
                "5 días de fuerza e hipertrofia: 2 de fuerza + 3 de bombeo. Mucho volumen para masa.",
                "5 Tage Kraft und Hypertrophie: 2 Krafttage + 3 Pump-Tage. Viel Masse-Volumen.",
                "5 jours de force et hypertrophie : 2 de force + 3 de pump. Gros volume de masse.",
                "5 dias de força e hipertrofia: 2 de força + 3 de pump. Muito volume para massa.",
                "5 dni siły i hipertrofii: 2 siłowe + 3 dni pompy. Dużo objętości na masę.",
                "5 giorni di forza e ipertrofia: 2 di forza + 3 di pump. Tanto volume per la massa."),
            gender: .men, category: .powerbuilding, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: LocStr("Верх (сила)","Upper (power)","Верх (сила)","Superior (fuerza)","Ober (Kraft)","Haut (force)","Superior (força)","Góra (siła)","Sopra (forza)"), items: [
                    .ex("bent_over_row_barbell", 4, 5, "3×3–5"),
                    .ex("pull_up_overhand", 3, 6, "3×6–10"),
                    .ex("bench_press_barbell", 4, 5, "3×3–5"),
                    .ex("seated_dumbbell_press", 3, 6, "3×6–10"),
                    .ex("close_grip_bench_press", 3, 8, "3×8"),
                    .ex("barbell_curl", 3, 8, "3×8"),
                ]),
                ProgramDay(title: LocStr("Низ (сила)","Lower (power)","Низ (сила)","Inferior (fuerza)","Unter (Kraft)","Bas (force)","Inferior (força)","Dół (siła)","Sotto (forza)"), items: [
                    .ex("squat_back", 4, 5, "3×3–5"),
                    .ex("deadlift", 3, 5, "3×3–5"),
                    .ex("leg_press", 4, 10, "4×10"),
                    .ex("leg_curl_lying", 4, 8, "4×8"),
                    .ex("calf_raise_standing", 4, 12, "4×12"),
                ]),
                ProgramDay(title: LocStr("Спина / плечі (памп)","Back / shoulders (pump)","Спина / плечи (памп)","Espalda / hombros","Rücken / Schultern","Dos / épaules","Costas / ombros","Plecy / barki","Schiena / spalle"), items: [
                    .ex("seated_row_v", 4, 12, "4×8–12"),
                    .ex("lat_pulldown_wide", 4, 12, "4×12"),
                    .ex("straight_arm_pulldown", 3, 15, "3×15"),
                    .ex("machine_shoulder_press", 4, 12, "4×12"),
                    .ex("lateral_raise_dumbbell", 4, 15, "4×15"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: LocStr("Ноги (памп)","Legs (pump)","Ноги (памп)","Piernas (bombeo)","Beine (Pump)","Jambes (pump)","Pernas (pump)","Nogi (pompa)","Gambe (pump)"), items: [
                    .ex("squat_front", 4, 12, "4×8–12"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_extension", 4, 15, "4×15"),
                    .ex("leg_curl_seated", 4, 15, "4×15"),
                    .ex("calf_raise_seated", 4, 15, "4×15"),
                ]),
                ProgramDay(title: LocStr("Груди / руки (памп)","Chest / arms (pump)","Грудь / руки (памп)","Pecho / brazos","Brust / Arme","Pecs / bras","Peito / braços","Klatka / ramiona","Petto / braccia"), items: [
                    .ex("incline_bench_press_dumbbell", 4, 12, "4×8–12"),
                    .ex("pec_deck", 4, 12, "4×12"),
                    .ex("cable_crossover_mid", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 4, 12, "4×12"),
                    .ex("tricep_pushdown_rope", 4, 12, "4×12"),
                    .ex("hammer_curl", 3, 15, "3×15"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Важка атлетика
// =====================================================================

extension BuiltInPrograms {
    static let menWeightlifting: [BuiltInProgram] = [
        BuiltInProgram(
            id: "oly3",
            name: LocStr("Важка атлетика (3 дні)","Weightlifting (3 days)","Тяжёлая атлетика (3 дня)","Halterofilia (3 días)",
                         "Gewichtheben (3 Tage)","Haltérophilie (3 jours)","Levantamento (3 dias)","Ciężary (3 dni)","Sollevamento (3 giorni)"),
            desc: LocStr(
                "Базовий вхід у ривок і поштовх: 3 рази/тиждень, два змагальні рухи + присіди. Потрібна попередня техніка або тренер.",
                "A basic entry to snatch and clean & jerk: 3×/week, the two lifts + squats. Needs prior technique or a coach.",
                "Базовый вход в рывок и толчок: 3 раза/нед, два движения + приседы. Нужна техника или тренер.",
                "Entrada básica a arrancada y envión: 3×/sem, dos levantamientos + sentadillas. Requiere técnica o entrenador.",
                "Einstieg in Reißen und Stoßen: 3×/Woche, beide Lifts + Kniebeugen. Technik oder Coach nötig.",
                "Initiation arraché et épaulé-jeté : 3×/sem, deux mouvements + squats. Technique ou coach requis.",
                "Entrada básica ao arranco e arremesso: 3×/sem, dois levantamentos + agachamentos. Requer técnica ou treinador.",
                "Podstawowe wejście w rwanie i podrzut: 3×/tydz, dwa boje + przysiady. Wymaga techniki lub trenera.",
                "Avvio a strappo e slancio: 3×/sett, due alzate + squat. Serve tecnica o un coach."),
            tip: LocStr("Олімпійські рухи роби з невеликою вагою на техніку, відпочинок між підходами 2–3 хв.",
                        "Do the Olympic lifts light, focus on technique, rest 2–3 min between sets.",
                        "Олимпийские движения делай с малым весом на технику, отдых 2–3 мин.",
                        "Haz los olímpicos ligeros, técnica primero, descanso 2–3 min.",
                        "Olympische Lifts leicht und sauber, Pause 2–3 Min.",
                        "Mouvements olympiques légers, technique d'abord, repos 2–3 min.",
                        "Faça os olímpicos leves, foco na técnica, descanso 2–3 min.",
                        "Boje olimpijskie lekko, technika najpierw, przerwa 2–3 min.",
                        "Esegui le alzate olimpiche leggere, tecnica prima, recupero 2–3 min."),
            gender: .men, category: .weightlifting, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.snatchDay, items: [
                    .custom(PL.snatchDay, .back, 5, 3, "5×3"),
                    .custom(PL.snatchPull, .back, 3, 3, "3×3"),
                    .ex("squat_front", 4, 4, "4×4"),
                ]),
                ProgramDay(title: PL.cjDay, items: [
                    .custom(PL.cjDay, .legs, 5, 2, "5×2"),
                    .custom(PL.pushPress, .shoulders, 4, 3, "4×3"),
                    .ex("squat_back", 4, 4, "4×4"),
                ]),
                ProgramDay(title: LocStr("Техніка + присід","Technique + squat","Техника + присед","Técnica + sentadilla","Technik + Kniebeuge","Technique + squat","Técnica + agachamento","Technika + przysiad","Tecnica + squat"), items: [
                    .custom(PL.powerSnatch, .back, 4, 2, "4×2"),
                    .custom(PL.powerClean, .legs, 4, 2, "4×2"),
                    .custom(PL.overheadSquat, .legs, 4, 3, "4×3"),
                    .ex("squat_back", 3, 5, "3×5"),
                ]),
            ]),
        BuiltInProgram(
            id: "oly4",
            name: LocStr("Важка атлетика (4 дні)","Weightlifting (4 days)","Тяжёлая атлетика (4 дня)","Halterofilia (4 días)",
                         "Gewichtheben (4 Tage)","Haltérophilie (4 jours)","Levantamento (4 dias)","Ciężary (4 dni)","Sollevamento (4 giorni)"),
            desc: LocStr(
                "Системний тиждень: окремі дні на ривок, поштовх, техніку та силу. Для тих, хто вже впевнено володіє рухами.",
                "A structured week: separate days for snatch, clean & jerk, technique and strength. For confident lifters.",
                "Системная неделя: отдельные дни на рывок, толчок, технику и силу. Для уверенных атлетов.",
                "Semana estructurada: días separados de arrancada, envión, técnica y fuerza. Para avanzados.",
                "Strukturierte Woche: getrennte Tage für Reißen, Stoßen, Technik und Kraft. Für Geübte.",
                "Semaine structurée : jours séparés arraché, épaulé-jeté, technique et force. Pour confirmés.",
                "Semana estruturada: dias separados de arranco, arremesso, técnica e força. Para avançados.",
                "Ustrukturyzowany tydzień: osobne dni na rwanie, podrzut, technikę i siłę. Dla pewnych.",
                "Settimana strutturata: giorni separati per strappo, slancio, tecnica e forza. Per esperti."),
            gender: .men, category: .weightlifting, level: .advanced, days: 4,
            schedule: [
                ProgramDay(title: PL.snatchDay, items: [
                    .custom(PL.snatchDay, .back, 6, 2, "6×2"),
                    .custom(PL.snatchPull, .back, 3, 3, "3×3"),
                    .ex("squat_back", 4, 4, "4×4"),
                ]),
                ProgramDay(title: PL.cjDay, items: [
                    .custom(PL.cjDay, .legs, 6, 2, "6×2"),
                    .custom(PL.cleanPull, .back, 3, 3, "3×3"),
                    .ex("squat_front", 4, 4, "4×4"),
                ]),
                ProgramDay(title: LocStr("Техніка","Technique","Техника","Técnica","Technik","Technique","Técnica","Technika","Tecnica"), items: [
                    .custom(PL.powerSnatch, .back, 5, 2, "5×2"),
                    .custom(PL.overheadSquat, .legs, 4, 3, "4×3"),
                    .ex("pull_up_overhand", 3, 8, "3×8"),
                ]),
                ProgramDay(title: LocStr("Сила","Strength","Сила","Fuerza","Kraft","Force","Força","Siła","Forza"), items: [
                    .custom(PL.powerClean, .legs, 5, 2, "5×2"),
                    .custom(PL.pushPress, .shoulders, 4, 3, "4×3"),
                    .ex("squat_back", 5, 3, "5×3"),
                ]),
            ]),
        BuiltInProgram(
            id: "oly5",
            name: LocStr("Важка атлетика (5 днів)","Weightlifting (5 days)","Тяжёлая атлетика (5 дней)","Halterofilia (5 días)",
                         "Gewichtheben (5 Tage)","Haltérophilie (5 jours)","Levantamento (5 dias)","Ciężary (5 dni)","Sollevamento (5 giorni)"),
            desc: LocStr(
                "Майже змагальний обсяг: ривок, поштовх, техніка, чиста сила й контрольний день. Для досвідчених атлетів.",
                "Near-competitive volume: snatch, clean & jerk, technique, pure strength and a test day. For experienced lifters.",
                "Почти соревновательный объём: рывок, толчок, техника, сила и контрольный день. Для опытных.",
                "Volumen casi competitivo: arrancada, envión, técnica, fuerza y día de control. Para experimentados.",
                "Fast wettkampfnahes Volumen: Reißen, Stoßen, Technik, Kraft und Testtag. Für Erfahrene.",
                "Volume quasi compétitif : arraché, épaulé-jeté, technique, force et jour test. Pour expérimentés.",
                "Volume quase competitivo: arranco, arremesso, técnica, força e dia de teste. Para experientes.",
                "Niemal startowa objętość: rwanie, podrzut, technika, siła i dzień kontrolny. Dla doświadczonych.",
                "Volume quasi da gara: strappo, slancio, tecnica, forza e giorno test. Per esperti."),
            gender: .men, category: .weightlifting, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: PL.snatchDay, items: [
                    .custom(PL.snatchDay, .back, 6, 2, "6×2"),
                    .custom(PL.snatchPull, .back, 4, 3, "4×3"),
                    .ex("squat_front", 5, 3, "5×3"),
                ]),
                ProgramDay(title: PL.cjDay, items: [
                    .custom(PL.cjDay, .legs, 6, 2, "6×2"),
                    .custom(PL.cleanPull, .back, 4, 3, "4×3"),
                    .ex("squat_back", 5, 3, "5×3"),
                ]),
                ProgramDay(title: LocStr("Техніка","Technique","Техника","Técnica","Technik","Technique","Técnica","Technika","Tecnica"), items: [
                    .custom(PL.powerSnatch, .back, 5, 2, "5×2"),
                    .custom(PL.powerClean, .legs, 5, 2, "5×2"),
                    .custom(PL.overheadSquat, .legs, 4, 3, "4×3"),
                ]),
                ProgramDay(title: LocStr("Сила","Strength","Сила","Fuerza","Kraft","Force","Força","Siła","Forza"), items: [
                    .ex("squat_back", 5, 3, "5×3"),
                    .custom(PL.pushPress, .shoulders, 5, 3, "5×3"),
                    .ex("deadlift", 3, 3, "3×3"),
                ]),
                ProgramDay(title: LocStr("Контроль","Test day","Контроль","Día de control","Testtag","Jour test","Dia de teste","Dzień kontrolny","Giorno test"), items: [
                    .custom(PL.snatchDay, .back, 5, 1, "5×1 (важко)"),
                    .custom(PL.cjDay, .legs, 5, 1, "5×1 (важко)"),
                    .ex("squat_front", 3, 3, "3×3"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Кросфіт
// =====================================================================

extension BuiltInPrograms {
    static let menCrossfit: [BuiltInProgram] = [
        BuiltInProgram(
            id: "crossfit3",
            name: LocStr("Кросфіт (3 дні)","CrossFit (3 days)","Кроссфит (3 дня)","CrossFit (3 días)",
                         "CrossFit (3 Tage)","CrossFit (3 jours)","CrossFit (3 dias)","CrossFit (3 dni)","CrossFit (3 giorni)"),
            desc: LocStr(
                "Сила + інтенсивна кондиція: базовий рух дня, потім короткий «меткон» на максимум роботи. Функціональна форма за 3 дні.",
                "Strength + intense conditioning: a main lift, then a short metcon for max work. Functional fitness in 3 days.",
                "Сила + интенсивная кондиция: базовое движение, затем короткий «меткон». Функционалка за 3 дня.",
                "Fuerza + acondicionamiento intenso: un básico y luego un metcon corto. En 3 días.",
                "Kraft + intensive Kondition: eine Hauptübung, dann ein kurzer Metcon. In 3 Tagen.",
                "Force + conditionnement intense : un mouvement principal puis un metcon court. En 3 jours.",
                "Força + condicionamento intenso: um básico e um metcon curto. Em 3 dias.",
                "Siła + intensywna kondycja: główny ruch, potem krótki metcon. W 3 dni.",
                "Forza + condizionamento intenso: un fondamentale, poi un breve metcon. In 3 giorni."),
            tip: LocStr("Меткон роби «на час» або максимум кіл за відведені хвилини. Техніка важливіша за швидкість.",
                        "Do the metcon 'for time' or max rounds in the set minutes. Form beats speed.",
                        "Меткон — «на время» или максимум кругов за минуты. Техника важнее скорости.",
                        "El metcon: 'por tiempo' o máximas rondas. La técnica vence a la velocidad.",
                        "Metcon 'auf Zeit' oder max. Runden. Technik vor Tempo.",
                        "Le metcon 'pour le temps' ou max de tours. La technique avant la vitesse.",
                        "Metcon 'por tempo' ou máximo de voltas. Técnica antes da velocidade.",
                        "Metcon 'na czas' lub maks rund. Technika ważniejsza od tempa.",
                        "Metcon 'a tempo' o massimo giri. La tecnica batte la velocità."),
            gender: .men, category: .crossfit, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.day1, items: [
                    .ex("squat_back", 5, 5, "5×5"),
                    .block(PL.conditioning),
                    .cardio("rowing", 12, "інтервали"),
                    .cardio("burpees", 8, "AMRAP"),
                ]),
                ProgramDay(title: PL.day2, items: [
                    .custom(PL.powerClean, .legs, 5, 3, "5×3"),
                    .ex("deadlift", 5, 3, "5×3"),
                    .block(PL.conditioning),
                    .cardio("assault_bike", 12, "інтервали"),
                    .cardio("jump_rope", 8, "подвійні"),
                ]),
                ProgramDay(title: PL.day3, items: [
                    .ex("overhead_press_barbell", 5, 5, "5×5"),
                    .ex("pull_up_overhand", 5, 8, "5×8"),
                    .block(PL.conditioning),
                    .cardio("rowing", 10, "на час"),
                    .cardio("mountain_climbers", 8, "AMRAP"),
                ]),
            ]),
        BuiltInProgram(
            id: "crossfit5",
            name: LocStr("Кросфіт (5 днів)","CrossFit (5 days)","Кроссфит (5 дней)","CrossFit (5 días)",
                         "CrossFit (5 Tage)","CrossFit (5 jours)","CrossFit (5 dias)","CrossFit (5 dni)","CrossFit (5 giorni)"),
            desc: LocStr(
                "Повний тиждень «коробки»: сила, олімпійські рухи, гімнастика й щоденні меткони. Для тих, хто живе кросфітом.",
                "A full 'box' week: strength, Olympic lifts, gymnastics and daily metcons. For those who live CrossFit.",
                "Полная неделя «бокса»: сила, олимпийские движения, гимнастика и ежедневные метконы.",
                "Semana completa de 'box': fuerza, olímpicos, gimnásticos y metcons diarios.",
                "Volle 'Box'-Woche: Kraft, olympische Lifts, Gymnastik und tägliche Metcons.",
                "Semaine 'box' complète : force, mouvements olympiques, gymnastique et metcons quotidiens.",
                "Semana completa de 'box': força, olímpicos, ginásticos e metcons diários.",
                "Pełny tydzień 'boxu': siła, boje olimpijskie, gimnastyka i codzienne metcony.",
                "Settimana 'box' completa: forza, olimpici, ginnastica e metcon quotidiani."),
            gender: .men, category: .crossfit, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: LocStr("Присід + меткон","Squat + metcon","Присед + меткон","Sentadilla + metcon","Kniebeuge + Metcon","Squat + metcon","Agachamento + metcon","Przysiad + metcon","Squat + metcon"), items: [
                    .ex("squat_back", 5, 3, "5×3"),
                    .block(PL.conditioning),
                    .cardio("assault_bike", 10, "інтервали"),
                    .cardio("burpees", 7, "AMRAP"),
                ]),
                ProgramDay(title: LocStr("Ривок + гімнастика","Snatch + gymnastics","Рывок + гимнастика","Arrancada + gimnásticos","Reißen + Gymnastik","Arraché + gymnastique","Arranco + ginástica","Rwanie + gimnastyka","Strappo + ginnastica"), items: [
                    .custom(PL.powerSnatch, .back, 6, 2, "6×2"),
                    .ex("pull_up_overhand", 5, 8, "5×8"),
                    .block(PL.conditioning),
                    .cardio("jump_rope", 10, "подвійні"),
                ]),
                ProgramDay(title: LocStr("Жим + кор","Press + core","Жим + кор","Press + core","Drücken + Core","Développé + core","Press + core","Wyciskanie + core","Distensioni + core"), items: [
                    .ex("overhead_press_barbell", 5, 5, "5×5"),
                    .ex("dips_tricep", 4, 10, "4×10"),
                    .ex("leg_raise_hanging", 4, 12, "4×12"),
                    .block(PL.conditioning),
                    .cardio("rowing", 12, "на час"),
                ]),
                ProgramDay(title: LocStr("Поштовх + меткон","C&J + metcon","Толчок + меткон","Envión + metcon","Stoßen + Metcon","Épaulé-jeté + metcon","Arremesso + metcon","Podrzut + metcon","Slancio + metcon"), items: [
                    .custom(PL.powerClean, .legs, 6, 2, "6×2"),
                    .custom(PL.pushPress, .shoulders, 4, 3, "4×3"),
                    .block(PL.conditioning),
                    .cardio("assault_bike", 12, "інтервали"),
                    .cardio("mountain_climbers", 8, "AMRAP"),
                ]),
                ProgramDay(title: LocStr("Станова + кондиція","Deadlift + conditioning","Становая + кондиция","Peso muerto + cond.","Kreuzheben + Kondition","Soulevé + cond.","Terra + cond.","Martwy + kondycja","Stacco + cond."), items: [
                    .ex("deadlift", 5, 3, "5×3"),
                    .ex("farmer_walk", 4, 0, "4×30 м"),
                    .block(PL.conditioning),
                    .cardio("rowing", 10, "інтервали"),
                    .cardio("burpees", 8, "AMRAP"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Чоловіки / Сушка
// =====================================================================

extension BuiltInPrograms {
    static let menCutting: [BuiltInProgram] = [
        BuiltInProgram(
            id: "cut_fb3",
            name: LocStr("Сушка: повне тіло (3 дні)","Cutting: Full Body (3 days)","Сушка: всё тело (3 дня)","Definición: cuerpo completo (3 días)",
                         "Definition: Ganzkörper (3 Tage)","Sèche : corps entier (3 jours)","Definição: corpo inteiro (3 dias)","Redukcja: całe ciało (3 dni)","Definizione: corpo intero (3 giorni)"),
            desc: LocStr(
                "Зберегти м'язи на дефіциті: важкі базові вправи + HIIT-фінішер для спалювання. Усе тіло 3 рази/тиждень.",
                "Keep muscle in a deficit: heavy compounds + a HIIT finisher to burn. Full body 3×/week.",
                "Сохранить мышцы на дефиците: тяжёлая база + HIIT-финишер. Всё тело 3 раза/нед.",
                "Conservar músculo en déficit: básicos pesados + finisher HIIT. Cuerpo completo 3×/sem.",
                "Muskeln im Defizit halten: schwere Grundübungen + HIIT-Finisher. Ganzkörper 3×/Woche.",
                "Garder le muscle en déficit : basiques lourds + finisher HIIT. Corps entier 3×/sem.",
                "Manter músculo no déficit: básicos pesados + finisher HIIT. Corpo inteiro 3×/sem.",
                "Utrzymać mięśnie na deficycie: ciężka baza + finisher HIIT. Całe ciało 3×/tydz.",
                "Mantieni i muscoli in deficit: fondamentali pesanti + finisher HIIT. Corpo intero 3×/sett."),
            tip: LocStr("Тримай ваги важкими — це зберігає м'язи. Дефіцит роблять їжею, а не вбивчими тренуваннями. HIIT — максимум 1–2 рази/тиждень.",
                        "Keep the weights heavy — that preserves muscle. The deficit comes from food, not killer workouts. HIIT — 1–2×/week max.",
                        "Держи веса тяжёлыми — это сохраняет мышцы. Дефицит делают едой. HIIT — максимум 1–2 раза/нед.",
                        "Mantén pesos altos — conserva músculo. El déficit es por dieta. HIIT — 1–2×/sem máx.",
                        "Halte die Gewichte schwer — das erhält Muskeln. Defizit über Ernährung. HIIT — max. 1–2×/Woche.",
                        "Garde des charges lourdes — ça préserve le muscle. Le déficit vient de l'alimentation. HIIT — 1–2×/sem max.",
                        "Mantenha cargas pesadas — preserva músculo. O déficit vem da dieta. HIIT — 1–2×/sem no máx.",
                        "Trzymaj ciężary wysokie — to chroni mięśnie. Deficyt robi dieta. HIIT — maks 1–2×/tydz.",
                        "Tieni i pesi alti — preserva i muscoli. Il deficit viene dalla dieta. HIIT — max 1–2×/sett."),
            gender: .men, category: .cutting, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.fullBody, items: [
                    .ex("squat_back", 3, 6, "3×6"),
                    .ex("bench_press_barbell", 3, 6, "3×6"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .cardio("hiit", 12, "8×(20с/40с)"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("deadlift", 3, 5, "3×5"),
                    .ex("overhead_press_barbell", 3, 8, "3×8"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .cardio("incline_walking", 25, "стале, низький пульс"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("squat_front", 3, 8, "3×8"),
                    .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
                    .ex("pull_up_overhand", 3, 8, "3×8"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                    .cardio("sprints", 10, "інтервали"),
                ]),
            ]),
        BuiltInProgram(
            id: "cut_ul4",
            name: LocStr("Сушка: верх/низ (4 дні)","Cutting: Upper/Lower (4 days)","Сушка: верх/низ (4 дня)","Definición: sup./inf. (4 días)",
                         "Definition: Ober/Unter (4 Tage)","Sèche : haut/bas (4 jours)","Definição: sup./inf. (4 dias)","Redukcja: góra/dół (4 dni)","Definizione: sopra/sotto (4 giorni)"),
            desc: LocStr(
                "Більше об'єму для збереження форми на дефіциті: верх/низ двічі + кардіо щодня. Оптимально, коли є 4 дні.",
                "More volume to hold shape in a deficit: upper/lower twice + daily cardio. Ideal with 4 days.",
                "Больше объёма для сохранения формы на дефиците: верх/низ дважды + кардио ежедневно.",
                "Más volumen para mantener forma en déficit: sup./inf. 2× + cardio diario.",
                "Mehr Volumen, um in Form zu bleiben: Ober/Unter 2× + tägliches Cardio.",
                "Plus de volume pour garder la forme : haut/bas 2× + cardio quotidien.",
                "Mais volume para manter a forma no déficit: sup./inf. 2× + cardio diário.",
                "Więcej objętości, by utrzymać formę: góra/dół 2× + cardio codziennie.",
                "Più volume per mantenere la forma: sopra/sotto 2× + cardio quotidiano."),
            tip: LocStr("Ваги тримай як на масі. Стале кардіо — спокійно, HIIT — рідко й коротко.",
                        "Keep the weights as in a bulk. Steady cardio easy, HIIT rare and short.",
                        "Веса держи как на массе. Стабильное кардио спокойно, HIIT редко и коротко.",
                        "Mantén los pesos como en volumen. Cardio suave, HIIT raro y corto.",
                        "Gewichte wie im Aufbau halten. Steady-Cardio locker, HIIT selten und kurz.",
                        "Garde les charges comme en prise de masse. Cardio doux, HIIT rare et court.",
                        "Mantenha as cargas como no bulking. Cardio leve, HIIT raro e curto.",
                        "Trzymaj ciężary jak na masie. Cardio spokojnie, HIIT rzadko i krótko.",
                        "Tieni i pesi come in massa. Cardio leggero, HIIT raro e breve."),
            gender: .men, category: .cutting, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.upper, items: [
                    .ex("bench_press_barbell", 4, 6, "4×6"),
                    .ex("bent_over_row_barbell", 4, 8, "4×8"),
                    .ex("seated_dumbbell_press", 3, 10, "3×10"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 3, 12, "3×12"),
                    .cardio("incline_walking", 20, "стале"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("squat_back", 4, 6, "4×6"),
                    .ex("romanian_deadlift", 3, 8, "3×8"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                    .cardio("hiit", 10, "інтервали"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("incline_bench_press_dumbbell", 4, 10, "4×10"),
                    .ex("seated_row_v", 4, 10, "4×10"),
                    .ex("machine_shoulder_press", 3, 10, "3×10"),
                    .ex("pull_up_overhand", 3, 8, "3×8"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                    .cardio("cycling", 25, "стале"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("deadlift", 4, 5, "4×5"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("leg_curl_seated", 3, 15, "3×15"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                    .cardio("sprints", 10, "інтервали"),
                ]),
            ]),
        BuiltInProgram(
            id: "cut_ppl5",
            name: LocStr("Сушка: PPL (5 днів)","Cutting: PPL (5 days)","Сушка: PPL (5 дней)","Definición: PPL (5 días)",
                         "Definition: PPL (5 Tage)","Sèche : PPL (5 jours)","Definição: PPL (5 dias)","Redukcja: PPL (5 dni)","Definizione: PPL (5 giorni)"),
            desc: LocStr(
                "Максимум контролю на сушці: спліт push/pull/legs + верх/низ і кардіо щодня. Для досвідчених при 5 днях.",
                "Maximum control while cutting: push/pull/legs + upper/lower with daily cardio. For experienced lifters with 5 days.",
                "Максимум контроля на сушке: push/pull/legs + верх/низ и кардио ежедневно.",
                "Máximo control en definición: push/pull/legs + sup./inf. con cardio diario.",
                "Maximale Kontrolle beim Definieren: push/pull/legs + Ober/Unter mit täglichem Cardio.",
                "Contrôle maximal en sèche : push/pull/legs + haut/bas avec cardio quotidien.",
                "Máximo controle na definição: push/pull/legs + sup./inf. com cardio diário.",
                "Maksymalna kontrola na redukcji: push/pull/nogi + góra/dół z cardio codziennie.",
                "Massimo controllo in definizione: push/pull/gambe + sopra/sotto con cardio quotidiano."),
            tip: LocStr("Не зрізай ваги — зрізай калорії. 1–2 HIIT/тиждень, решта — спокійна ходьба.",
                        "Don't cut the weights — cut calories. 1–2 HIIT/week, the rest is easy walking.",
                        "Не режь веса — режь калории. 1–2 HIIT/нед, остальное — спокойная ходьба.",
                        "No recortes pesos — recorta calorías. 1–2 HIIT/sem, el resto caminar.",
                        "Nicht die Gewichte kürzen — die Kalorien. 1–2 HIIT/Woche, sonst Gehen.",
                        "Ne coupe pas les charges — les calories. 1–2 HIIT/sem, sinon marche.",
                        "Não corte as cargas — corte calorias. 1–2 HIIT/sem, o resto caminhada.",
                        "Nie tnij ciężarów — tnij kalorie. 1–2 HIIT/tydz, reszta spacer.",
                        "Non tagliare i pesi — taglia le calorie. 1–2 HIIT/sett, il resto camminata."),
            gender: .men, category: .cutting, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: PL.push, items: [
                    .ex("bench_press_barbell", 4, 8, "4×8"),
                    .ex("overhead_press_barbell", 3, 8, "3×8"),
                    .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                    .cardio("hiit", 10, "інтервали"),
                ]),
                ProgramDay(title: PL.pull, items: [
                    .ex("pull_up_overhand", 4, 8, "4×8"),
                    .ex("bent_over_row_barbell", 4, 8, "4×8"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("face_pull", 3, 15, "3×15"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                    .cardio("incline_walking", 25, "стале"),
                ]),
                ProgramDay(title: PL.legs, items: [
                    .ex("squat_back", 4, 8, "4×8"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                    .cardio("cycling", 20, "стале"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("incline_bench_press_dumbbell", 4, 10, "4×10"),
                    .ex("lat_pulldown_wide", 4, 10, "4×10"),
                    .ex("seated_dumbbell_press", 3, 10, "3×10"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("hammer_curl", 3, 12, "3×12"),
                    .cardio("sprints", 10, "інтервали"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("deadlift", 4, 5, "4×5"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                    .ex("plank", 3, 0, "45–60 с"),
                    .cardio("incline_walking", 25, "стале"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Піковий цикл (оригінальна періодизація)
// =====================================================================

extension BuiltInPrograms {
    static let peakCycle: [BuiltInProgram] = [
        BuiltInProgram(
            id: "peak_basic3",
            name: LocStr("Піковий цикл: Початковий (3 дні)","Peak Cycle: Foundation (3 days)","Пиковый цикл: Начальный (3 дня)","Ciclo de pico: Base (3 días)",
                         "Peak-Zyklus: Basis (3 Tage)","Cycle de pic : Base (3 jours)","Ciclo de pico: Base (3 dias)","Cykl szczytowy: Bazowy (3 dni)","Ciclo di picco: Base (3 giorni)"),
            desc: LocStr(
                "Перший досвід періодизації: 3 базові рухи, вага росте хвилями — від легких об'ємних тижнів до важкої прохідки.",
                "A first taste of periodization: 3 main lifts, weight rises in waves — from lighter volume weeks to a heavy test.",
                "Первый опыт периодизации: 3 базовых движения, вес растёт волнами — от объёмных недель к тяжёлой проходке.",
                "Primera periodización: 3 básicos, el peso sube en olas — de semanas de volumen a una prueba pesada.",
                "Erste Periodisierung: 3 Hauptübungen, Gewicht steigt in Wellen — von Volumenwochen zum schweren Test.",
                "Première périodisation : 3 mouvements, le poids monte par vagues — du volume vers un test lourd.",
                "Primeira periodização: 3 básicos, o peso sobe em ondas — de semanas de volume a um teste pesado.",
                "Pierwsza periodyzacja: 3 ruchy, ciężar rośnie falami — od tygodni objętości do ciężkiego sprawdzianu.",
                "Prima periodizzazione: 3 fondamentali, il peso sale a onde — da settimane di volume a un test pesante."),
            tip: LocStr("Цикл на ~6–7 тижнів. Тижні 1–3: накопичення 70–80%, більше повторів. Тижні 4–6: інтенсивність 80–90%, менше повторів. Останній тиждень: розвантаження, потім прохідка на 1ПМ. Щотижня трохи додавай вагу.",
                        "A ~6–7 week cycle. Weeks 1–3: accumulation 70–80%, more reps. Weeks 4–6: intensity 80–90%, fewer reps. Last week: deload, then a 1RM test. Add a little weight each week.",
                        "Цикл ~6–7 недель. Недели 1–3: накопление 70–80%, больше повторов. Недели 4–6: интенсивность 80–90%. Последняя: разгрузка и проходка на 1ПМ.",
                        "Ciclo de ~6–7 semanas. Sem 1–3: acumulación 70–80%. Sem 4–6: intensidad 80–90%. Última: descarga y prueba de 1RM.",
                        "~6–7-Wochen-Zyklus. Wo 1–3: Akkumulation 70–80%. Wo 4–6: Intensität 80–90%. Letzte: Deload, dann 1RM-Test.",
                        "Cycle de ~6–7 semaines. Sem 1–3 : accumulation 70–80%. Sem 4–6 : intensité 80–90%. Dernière : décharge puis test 1RM.",
                        "Ciclo de ~6–7 semanas. Sem 1–3: acumulação 70–80%. Sem 4–6: intensidade 80–90%. Última: descarga e teste de 1RM.",
                        "Cykl ~6–7 tygodni. Tydz 1–3: akumulacja 70–80%. Tydz 4–6: intensywność 80–90%. Ostatni: deload i test 1RM.",
                        "Ciclo di ~6–7 settimane. Sett 1–3: accumulo 70–80%. Sett 4–6: intensità 80–90%. Ultima: scarico e test 1RM."),
            gender: .men, category: .peakcycle, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: LocStr("Присід","Squat day","Присед","Día de sentadilla","Kniebeuge-Tag","Jour squat","Dia de agachamento","Dzień przysiadu","Giorno squat"), items: [
                    .ex("squat_back", 5, 5, "5×5 → 5×3 (хвиля %)"),
                    .ex("leg_press", 3, 10, "3×10"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("plank", 3, 0, "45 с"),
                ]),
                ProgramDay(title: LocStr("Жим","Bench day","Жим","Día de press","Bank-Tag","Jour développé","Dia de supino","Dzień wyciskania","Giorno panca"), items: [
                    .ex("bench_press_barbell", 5, 5, "5×5 → 5×3 (хвиля %)"),
                    .ex("overhead_press_barbell", 3, 6, "3×6"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Станова","Deadlift day","Становая","Día de peso muerto","Kreuzheben-Tag","Jour soulevé","Dia de terra","Dzień martwego","Giorno stacco"), items: [
                    .ex("deadlift", 5, 3, "5×3 (хвиля %)"),
                    .ex("bent_over_row_barbell", 4, 6, "4×6"),
                    .ex("hyperextension", 3, 12, "3×12"),
                    .ex("barbell_curl", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "peak_pl4",
            name: LocStr("Піковий цикл: Троєборство (4 дні)","Peak Cycle: Powerlifting (4 days)","Пиковый цикл: Троеборье (4 дня)","Ciclo de pico: Powerlifting (4 días)",
                         "Peak-Zyklus: Kraftdreikampf (4 Tage)","Cycle de pic : Powerlifting (4 jours)","Ciclo de pico: Powerlifting (4 dias)","Cykl szczytowy: Trójbój (4 dni)","Ciclo di picco: Powerlifting (4 giorni)"),
            desc: LocStr(
                "Підведення до піку у присіді, жимі й становій: окремі важкі дні + швидкісний жим. Готує до прохідки чи змагань.",
                "Peaking the squat, bench and deadlift: dedicated heavy days + a speed-bench day. Preps you for a max or a meet.",
                "Подведение к пику в приседе, жиме и становой: отдельные тяжёлые дни + скоростной жим.",
                "Pico en sentadilla, press y peso muerto: días pesados + press de velocidad. Prepara para una marca o competición.",
                "Peaking für Kniebeuge, Bank und Kreuzheben: schwere Tage + Speed-Bank. Bereitet auf Maximum/Wettkampf vor.",
                "Pic en squat, développé et soulevé : jours lourds + développé en vitesse. Prépare un max ou une compétition.",
                "Pico em agachamento, supino e terra: dias pesados + supino de velocidade. Prepara para um máximo ou competição.",
                "Szczyt w przysiadzie, wyciskaniu i martwym: ciężkie dni + szybkie wyciskanie. Przygotowuje do maksa lub zawodów.",
                "Picco in squat, panca e stacco: giorni pesanti + panca veloce. Prepara a un massimale o a una gara."),
            tip: LocStr("Цикл ~7 тижнів: накопичення (75–82%), інтенсивність (85–92%), пік (1–3 повтори 90%+), розвантаження, прохідка. Швидкісний жим — 60–70%, вибухово.",
                        "~7-week cycle: accumulation (75–82%), intensity (85–92%), peak (1–3 reps at 90%+), deload, then test. Speed bench at 60–70%, explosive.",
                        "Цикл ~7 недель: накопление (75–82%), интенсивность (85–92%), пик (1–3 повтора 90%+), разгрузка, проходка. Скоростной жим 60–70%.",
                        "Ciclo ~7 semanas: acumulación (75–82%), intensidad (85–92%), pico (1–3 reps 90%+), descarga, prueba. Press de velocidad 60–70%.",
                        "~7-Wochen-Zyklus: Akkumulation (75–82%), Intensität (85–92%), Peak (1–3 Wdh 90%+), Deload, Test. Speed-Bank 60–70%.",
                        "Cycle ~7 sem : accumulation (75–82%), intensité (85–92%), pic (1–3 reps 90%+), décharge, test. Développé vitesse 60–70%.",
                        "Ciclo ~7 semanas: acumulação (75–82%), intensidade (85–92%), pico (1–3 reps 90%+), descarga, teste. Supino veloz 60–70%.",
                        "Cykl ~7 tyg: akumulacja (75–82%), intensywność (85–92%), szczyt (1–3 powt 90%+), deload, test. Szybkie wyciskanie 60–70%.",
                        "Ciclo ~7 sett: accumulo (75–82%), intensità (85–92%), picco (1–3 rip 90%+), scarico, test. Panca veloce 60–70%."),
            gender: .men, category: .peakcycle, level: .advanced, days: 4,
            schedule: [
                ProgramDay(title: LocStr("Присід (важко)","Squat (heavy)","Присед (тяжело)","Sentadilla (pesado)","Kniebeuge (schwer)","Squat (lourd)","Agachamento (pesado)","Przysiad (ciężko)","Squat (pesante)"), items: [
                    .ex("squat_back", 5, 4, "5×4 (хвиля %)"),
                    .ex("squat_front", 3, 5, "3×5"),
                    .ex("leg_curl_lying", 3, 10, "3×10"),
                    .ex("leg_raise_hanging", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Жим (важко)","Bench (heavy)","Жим (тяжело)","Press (pesado)","Bank (schwer)","Développé (lourd)","Supino (pesado)","Wyciskanie (ciężko)","Panca (pesante)"), items: [
                    .ex("bench_press_barbell", 5, 4, "5×4 (хвиля %)"),
                    .ex("close_grip_bench_press", 3, 6, "3×6"),
                    .ex("seated_row_v", 4, 8, "4×8"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: LocStr("Станова (важко)","Deadlift (heavy)","Становая (тяжело)","Peso muerto (pesado)","Kreuzheben (schwer)","Soulevé (lourd)","Terra (pesado)","Martwy (ciężko)","Stacco (pesante)"), items: [
                    .ex("deadlift", 5, 3, "5×3 (хвиля %)"),
                    .ex("romanian_deadlift", 3, 6, "3×6"),
                    .ex("bent_over_row_barbell", 4, 6, "4×6"),
                    .ex("hyperextension", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Жим швидкісний + підсобка","Speed bench + accessory","Скоростной жим + подсобка","Press de velocidad + accesorio","Speed-Bank + Zusatz","Développé vitesse + accessoire","Supino veloz + acessório","Szybkie wyciskanie + akcesoria","Panca veloce + accessori"), items: [
                    .ex("bench_press_barbell", 6, 3, "6×3 @60–70% (швидко)"),
                    .ex("overhead_press_barbell", 3, 8, "3×8"),
                    .ex("pull_up_overhand", 3, 8, "3×8"),
                    .ex("tricep_overhead_rope", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "peak_bench3",
            name: LocStr("Піковий цикл: Жим (3 дні)","Peak Cycle: Bench (3 days)","Пиковый цикл: Жим (3 дня)","Ciclo de pico: Press (3 días)",
                         "Peak-Zyklus: Bankdrücken (3 Tage)","Cycle de pic : Développé (3 jours)","Ciclo de pico: Supino (3 dias)","Cykl szczytowy: Wyciskanie (3 dni)","Ciclo di picco: Panca (3 giorni)"),
            desc: LocStr(
                "Спеціалізація на жимі лежачи: 3 дні жиму на тиждень — важкий, об'ємний і підсобний. Щоб пробити застій у жимі.",
                "Bench press specialization: 3 bench days a week — heavy, volume and support. To break a bench plateau.",
                "Специализация на жиме лёжа: 3 жимовых дня — тяжёлый, объёмный и подсобный. Чтобы пробить застой.",
                "Especialización en press banca: 3 días de press — pesado, volumen y apoyo. Para romper el estancamiento.",
                "Bankdrück-Spezialisierung: 3 Banktage — schwer, Volumen und Zusatz. Um ein Plateau zu durchbrechen.",
                "Spécialisation développé couché : 3 jours de développé — lourd, volume et soutien. Pour casser un plateau.",
                "Especialização em supino: 3 dias de supino — pesado, volume e apoio. Para quebrar a estagnação.",
                "Specjalizacja na wyciskaniu: 3 dni wyciskania — ciężki, objętościowy i wspomagający. By przebić zastój.",
                "Specializzazione panca: 3 giorni di panca — pesante, volume e supporto. Per superare lo stallo."),
            tip: LocStr("Важкий день — 80–90%, об'ємний — 65–75% на більше повторів, підсобний — трицепс, плечі, спина. Щотижня трохи додавай.",
                        "Heavy day 80–90%, volume day 65–75% for more reps, support day — triceps, shoulders, back. Add a little each week.",
                        "Тяжёлый день 80–90%, объёмный 65–75% на больше повторов, подсобный — трицепс, плечи, спина.",
                        "Día pesado 80–90%, volumen 65–75% a más reps, apoyo — tríceps, hombros, espalda.",
                        "Schwerer Tag 80–90%, Volumen 65–75% mehr Wdh, Zusatz — Trizeps, Schultern, Rücken.",
                        "Jour lourd 80–90%, volume 65–75% plus de reps, soutien — triceps, épaules, dos.",
                        "Dia pesado 80–90%, volume 65–75% mais reps, apoio — tríceps, ombros, costas.",
                        "Dzień ciężki 80–90%, objętość 65–75% więcej powt, wsparcie — triceps, barki, plecy.",
                        "Giorno pesante 80–90%, volume 65–75% più rip, supporto — tricipiti, spalle, schiena."),
            gender: .men, category: .peakcycle, level: .advanced, days: 3,
            schedule: [
                ProgramDay(title: LocStr("Жим важкий","Heavy bench","Жим тяжёлый","Press pesado","Bank schwer","Développé lourd","Supino pesado","Wyciskanie ciężkie","Panca pesante"), items: [
                    .ex("bench_press_barbell", 6, 4, "6×4 @80–90%"),
                    .ex("close_grip_bench_press", 3, 6, "3×6"),
                    .ex("tricep_pushdown_rope", 4, 10, "4×10"),
                ]),
                ProgramDay(title: LocStr("Жим об'ємний","Volume bench","Жим объёмный","Press volumen","Bank Volumen","Développé volume","Supino volume","Wyciskanie objętość","Panca volume"), items: [
                    .ex("bench_press_barbell", 5, 8, "5×8 @65–75%"),
                    .ex("incline_bench_press_dumbbell", 4, 10, "4×10"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("skull_crusher_ez", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Підсобка","Support","Подсобка","Apoyo","Zusatz","Soutien","Apoio","Wsparcie","Supporto"), items: [
                    .ex("overhead_press_barbell", 4, 6, "4×6"),
                    .ex("pull_up_overhand", 4, 8, "4×8"),
                    .ex("bent_over_row_barbell", 4, 8, "4×8"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Жінки / Новачок
// =====================================================================

extension BuiltInPrograms {
    static let womenBeginner: [BuiltInProgram] = [
        BuiltInProgram(
            id: "w_fb2",
            name: LocStr("Повне тіло (2 дні)","Full Body (2 days)","Всё тело (2 дня)","Cuerpo completo (2 días)",
                         "Ganzkörper (2 Tage)","Corps entier (2 jours)","Corpo inteiro (2 dias)","Całe ciało (2 dni)","Corpo intero (2 giorni)"),
            desc: LocStr(
                "М'який старт для зайнятих: усе тіло двічі на тиждень із акцентом на ноги й сідниці, верх — у легкому тонусі.",
                "A gentle start for busy women: full body twice a week with a legs-and-glutes focus, upper body kept light.",
                "Мягкий старт для занятых: всё тело дважды в неделю с акцентом на ноги и ягодицы, верх — в лёгком тонусе.",
                "Inicio suave para ocupadas: cuerpo completo 2×/sem con foco en piernas y glúteos, tren superior ligero.",
                "Sanfter Start für Beschäftigte: Ganzkörper 2×/Woche mit Bein-/Po-Fokus, Oberkörper leicht.",
                "Départ doux pour les occupées : corps entier 2×/sem axé jambes/fessiers, haut du corps léger.",
                "Início suave para ocupadas: corpo inteiro 2×/sem com foco em pernas e glúteos, superior leve.",
                "Łagodny start dla zajętych: całe ciało 2×/tydz z naciskiem na nogi i pośladki, góra lekko.",
                "Avvio dolce per le impegnate: corpo intero 2×/sett con focus su gambe e glutei, parte alta leggera."),
            gender: .women, category: .beginner, level: .beginner, days: 2,
            schedule: [
                ProgramDay(title: PL.dayA, items: [
                    .ex("goblet_squat", 3, 10, "3×10"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("plank", 3, 0, "30–45 с"),
                ]),
                ProgramDay(title: PL.dayB, items: [
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                    .ex("glute_bridge_barbell", 3, 15, "3×15"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_fb3",
            name: LocStr("Повне тіло (3 дні)","Full Body (3 days)","Всё тело (3 дня)","Cuerpo completo (3 días)",
                         "Ganzkörper (3 Tage)","Corps entier (3 jours)","Corpo inteiro (3 dias)","Całe ciało (3 dni)","Corpo intero (3 giorni)"),
            desc: LocStr(
                "Базова програма для початку: усе тіло 3 рази/тиждень, низ навантажуємо сильніше, верх — для тонусу й постави.",
                "A solid starter: full body 3×/week, the lower body worked harder, the upper for tone and posture.",
                "Базовая стартовая: всё тело 3 раза/нед, низ нагружаем сильнее, верх — для тонуса и осанки.",
                "Programa base para empezar: cuerpo completo 3×/sem, tren inferior más cargado, superior para tono y postura.",
                "Solide Einsteigerin: Ganzkörper 3×/Woche, Unterkörper stärker, Oberkörper für Tonus und Haltung.",
                "Bon programme de départ : corps entier 3×/sem, bas plus chargé, haut pour le tonus et la posture.",
                "Programa base para começar: corpo inteiro 3×/sem, inferior mais carregado, superior para tônus e postura.",
                "Solidny start: całe ciało 3×/tydz, dół mocniej, góra dla napięcia i postawy.",
                "Ottimo inizio: corpo intero 3×/sett, parte bassa più carica, parte alta per tono e postura."),
            gender: .women, category: .beginner, level: .beginner, days: 3,
            schedule: [
                ProgramDay(title: PL.day1, items: [
                    .ex("squat_back", 3, 10, "3×10"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("plank", 3, 0, "30–45 с"),
                ]),
                ProgramDay(title: PL.day2, items: [
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("abductor_machine", 3, 20, "3×20"),
                ]),
                ProgramDay(title: PL.day3, items: [
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("glute_bridge_barbell", 3, 15, "3×15"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Жінки / Сідниці-ноги
// =====================================================================

extension BuiltInPrograms {
    static let womenGlutes: [BuiltInProgram] = [
        BuiltInProgram(
            id: "w_lower2",
            name: LocStr("Низ-акцент (2 дні)","Lower focus (2 days)","Низ-акцент (2 дня)","Foco inferior (2 días)",
                         "Unterkörper-Fokus (2 Tage)","Focus bas (2 jours)","Foco inferior (2 dias)","Dół-akcent (2 dni)","Focus gambe (2 giorni)"),
            desc: LocStr(
                "Для дуже зайнятих, але хочеться сідниць: 2 потужні дні низу, трохи верху для балансу.",
                "For the very busy who still want glutes: 2 strong lower-body days, a little upper for balance.",
                "Для очень занятых, но хочется ягодиц: 2 мощных дня низа, немного верха для баланса.",
                "Para muy ocupadas que quieren glúteos: 2 días fuertes de inferior, algo de superior para equilibrio.",
                "Für sehr Beschäftigte mit Po-Ziel: 2 starke Unterkörpertage, etwas Oberkörper für Balance.",
                "Pour les très occupées qui veulent des fessiers : 2 jours bas intenses, un peu de haut pour l'équilibre.",
                "Para muito ocupadas que querem glúteos: 2 dias fortes de inferior, um pouco de superior.",
                "Dla bardzo zajętych chcących pośladków: 2 mocne dni dołu, trochę góry dla równowagi.",
                "Per le molto impegnate che vogliono glutei: 2 giorni intensi di gambe, un po' di parte alta."),
            gender: .women, category: .glutes, level: .beginner, days: 2,
            schedule: [
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("hip_thrust", 4, 10, "4×10"),
                    .ex("squat_back", 3, 10, "3×10"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("abductor_machine", 3, 20, "3×20"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("leg_press", 4, 12, "4×12"),
                    .ex("glute_bridge_barbell", 4, 12, "4×12"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_glute_fb3",
            name: LocStr("Сідниці: повне тіло (3 дні)","Glutes: Full Body (3 days)","Ягодицы: всё тело (3 дня)","Glúteos: cuerpo completo (3 días)",
                         "Po: Ganzkörper (3 Tage)","Fessiers : corps entier (3 jours)","Glúteos: corpo inteiro (3 dias)","Pośladki: całe ciało (3 dni)","Glutei: corpo intero (3 giorni)"),
            desc: LocStr(
                "Найпопулярніший формат: 3 рази/тиждень, сідниці й ноги — важко в кожному тренуванні, верх — легко для тонусу.",
                "The most popular format: 3×/week, glutes and legs trained hard each session, upper kept light for tone.",
                "Самый популярный формат: 3 раза/нед, ягодицы и ноги — тяжело, верх — легко для тонуса.",
                "El formato más popular: 3×/sem, glúteos y piernas duro, superior ligero para tono.",
                "Das beliebteste Format: 3×/Woche, Po und Beine hart, Oberkörper leicht für Tonus.",
                "Le format le plus populaire : 3×/sem, fessiers et jambes intenses, haut léger pour le tonus.",
                "O formato mais popular: 3×/sem, glúteos e pernas pesado, superior leve para tônus.",
                "Najpopularniejszy format: 3×/tydz, pośladki i nogi mocno, góra lekko dla napięcia.",
                "Il formato più popolare: 3×/sett, glutei e gambe intensi, parte alta leggera per il tono."),
            gender: .women, category: .glutes, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.glutesDay, items: [
                    .ex("hip_thrust", 4, 10, "4×10"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("squat_bulgarian", 3, 12, "3×12"),
                    .ex("abductor_machine", 4, 20, "4×20"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.glutesDay, items: [
                    .ex("squat_back", 4, 10, "4×10"),
                    .ex("glute_bridge_barbell", 4, 12, "4×12"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_curl_seated", 3, 12, "3×12"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.glutesDay, items: [
                    .ex("hip_thrust", 4, 12, "4×12"),
                    .ex("step_up", 3, 12, "3×12"),
                    .ex("leg_press_wide", 4, 15, "4×15"),
                    .ex("adductor_machine", 3, 20, "3×20"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_glute_ul4",
            name: LocStr("Сідниці: верх/низ (4 дні)","Glutes: Upper/Lower (4 days)","Ягодицы: верх/низ (4 дня)","Glúteos: sup./inf. (4 días)",
                         "Po: Ober/Unter (4 Tage)","Fessiers : haut/bas (4 jours)","Glúteos: sup./inf. (4 dias)","Pośladki: góra/dół (4 dni)","Glutei: sopra/sotto (4 giorni)"),
            desc: LocStr(
                "Два важкі дні низу й два легкі дні верху на тиждень. Ідеально, коли головна мета — сідниці й ноги.",
                "Two hard lower days and two light upper days a week. Ideal when glutes and legs are the main goal.",
                "Два тяжёлых дня низа и два лёгких дня верха в неделю. Идеально, когда цель — ягодицы и ноги.",
                "Dos días duros de inferior y dos ligeros de superior. Ideal si el objetivo son glúteos y piernas.",
                "Zwei harte Unter- und zwei leichte Obertage pro Woche. Ideal, wenn Po und Beine das Ziel sind.",
                "Deux jours bas intenses et deux jours haut légers. Idéal si l'objectif est fessiers et jambes.",
                "Dois dias pesados de inferior e dois leves de superior. Ideal quando o foco são glúteos e pernas.",
                "Dwa ciężkie dni dołu i dwa lekkie dni góry. Idealne, gdy cel to pośladki i nogi.",
                "Due giorni intensi di gambe e due leggeri di parte alta. Ideale se l'obiettivo sono glutei e gambe."),
            gender: .women, category: .glutes, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("hip_thrust", 4, 8, "4×8"),
                    .ex("squat_back", 4, 10, "4×10"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("abductor_machine", 4, 20, "4×20"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.upperLight, items: [
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                    .ex("face_pull", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("squat_bulgarian", 4, 10, "4×10"),
                    .ex("glute_bridge_barbell", 4, 12, "4×12"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_press_wide", 4, 15, "4×15"),
                    .ex("adductor_machine", 3, 20, "3×20"),
                ]),
                ProgramDay(title: PL.upperLight, items: [
                    .ex("machine_shoulder_press", 3, 12, "3×12"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_booty5",
            name: LocStr("Booty (5 днів)","Booty (5 days)","Booty (5 дней)","Booty (5 días)",
                         "Booty (5 Tage)","Booty (5 jours)","Booty (5 dias)","Booty (5 dni)","Booty (5 giorni)"),
            desc: LocStr(
                "Максимальна спеціалізація на сідницях: 3 силові/пампінгові дні низу, 1 легкий верх і 1 день кардіо+тонус.",
                "Maximum glute specialization: 3 strength/pump lower days, 1 light upper day and 1 cardio + tone day.",
                "Максимальная специализация на ягодицах: 3 силовых/памповых дня низа, 1 лёгкий верх и 1 день кардио+тонус.",
                "Máxima especialización en glúteos: 3 días de fuerza/bombeo inferior, 1 superior ligero y 1 de cardio + tono.",
                "Maximale Po-Spezialisierung: 3 Kraft-/Pump-Unterkörpertage, 1 leichter Obertag und 1 Cardio-/Tonustag.",
                "Spécialisation fessiers maximale : 3 jours bas force/pump, 1 haut léger et 1 cardio + tonus.",
                "Especialização máxima em glúteos: 3 dias de força/pump inferior, 1 superior leve e 1 de cardio + tônus.",
                "Maksymalna specjalizacja na pośladki: 3 dni siła/pompa dołu, 1 lekka góra i 1 cardio + napięcie.",
                "Massima specializzazione glutei: 3 giorni forza/pump gambe, 1 parte alta leggera e 1 cardio + tono."),
            gender: .women, category: .glutes, level: .advanced, days: 5,
            schedule: [
                ProgramDay(title: LocStr("Сідниці (сила)","Glutes (strength)","Ягодицы (сила)","Glúteos (fuerza)","Po (Kraft)","Fessiers (force)","Glúteos (força)","Pośladki (siła)","Glutei (forza)"), items: [
                    .ex("hip_thrust", 4, 8, "4×8"),
                    .ex("squat_back", 4, 8, "4×8"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                ]),
                ProgramDay(title: PL.upperLight, items: [
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                ]),
                ProgramDay(title: LocStr("Сідниці (памп)","Glutes (pump)","Ягодицы (памп)","Glúteos (bombeo)","Po (Pump)","Fessiers (pump)","Glúteos (pump)","Pośladki (pompa)","Glutei (pump)"), items: [
                    .ex("glute_bridge_barbell", 4, 15, "4×15"),
                    .ex("abductor_machine", 4, 20, "4×20"),
                    .ex("lunges_walking", 3, 15, "3×15"),
                    .ex("step_up", 3, 15, "3×15"),
                    .ex("adductor_machine", 3, 20, "3×20"),
                ]),
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("squat_bulgarian", 4, 10, "4×10"),
                    .ex("leg_press_wide", 4, 12, "4×12"),
                    .ex("leg_curl_seated", 4, 12, "4×12"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.cardioDay, items: [
                    .ex("abductor_machine", 3, 25, "3×25"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                    .ex("plank", 3, 0, "45–60 с"),
                    .cardio("incline_walking", 30, "стале, нахил"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_lower_spec4",
            name: LocStr("Ноги/сідниці: спеціалізація (4 дні)","Legs/Glutes Specialization (4 days)","Ноги/ягодицы: специализация (4 дня)","Piernas/glúteos: especialización (4 días)",
                         "Beine/Po: Spezialisierung (4 Tage)","Jambes/fessiers : spécialisation (4 jours)","Pernas/glúteos: especialização (4 dias)","Nogi/pośladki: specjalizacja (4 dni)","Gambe/glutei: specializzazione (4 giorni)"),
            desc: LocStr(
                "Для досвідчених: важкий день, день гіпертрофії, день пампінгу для низу + один легкий верх. Серйозна робота над формою ніг і сідниць.",
                "For experienced women: a heavy day, a hypertrophy day, a pump day for the lower body + one light upper. Serious leg/glute shaping.",
                "Для опытных: тяжёлый день, день гипертрофии, день пампинга для низа + 1 лёгкий верх.",
                "Para avanzadas: día pesado, día de hipertrofia, día de bombeo para inferior + 1 superior ligero.",
                "Für Geübte: schwerer Tag, Hypertrophietag, Pump-Tag für unten + 1 leichter Obertag.",
                "Pour confirmées : jour lourd, jour hypertrophie, jour pump pour le bas + 1 haut léger.",
                "Para avançadas: dia pesado, dia de hipertrofia, dia de pump para inferior + 1 superior leve.",
                "Dla zaawansowanych: dzień ciężki, hipertrofii, pompy dla dołu + 1 lekka góra.",
                "Per esperte: giorno pesante, ipertrofia, pump per le gambe + 1 parte alta leggera."),
            gender: .women, category: .glutes, level: .advanced, days: 4,
            schedule: [
                ProgramDay(title: LocStr("Низ (важко)","Lower (heavy)","Низ (тяжело)","Inferior (pesado)","Unten (schwer)","Bas (lourd)","Inferior (pesado)","Dół (ciężko)","Gambe (pesante)"), items: [
                    .ex("hip_thrust", 5, 6, "5×6"),
                    .ex("squat_back", 4, 8, "4×8"),
                    .ex("romanian_deadlift", 3, 8, "3×8"),
                ]),
                ProgramDay(title: PL.upperLight, items: [
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("face_pull", 3, 15, "3×15"),
                ]),
                ProgramDay(title: LocStr("Низ (гіпертрофія)","Lower (hypertrophy)","Низ (гипертрофия)","Inferior (hipertrofia)","Unten (Hypertrophie)","Bas (hypertrophie)","Inferior (hipertrofia)","Dół (hipertrofia)","Gambe (ipertrofia)"), items: [
                    .ex("squat_bulgarian", 4, 10, "4×10"),
                    .ex("leg_press_wide", 4, 12, "4×12"),
                    .ex("leg_curl_seated", 4, 12, "4×12"),
                    .ex("abductor_machine", 4, 20, "4×20"),
                ]),
                ProgramDay(title: LocStr("Низ (памп)","Lower (pump)","Низ (памп)","Inferior (bombeo)","Unten (Pump)","Bas (pump)","Inferior (pump)","Dół (pompa)","Gambe (pump)"), items: [
                    .ex("glute_bridge_barbell", 4, 15, "4×15"),
                    .ex("hip_thrust", 4, 15, "4×15"),
                    .ex("step_up", 3, 15, "3×15"),
                    .ex("adductor_machine", 4, 20, "4×20"),
                    .ex("lunges_static", 3, 15, "3×15"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_balanced_ul4",
            name: LocStr("Збалансований верх/низ (4 дні)","Balanced Upper/Lower (4 days)","Сбалансированный верх/низ (4 дня)","Equilibrado sup./inf. (4 días)",
                         "Ausgewogen Ober/Unter (4 Tage)","Équilibré haut/bas (4 jours)","Equilibrado sup./inf. (4 dias)","Zbalansowany góra/dół (4 dni)","Bilanciato sopra/sotto (4 giorni)"),
            desc: LocStr(
                "Коли хочеться форми всього тіла, а не лише низу: верх і низ двічі на тиждень, рівномірне навантаження.",
                "When you want a balanced whole-body shape, not just the lower body: upper and lower twice a week, even effort.",
                "Когда хочется формы всего тела, а не только низа: верх и низ дважды в неделю, равномерно.",
                "Cuando quieres forma de todo el cuerpo: superior e inferior 2×/sem, esfuerzo parejo.",
                "Wenn der ganze Körper geformt werden soll: Ober und Unter 2×/Woche, gleichmäßig.",
                "Quand on veut une forme globale : haut et bas 2×/sem, effort équilibré.",
                "Quando se quer forma de corpo inteiro: superior e inferior 2×/sem, esforço uniforme.",
                "Gdy chcesz formy całego ciała: góra i dół 2×/tydz, równomiernie.",
                "Quando vuoi una forma di tutto il corpo: sopra e sotto 2×/sett, sforzo uniforme."),
            gender: .women, category: .glutes, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.lower, items: [
                    .ex("squat_back", 4, 8, "4×8"),
                    .ex("hip_thrust", 4, 10, "4×10"),
                    .ex("leg_curl_lying", 3, 12, "3×12"),
                    .ex("calf_raise_standing", 4, 15, "4×15"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("machine_chest_press", 3, 10, "3×10"),
                    .ex("lat_pulldown_wide", 3, 10, "3×10"),
                    .ex("seated_dumbbell_press", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 3, 12, "3×12"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("romanian_deadlift", 4, 8, "4×8"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("abductor_machine", 4, 20, "4×20"),
                    .ex("glute_bridge_barbell", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("incline_bench_press_dumbbell", 3, 10, "3×10"),
                    .ex("seated_row_v", 3, 10, "3×10"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                    .ex("cable_curl_straight", 3, 12, "3×12"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Жінки / Сила
// =====================================================================

extension BuiltInPrograms {
    static let womenStrength: [BuiltInProgram] = [
        BuiltInProgram(
            id: "w_strength3",
            name: LocStr("Жіноча сила (3 дні)","Women's Strength (3 days)","Женская сила (3 дня)","Fuerza femenina (3 días)",
                         "Frauen-Kraft (3 Tage)","Force femme (3 jours)","Força feminina (3 dias)","Siła kobiet (3 dni)","Forza femminile (3 giorni)"),
            desc: LocStr(
                "Стати сильнішою на базових рухах: присід, тяга, жим і ягодичний міст у малих повторах. Сила теж дає форму.",
                "Get strong on the basics: squat, deadlift, press and hip thrust in low reps. Strength shapes the body too.",
                "Стать сильнее на базе: присед, тяга, жим и ягодичный мост в малых повторах.",
                "Hazte fuerte en lo básico: sentadilla, peso muerto, press y hip thrust en pocas reps.",
                "Werde stark an den Basics: Kniebeuge, Kreuzheben, Drücken und Hip Thrust in wenigen Wdh.",
                "Deviens forte sur les basiques : squat, soulevé, développé et hip thrust en peu de reps.",
                "Fique forte no básico: agachamento, terra, press e hip thrust em poucas reps.",
                "Stań się silna na bazie: przysiad, martwy, wyciskanie i hip thrust w małej liczbie powt.",
                "Diventa forte sui fondamentali: squat, stacco, distensioni e hip thrust a poche ripetizioni."),
            tip: LocStr("Малі повтори, важка вага. Додавай 2.5 кг, коли всі підходи виходять чисто.",
                        "Low reps, heavy weight. Add 2.5 kg when all sets go up cleanly.",
                        "Малые повторы, тяжёлый вес. Добавляй 2.5 кг, когда все подходы чисто.",
                        "Pocas reps, peso alto. Suma 2.5 kg cuando todas las series salgan limpias.",
                        "Wenige Wdh, schweres Gewicht. +2.5 kg, wenn alle Sätze sauber sind.",
                        "Peu de reps, charge lourde. +2.5 kg quand toutes les séries sont propres.",
                        "Poucas reps, peso alto. +2.5 kg quando todas as séries saírem limpas.",
                        "Mało powt, ciężki ciężar. +2.5 kg, gdy wszystkie serie czysto.",
                        "Poche rip, peso alto. +2.5 kg quando tutte le serie sono pulite."),
            gender: .women, category: .strength, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 3, 5, "3×5"),
                    .ex("bench_press_barbell", 3, 5, "3×5"),
                    .ex("hip_thrust", 3, 8, "3×8"),
                ]),
                ProgramDay(title: PL.dayB, items: [
                    .ex("romanian_deadlift", 3, 6, "3×6"),
                    .ex("overhead_press_dumbbell", 3, 8, "3×8"),
                    .ex("lat_pulldown_wide", 3, 8, "3×8"),
                ]),
                ProgramDay(title: PL.dayA, items: [
                    .ex("squat_back", 3, 5, "3×5"),
                    .ex("hip_thrust", 4, 8, "4×8"),
                    .ex("seated_row_v", 3, 8, "3×8"),
                    .ex("glute_bridge_barbell", 3, 12, "3×12"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Жінки / Сушка
// =====================================================================

extension BuiltInPrograms {
    static let womenCutting: [BuiltInProgram] = [
        BuiltInProgram(
            id: "w_cut3",
            name: LocStr("Сушка: низ-акцент (3 дні)","Cutting: Lower focus (3 days)","Сушка: низ-акцент (3 дня)","Definición: foco inferior (3 días)",
                         "Definition: Unterkörper (3 Tage)","Sèche : focus bas (3 jours)","Definição: foco inferior (3 dias)","Redukcja: dół-akcent (3 dni)","Definizione: focus gambe (3 giorni)"),
            desc: LocStr(
                "Зберегти сідниці й тонус на дефіциті: важка робота на низ + HIIT і ходьба. Верх — легко.",
                "Keep glutes and tone in a deficit: hard lower-body work + HIIT and walking. Upper kept light.",
                "Сохранить ягодицы и тонус на дефиците: тяжёлая работа на низ + HIIT и ходьба.",
                "Conservar glúteos y tono en déficit: trabajo duro de inferior + HIIT y caminata.",
                "Po und Tonus im Defizit halten: harte Unterkörperarbeit + HIIT und Gehen.",
                "Garder fessiers et tonus en déficit : bas intense + HIIT et marche.",
                "Manter glúteos e tônus no déficit: inferior pesado + HIIT e caminhada.",
                "Utrzymać pośladki i napięcie na deficycie: mocny dół + HIIT i spacer.",
                "Mantenere glutei e tono in deficit: gambe intense + HIIT e camminata."),
            tip: LocStr("Дефіцит роблять їжею. Силові ваги тримай — це зберігає форму. HIIT 1–2 рази/тиждень, решта — ходьба.",
                        "The deficit comes from food. Keep the lifting weights — that holds your shape. HIIT 1–2×/week, rest is walking.",
                        "Дефицит делают едой. Силовые веса держи — это сохраняет форму. HIIT 1–2 раза/нед.",
                        "El déficit es por dieta. Mantén los pesos — conserva la forma. HIIT 1–2×/sem.",
                        "Defizit über Ernährung. Gewichte halten — das erhält die Form. HIIT 1–2×/Woche.",
                        "Le déficit vient de l'alimentation. Garde les charges — ça préserve la forme. HIIT 1–2×/sem.",
                        "O déficit vem da dieta. Mantenha as cargas — preserva a forma. HIIT 1–2×/sem.",
                        "Deficyt robi dieta. Trzymaj ciężary — to chroni formę. HIIT 1–2×/tydz.",
                        "Il deficit viene dalla dieta. Tieni i pesi — preserva la forma. HIIT 1–2×/sett."),
            gender: .women, category: .cutting, level: .intermediate, days: 3,
            schedule: [
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("hip_thrust", 4, 10, "4×10"),
                    .ex("squat_back", 3, 10, "3×10"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .cardio("hiit", 10, "інтервали"),
                ]),
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("lunges_walking", 3, 12, "3×12"),
                    .ex("abductor_machine", 3, 20, "3×20"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .cardio("incline_walking", 25, "стале"),
                ]),
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("leg_press_wide", 4, 12, "4×12"),
                    .ex("glute_bridge_barbell", 3, 15, "3×15"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("cable_crunch", 3, 15, "3×15"),
                    .cardio("sprints", 8, "інтервали"),
                ]),
            ]),
        BuiltInProgram(
            id: "w_cut4",
            name: LocStr("Сушка: верх/низ (4 дні)","Cutting: Upper/Lower (4 days)","Сушка: верх/низ (4 дня)","Definición: sup./inf. (4 días)",
                         "Definition: Ober/Unter (4 Tage)","Sèche : haut/bas (4 jours)","Definição: sup./inf. (4 dias)","Redukcja: góra/dół (4 dni)","Definizione: sopra/sotto (4 giorni)"),
            desc: LocStr(
                "Більше тренувань для тонусу на дефіциті: два важкі дні низу й два легкі верху, кардіо щодня.",
                "More sessions for tone in a deficit: two hard lower days and two light upper days, daily cardio.",
                "Больше тренировок для тонуса на дефиците: два тяжёлых дня низа и два лёгких верха, кардио ежедневно.",
                "Más sesiones para el tono en déficit: dos días duros de inferior y dos ligeros de superior, cardio diario.",
                "Mehr Einheiten für Tonus im Defizit: zwei harte Unter- und zwei leichte Obertage, tägliches Cardio.",
                "Plus de séances pour le tonus en déficit : deux jours bas intenses et deux haut légers, cardio quotidien.",
                "Mais treinos para o tônus no déficit: dois dias pesados de inferior e dois leves de superior, cardio diário.",
                "Więcej treningów dla napięcia na deficycie: dwa ciężkie dni dołu i dwa lekkie góry, cardio codziennie.",
                "Più sedute per il tono in deficit: due giorni intensi di gambe e due leggeri di parte alta, cardio quotidiano."),
            gender: .women, category: .cutting, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("hip_thrust", 4, 10, "4×10"),
                    .ex("squat_back", 4, 10, "4×10"),
                    .ex("romanian_deadlift", 3, 10, "3×10"),
                    .ex("abductor_machine", 4, 20, "4×20"),
                    .cardio("hiit", 10, "інтервали"),
                ]),
                ProgramDay(title: PL.upperLight, items: [
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                    .cardio("incline_walking", 25, "стале"),
                ]),
                ProgramDay(title: PL.lowerHard, items: [
                    .ex("squat_bulgarian", 4, 10, "4×10"),
                    .ex("leg_press_wide", 4, 12, "4×12"),
                    .ex("glute_bridge_barbell", 4, 12, "4×12"),
                    .ex("adductor_machine", 3, 20, "3×20"),
                    .cardio("cycling", 20, "стале"),
                ]),
                ProgramDay(title: PL.upperLight, items: [
                    .ex("machine_shoulder_press", 3, 12, "3×12"),
                    .ex("rear_delt_fly_dumbbell", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                    .cardio("incline_walking", 25, "стале"),
                ]),
            ]),
    ]
}

// =====================================================================
// MARK: - ДАНІ: Безпечно для спини (для всіх)
// =====================================================================

extension BuiltInPrograms {
    static let backSafe: [BuiltInProgram] = [
        BuiltInProgram(
            id: "bs_mcgill3",
            name: LocStr("Основа для спини (McGill Big 3)","Back Foundation (McGill Big 3)","Основа для спины (McGill Big 3)","Base para espalda (McGill Big 3)",
                         "Rücken-Basis (McGill Big 3)","Base du dos (McGill Big 3)","Base para costas (McGill Big 3)","Podstawa pleców (McGill Big 3)","Base per la schiena (McGill Big 3)"),
            desc: LocStr(
                "Три безпечні вправи для стабільності хребта без згинань і осьового навантаження. М'який щоденний фундамент при болях у спині.",
                "Three safe exercises for spine stability without flexion or axial load. A gentle daily foundation when your back hurts.",
                "Три безопасных упражнения для стабильности позвоночника без сгибаний и осевой нагрузки. Мягкая ежедневная основа.",
                "Tres ejercicios seguros para estabilidad de la columna sin flexión ni carga axial. Base diaria suave.",
                "Drei sichere Übungen für Wirbelsäulenstabilität ohne Beugung und axiale Last. Sanfte tägliche Basis.",
                "Trois exercices sûrs pour la stabilité du rachis, sans flexion ni charge axiale. Base douce quotidienne.",
                "Três exercícios seguros para estabilidade da coluna sem flexão nem carga axial. Base diária suave.",
                "Trzy bezpieczne ćwiczenia na stabilność kręgosłupa bez zginania i obciążenia osiowego. Łagodna codzienna baza.",
                "Tre esercizi sicuri per la stabilità della colonna senza flessione né carico assiale. Base quotidiana dolce."),
            tip: LocStr("⚠️ Спершу проконсультуйся з лікарем/фізіотерапевтом. Рухи повільні, без болю; можна робити щодня. Без різких скручувань хребта.",
                        "⚠️ Consult a doctor/physiotherapist first. Move slowly, pain-free; can be done daily. No sharp spinal twisting.",
                        "⚠️ Сначала проконсультируйся с врачом/физиотерапевтом. Движения медленные, без боли; можно ежедневно.",
                        "⚠️ Consulta primero a un médico/fisioterapeuta. Movimientos lentos, sin dolor; a diario.",
                        "⚠️ Zuerst Arzt/Physiotherapeut fragen. Langsam, schmerzfrei; täglich möglich.",
                        "⚠️ Consulte d'abord un médecin/kiné. Mouvements lents, sans douleur ; quotidien possible.",
                        "⚠️ Consulte primeiro médico/fisioterapeuta. Movimentos lentos, sem dor; diário.",
                        "⚠️ Najpierw skonsultuj się z lekarzem/fizjoterapeutą. Powoli, bez bólu; codziennie.",
                        "⚠️ Consulta prima un medico/fisioterapista. Movimenti lenti, senza dolore; quotidiano."),
            gender: .any, category: .backsafe, level: .beginner, days: 3,
            schedule: [
                ProgramDay(title: LocStr("Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3"), items: [
                    .custom(PL.curlUp, .abs, 3, 6, "3×6 (8 с утримання)"),
                    .ex("side_plank", 3, 0, "3×20–40 с / бік"),
                    .custom(PL.birdDog, .abs, 3, 8, "3×8 / бік (повільно)"),
                    .cardio("walking", 20, "спокійно"),
                ]),
                ProgramDay(title: LocStr("Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3"), items: [
                    .custom(PL.curlUp, .abs, 3, 6, "3×6 (8 с утримання)"),
                    .ex("side_plank", 3, 0, "3×20–40 с / бік"),
                    .custom(PL.birdDog, .abs, 3, 8, "3×8 / бік (повільно)"),
                    .ex("dead_bug", 3, 10, "3×10"),
                    .cardio("walking", 20, "спокійно"),
                ]),
                ProgramDay(title: LocStr("Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3","Big 3"), items: [
                    .custom(PL.curlUp, .abs, 3, 6, "3×6 (8 с утримання)"),
                    .ex("side_plank", 3, 0, "3×20–40 с / бік"),
                    .custom(PL.birdDog, .abs, 3, 8, "3×8 / бік (повільно)"),
                    .cardio("walking", 25, "спокійно"),
                ]),
            ]),
        BuiltInProgram(
            id: "bs_fb3",
            name: LocStr("Безпечне повне тіло (3 дні)","Back-safe Full Body (3 days)","Безопасное всё тело (3 дня)","Cuerpo completo seguro (3 días)",
                         "Rückenschonend Ganzkörper (3 Tage)","Corps entier sécurisé dos (3 jours)","Corpo inteiro seguro (3 dias)","Bezpieczne całe ciało (3 dni)","Corpo intero sicuro (3 giorni)"),
            desc: LocStr(
                "Сила без навантаження на хребет: тренажери з опорою для спини й рухи з нейтральним хребтом. Замість присіду зі штангою та станової.",
                "Strength without loading the spine: back-supported machines and neutral-spine moves. Replaces barbell squats and deadlifts.",
                "Сила без нагрузки на позвоночник: тренажёры с опорой для спины и движения с нейтральным позвоночником.",
                "Fuerza sin cargar la columna: máquinas con respaldo y movimientos de columna neutra.",
                "Kraft ohne Wirbelsäulenlast: Maschinen mit Rückenstütze und Übungen mit neutraler Wirbelsäule.",
                "Force sans charger la colonne : machines avec dossier et mouvements à colonne neutre.",
                "Força sem carregar a coluna: máquinas com apoio e movimentos de coluna neutra.",
                "Siła bez obciążania kręgosłupa: maszyny z oparciem i ruchy z neutralnym kręgosłupem.",
                "Forza senza caricare la colonna: macchine con schienale e movimenti a colonna neutra."),
            tip: LocStr("⚠️ Узгодь із лікарем/фізіотерапевтом. Уникай осьового навантаження й болю. Вага помірна, техніка повільна.",
                        "⚠️ Clear it with a doctor/physiotherapist. Avoid axial load and pain. Moderate weight, slow form.",
                        "⚠️ Согласуй с врачом/физиотерапевтом. Избегай осевой нагрузки и боли. Вес умеренный.",
                        "⚠️ Acuérdalo con un médico/fisioterapeuta. Evita carga axial y dolor. Peso moderado.",
                        "⚠️ Mit Arzt/Physiotherapeut abklären. Axiale Last und Schmerz vermeiden. Moderates Gewicht.",
                        "⚠️ Validez avec un médecin/kiné. Évitez charge axiale et douleur. Poids modéré.",
                        "⚠️ Combine com médico/fisioterapeuta. Evite carga axial e dor. Peso moderado.",
                        "⚠️ Uzgodnij z lekarzem/fizjoterapeutą. Unikaj obciążenia osiowego i bólu. Umiarkowany ciężar.",
                        "⚠️ Concordalo con medico/fisioterapista. Evita carico assiale e dolore. Peso moderato."),
            gender: .any, category: .backsafe, level: .beginner, days: 3,
            schedule: [
                ProgramDay(title: PL.fullBody, items: [
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("chest_supported_row", 3, 12, "3×12"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                    .ex("machine_shoulder_press", 3, 12, "3×12"),
                    .ex("side_plank", 3, 0, "3×20–30 с"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("leg_curl_seated", 3, 12, "3×12"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("glute_bridge_barbell", 3, 15, "3×15"),
                    .ex("dead_bug", 3, 10, "3×10"),
                ]),
                ProgramDay(title: PL.fullBody, items: [
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("chest_supported_row", 3, 12, "3×12"),
                    .ex("machine_shoulder_press", 3, 12, "3×12"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                    .ex("abductor_machine", 3, 20, "3×20"),
                    .custom(PL.birdDog, .abs, 3, 8, "3×8 / бік"),
                ]),
            ]),
        BuiltInProgram(
            id: "bs_ul4",
            name: LocStr("Безпечний верх/низ (4 дні)","Back-safe Upper/Lower (4 days)","Безопасный верх/низ (4 дня)","Sup./inf. seguro (4 días)",
                         "Rückenschonend Ober/Unter (4 Tage)","Haut/bas sécurisé (4 jours)","Sup./inf. seguro (4 dias)","Bezpieczne góra/dół (4 dni)","Sopra/sotto sicuro (4 giorni)"),
            desc: LocStr(
                "Для тих, хто вже зміцнив спину й хоче більше: верх/низ двічі на тиждень на тренажерах із опорою, без осьового навантаження.",
                "For those who have rebuilt their back and want more: upper/lower twice a week on supported machines, no axial load.",
                "Для тех, кто уже укрепил спину и хочет больше: верх/низ дважды в неделю на тренажёрах с опорой.",
                "Para quienes ya fortalecieron la espalda y quieren más: sup./inf. 2×/sem en máquinas con respaldo.",
                "Für alle mit wieder gestärktem Rücken: Ober/Unter 2×/Woche an gestützten Maschinen.",
                "Pour ceux qui ont renforcé leur dos : haut/bas 2×/sem sur machines avec appui.",
                "Para quem já fortaleceu as costas: sup./inf. 2×/sem em máquinas com apoio.",
                "Dla tych, którzy wzmocnili plecy: góra/dół 2×/tydz na maszynach z oparciem.",
                "Per chi ha rinforzato la schiena: sopra/sotto 2×/sett su macchine con appoggio."),
            tip: LocStr("⚠️ Лише після дозволу лікаря/фізіотерапевта і коли біль минув. Жодних рухів через біль.",
                        "⚠️ Only after a doctor/physiotherapist clears you and pain is gone. Never train through pain.",
                        "⚠️ Только после разрешения врача/физиотерапевта и когда боль прошла.",
                        "⚠️ Solo con permiso del médico/fisioterapeuta y sin dolor.",
                        "⚠️ Nur nach Freigabe von Arzt/Physiotherapeut und schmerzfrei.",
                        "⚠️ Seulement après accord du médecin/kiné et sans douleur.",
                        "⚠️ Apenas com liberação do médico/fisioterapeuta e sem dor.",
                        "⚠️ Tylko po zgodzie lekarza/fizjoterapeuty i bez bólu.",
                        "⚠️ Solo dopo l'ok del medico/fisioterapista e senza dolore."),
            gender: .any, category: .backsafe, level: .intermediate, days: 4,
            schedule: [
                ProgramDay(title: PL.lower, items: [
                    .ex("leg_press", 3, 12, "3×12"),
                    .ex("leg_extension", 3, 15, "3×15"),
                    .ex("leg_curl_seated", 3, 12, "3×12"),
                    .ex("hip_thrust", 3, 12, "3×12"),
                    .ex("abductor_machine", 3, 20, "3×20"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("chest_supported_row", 3, 12, "3×12"),
                    .ex("machine_shoulder_press", 3, 12, "3×12"),
                    .ex("lat_pulldown_wide", 3, 12, "3×12"),
                    .ex("face_pull", 3, 15, "3×15"),
                ]),
                ProgramDay(title: PL.lower, items: [
                    .ex("glute_bridge_barbell", 3, 12, "3×12"),
                    .ex("leg_press", 3, 15, "3×15"),
                    .ex("leg_curl_seated", 3, 12, "3×12"),
                    .ex("step_up", 3, 12, "3×12"),
                    .ex("adductor_machine", 3, 20, "3×20"),
                ]),
                ProgramDay(title: PL.upper, items: [
                    .ex("machine_chest_press", 3, 12, "3×12"),
                    .ex("seated_row_v", 3, 12, "3×12"),
                    .ex("lateral_raise_dumbbell", 3, 15, "3×15"),
                    .ex("rear_delt_fly_machine", 3, 15, "3×15"),
                    .ex("ez_bar_curl", 3, 12, "3×12"),
                    .ex("tricep_pushdown_rope", 3, 12, "3×12"),
                ]),
            ]),
    ]
}
