import Foundation

/// Запис у базі кардіо.
struct LibraryCardio: Identifiable, Hashable {
    let id: String
    let names: [AppLanguage: String]
    
    func localizedName(for lang: AppLanguage?) -> String {
        let l = lang ?? .en
        return names[l] ?? names[.en] ?? id
    }
}

/// База популярних кардіо-вправ.
enum CardioLibrary {
    static let all: [LibraryCardio] = [
        LibraryCardio(id: "running", names: [
            .uk: "Біг", .en: "Running", .es: "Carrera", .de: "Laufen",
            .fr: "Course", .pt: "Corrida", .pl: "Bieganie", .it: "Corsa",
        ]),
        LibraryCardio(id: "treadmill", names: [
            .uk: "Бігова доріжка", .en: "Treadmill", .es: "Cinta de correr", .de: "Laufband",
            .fr: "Tapis de course", .pt: "Esteira", .pl: "Bieżnia", .it: "Tapis roulant",
        ]),
        LibraryCardio(id: "walking", names: [
            .uk: "Ходьба", .en: "Walking", .es: "Caminata", .de: "Gehen",
            .fr: "Marche", .pt: "Caminhada", .pl: "Spacer", .it: "Camminata",
        ]),
        LibraryCardio(id: "incline_walking", names: [
            .uk: "Ходьба під нахилом", .en: "Incline Walking", .es: "Caminata inclinada", .de: "Steigungsgehen",
            .fr: "Marche en pente", .pt: "Caminhada inclinada", .pl: "Spacer pod górę", .it: "Camminata in salita",
        ]),
        LibraryCardio(id: "cycling", names: [
            .uk: "Велотренажер", .en: "Cycling", .es: "Bicicleta", .de: "Radfahren",
            .fr: "Vélo", .pt: "Bicicleta", .pl: "Rower", .it: "Cyclette",
        ]),
        LibraryCardio(id: "outdoor_cycling", names: [
            .uk: "Велосипед на вулиці", .en: "Outdoor Cycling", .es: "Bicicleta exterior", .de: "Fahrrad draußen",
            .fr: "Vélo en plein air", .pt: "Ciclismo ao ar livre", .pl: "Jazda na rowerze", .it: "Bici all'aperto",
        ]),
        LibraryCardio(id: "spinning", names: [
            .uk: "Спінінг", .en: "Spinning", .es: "Spinning", .de: "Spinning",
            .fr: "Spinning", .pt: "Spinning", .pl: "Spinning", .it: "Spinning",
        ]),
        LibraryCardio(id: "rowing", names: [
            .uk: "Веслувальний тренажер", .en: "Rowing Machine", .es: "Máquina de remo", .de: "Rudermaschine",
            .fr: "Rameur", .pt: "Remo ergômetro", .pl: "Wioślarz", .it: "Vogatore",
        ]),
        LibraryCardio(id: "elliptical", names: [
            .uk: "Еліптичний тренажер", .en: "Elliptical", .es: "Elíptica", .de: "Crosstrainer",
            .fr: "Elliptique", .pt: "Elíptico", .pl: "Orbitrek", .it: "Ellittica",
        ]),
        LibraryCardio(id: "stair_climber", names: [
            .uk: "Степпер", .en: "Stair Climber", .es: "Escaladora", .de: "Stepper",
            .fr: "Stepper", .pt: "Escada", .pl: "Stepper", .it: "Stair climber",
        ]),
        LibraryCardio(id: "jump_rope", names: [
            .uk: "Скакалка", .en: "Jump Rope", .es: "Comba", .de: "Seilspringen",
            .fr: "Corde à sauter", .pt: "Pular corda", .pl: "Skakanka", .it: "Corda per saltare",
        ]),
        LibraryCardio(id: "burpees", names: [
            .uk: "Бьорпі", .en: "Burpees", .es: "Burpees", .de: "Burpees",
            .fr: "Burpees", .pt: "Burpees", .pl: "Burpees", .it: "Burpees",
        ]),
        LibraryCardio(id: "jumping_jacks", names: [
            .uk: "Стрибки \"зірочкою\"", .en: "Jumping Jacks", .es: "Saltos de tijera", .de: "Hampelmann",
            .fr: "Jumping jacks", .pt: "Polichinelo", .pl: "Pajacyki", .it: "Jumping jacks",
        ]),
        LibraryCardio(id: "high_knees", names: [
            .uk: "Біг з високим підняттям колін", .en: "High Knees", .es: "Rodillas altas", .de: "Knie hoch",
            .fr: "Montées de genoux", .pt: "Joelhos altos", .pl: "Wysokie kolana", .it: "Skip alto",
        ]),
        LibraryCardio(id: "mountain_climbers", names: [
            .uk: "Скелелаз", .en: "Mountain Climbers", .es: "Escaladores", .de: "Mountain Climbers",
            .fr: "Mountain climbers", .pt: "Escaladores", .pl: "Wspinacze", .it: "Mountain climbers",
        ]),
        LibraryCardio(id: "swimming", names: [
            .uk: "Плавання", .en: "Swimming", .es: "Natación", .de: "Schwimmen",
            .fr: "Natation", .pt: "Natação", .pl: "Pływanie", .it: "Nuoto",
        ]),
        LibraryCardio(id: "boxing", names: [
            .uk: "Бокс", .en: "Boxing", .es: "Boxeo", .de: "Boxen",
            .fr: "Boxe", .pt: "Boxe", .pl: "Boks", .it: "Pugilato",
        ]),
        LibraryCardio(id: "shadow_boxing", names: [
            .uk: "Бій з тінню", .en: "Shadow Boxing", .es: "Boxeo de sombra", .de: "Schattenboxen",
            .fr: "Boxe de l'ombre", .pt: "Luta com sombra", .pl: "Boks z cieniem", .it: "Shadow boxing",
        ]),
        LibraryCardio(id: "kickboxing", names: [
            .uk: "Кікбоксинг", .en: "Kickboxing", .es: "Kickboxing", .de: "Kickboxen",
            .fr: "Kickboxing", .pt: "Kickboxing", .pl: "Kickboxing", .it: "Kickboxing",
        ]),
        LibraryCardio(id: "hiit", names: [
            .uk: "HIIT (інтервали)", .en: "HIIT", .es: "HIIT", .de: "HIIT",
            .fr: "HIIT", .pt: "HIIT", .pl: "HIIT", .it: "HIIT",
        ]),
        LibraryCardio(id: "sprints", names: [
            .uk: "Спринти", .en: "Sprints", .es: "Sprints", .de: "Sprints",
            .fr: "Sprints", .pt: "Sprints", .pl: "Sprinty", .it: "Sprint",
        ]),
        LibraryCardio(id: "stairs", names: [
            .uk: "Біг по сходах", .en: "Stairs Climbing", .es: "Subir escaleras", .de: "Treppensteigen",
            .fr: "Montée d'escaliers", .pt: "Subida de escadas", .pl: "Wchodzenie po schodach", .it: "Salita scale",
        ]),
        LibraryCardio(id: "battle_ropes", names: [
            .uk: "Канати (battle ropes)", .en: "Battle Ropes", .es: "Cuerdas de batalla", .de: "Battle Ropes",
            .fr: "Battle ropes", .pt: "Cordas navais", .pl: "Battle ropes", .it: "Battle ropes",
        ]),
        LibraryCardio(id: "assault_bike", names: [
            .uk: "Air bike / Assault bike", .en: "Assault Bike", .es: "Air bike", .de: "Air Bike",
            .fr: "Air bike", .pt: "Air bike", .pl: "Air bike", .it: "Air bike",
        ]),
        LibraryCardio(id: "ski_erg", names: [
            .uk: "Лижний тренажер (Ski Erg)", .en: "Ski Erg", .es: "Ski Erg", .de: "Ski Erg",
            .fr: "Ski Erg", .pt: "Ski Erg", .pl: "Ski Erg", .it: "Ski Erg",
        ]),
        LibraryCardio(id: "dance", names: [
            .uk: "Танці", .en: "Dancing", .es: "Baile", .de: "Tanzen",
            .fr: "Danse", .pt: "Dança", .pl: "Taniec", .it: "Ballo",
        ]),
        LibraryCardio(id: "hiking", names: [
            .uk: "Похід / Хайкінг", .en: "Hiking", .es: "Senderismo", .de: "Wandern",
            .fr: "Randonnée", .pt: "Caminhada na trilha", .pl: "Wędrówka", .it: "Escursionismo",
        ]),
    ]
    
    static func search(_ query: String, language: AppLanguage?) -> [LibraryCardio] {
        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return all }
        return all.filter { c in
            c.names.values.contains(where: { $0.lowercased().contains(q) })
        }
    }
}
