import SwiftUI

/// 8 акцентних кольорів для персоналізації.
/// НЕ плутати з `AppTheme` (Theme.swift) — це лише вибір кольору акценту,
/// який підміняє `AppTheme.accent` у ContentView.
enum AccentPalette: String, CaseIterable, Identifiable {
    case blue, indigo, purple, pink, red, orange, green, teal

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue:   return Color(red: 0.0,  green: 0.48, blue: 1.0)
        case .indigo: return Color(red: 0.35, green: 0.34, blue: 0.84)
        case .purple: return Color(red: 0.69, green: 0.32, blue: 0.87)
        case .pink:   return Color(red: 1.0,  green: 0.18, blue: 0.57)
        case .red:    return Color(red: 0.96, green: 0.26, blue: 0.21)
        case .orange: return Color(red: 1.0,  green: 0.58, blue: 0.0)
        case .green:  return Color(red: 0.20, green: 0.78, blue: 0.35)
        case .teal:   return Color(red: 0.19, green: 0.69, blue: 0.78)
        }
    }

    func title(_ lang: AppLanguage?) -> String {
        switch self {
        case .blue:   return L(lang, "Синій", "Blue", "Синий", "Azul", "Blau", "Bleu", "Azul", "Niebieski", "Blu")
        case .indigo: return L(lang, "Індиго", "Indigo", "Индиго", "Índigo", "Indigo", "Indigo", "Índigo", "Indygo", "Indaco")
        case .purple: return L(lang, "Фіолетовий", "Purple", "Фиолетовый", "Morado", "Lila", "Violet", "Roxo", "Fioletowy", "Viola")
        case .pink:   return L(lang, "Рожевий", "Pink", "Розовый", "Rosa", "Rosa", "Rose", "Rosa", "Różowy", "Rosa")
        case .red:    return L(lang, "Червоний", "Red", "Красный", "Rojo", "Rot", "Rouge", "Vermelho", "Czerwony", "Rosso")
        case .orange: return L(lang, "Помаранчевий", "Orange", "Оранжевый", "Naranja", "Orange", "Orange", "Laranja", "Pomarańczowy", "Arancione")
        case .green:  return L(lang, "Зелений", "Green", "Зелёный", "Verde", "Grün", "Vert", "Verde", "Zielony", "Verde")
        case .teal:   return L(lang, "Бірюзовий", "Teal", "Бирюзовый", "Verde azulado", "Türkis", "Turquoise", "Turquesa", "Morski", "Turchese")
        }
    }

    private func L(_ lang: AppLanguage?, _ uk: String, _ en: String, _ ru: String, _ es: String,
                   _ de: String, _ fr: String, _ pt: String, _ pl: String, _ it: String) -> String {
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
