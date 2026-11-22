import SwiftUI

struct AppTheme {
    var background: Color
    var cardBackground: Color
    var textPrimary: Color
    var textSecondary: Color
    var accent: Color
    var danger: Color
    
    static let defaultLight = AppTheme(
        background: Color(red: 0.97, green: 0.97, blue: 0.98),
        cardBackground: .white,
        textPrimary: Color(red: 0.1, green: 0.1, blue: 0.12),
        textSecondary: Color(red: 0.45, green: 0.45, blue: 0.5),
        accent: Color(red: 0.0, green: 0.48, blue: 1.0),
        danger: Color(red: 0.95, green: 0.27, blue: 0.27)
    )
    
    static let defaultDark = AppTheme(
        background: Color(red: 0.08, green: 0.08, blue: 0.1),
        cardBackground: Color(red: 0.14, green: 0.14, blue: 0.16),
        textPrimary: .white,
        textSecondary: Color(red: 0.65, green: 0.65, blue: 0.7),
        accent: Color(red: 0.25, green: 0.6, blue: 1.0),
        danger: Color(red: 1.0, green: 0.4, blue: 0.4)
    )
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .defaultLight
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
