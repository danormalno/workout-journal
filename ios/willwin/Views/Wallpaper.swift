import SwiftUI
import PhotosUI

// =====================================================================
// MARK: - Вибір заставки
// =====================================================================

enum WallpaperChoice: String, CaseIterable, Identifiable {
    case none, dark, light, pink, custom
    var id: String { rawValue }

    /// Можливі назви зображення в Assets (пробуємо англ. і укр., щоб працювало за будь-якого варіанту).
    var assetCandidates: [String] {
        switch self {
        case .dark:  return ["wallpaper_dark", "темна", "Темна", "dark", "Dark"]
        case .light: return ["wallpaper_light", "світла", "Світла", "light", "Light"]
        case .pink:  return ["wallpaper_pink", "рожева", "Рожева", "pink", "Pink"]
        default:     return []
        }
    }

    var title: LocStr {
        switch self {
        case .none:   return LocStr("Без заставки","None","Без заставки","Sin fondo","Kein Hintergrund","Aucun","Sem fundo","Brak","Nessuno")
        case .dark:   return LocStr("Темна","Dark","Тёмная","Oscuro","Dunkel","Sombre","Escuro","Ciemna","Scuro")
        case .light:  return LocStr("Світла","Light","Светлая","Claro","Hell","Clair","Claro","Jasna","Chiaro")
        case .pink:   return LocStr("Рожева","Pink","Розовая","Rosa","Rosa","Rose","Rosa","Różowa","Rosa")
        case .custom: return LocStr("З галереї","From gallery","Из галереи","De galería","Aus Galerie","Galerie","Da galeria","Z galerii","Da galleria")
        }
    }
}

enum WallpaperScrim: String, CaseIterable, Identifiable {
    case none, darken, lighten
    var id: String { rawValue }

    var title: LocStr {
        switch self {
        case .none:    return LocStr("Без","Off","Без","No","Aus","Aucun","Sem","Brak","No")
        case .darken:  return LocStr("Затемнити","Darken","Затемнить","Oscurecer","Abdunkeln","Assombrir","Escurecer","Przyciemnij","Scurisci")
        case .lighten: return LocStr("Освітлити","Lighten","Осветлить","Aclarar","Aufhellen","Éclaircir","Clarear","Rozjaśnij","Schiarisci")
        }
    }
}

enum WallpaperStore {
    static let choiceKey = "willwin_wallpaper"
    static let scrimKey  = "willwin_wallpaper_scrim"
    static let amountKey = "willwin_wallpaper_amount"
    static let revKey    = "willwin_wallpaper_rev"

    static var customURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("willwin_wallpaper_custom.jpg")
    }

    static func saveCustom(_ data: Data) {
        try? data.write(to: customURL, options: [.atomic])
        let d = UserDefaults.standard
        d.set(WallpaperChoice.custom.rawValue, forKey: choiceKey)
        d.set(d.integer(forKey: revKey) + 1, forKey: revKey)
    }

    static func loadCustom() -> UIImage? {
        guard let data = try? Data(contentsOf: customURL) else { return nil }
        return UIImage(data: data)
    }
}

// =====================================================================
// MARK: - Фонова заставка (рендериться в корені застосунку)
// =====================================================================

struct WallpaperBackground: View {
    @AppStorage(WallpaperStore.choiceKey) private var choiceRaw = WallpaperChoice.none.rawValue
    @AppStorage(WallpaperStore.scrimKey)  private var scrimRaw  = WallpaperScrim.none.rawValue
    @AppStorage(WallpaperStore.amountKey) private var amount    = 0.25
    @AppStorage(WallpaperStore.revKey)    private var rev        = 0

    var body: some View {
        let choice = WallpaperChoice(rawValue: choiceRaw) ?? .none
        // ВАЖЛИВО: базою є Color.clear (як фоновий колір) — він НЕ нав'язує розмір
        // сусіднім в'ю в ZStack, тому списки й заголовки зберігають безпечну зону.
        Color.clear
            .overlay {
                ZStack {
                    switch choice {
                    case .none:
                        Color.clear
                    case .custom:
                        if let ui = WallpaperStore.loadCustom() {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.clear
                        }
                    default:
                        if let name = resolvedAsset(for: choice) {
                            Image(name)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.clear
                        }
                    }
                    scrimOverlay
                }
            }
            .clipped()
            .ignoresSafeArea()
            .id(rev)
    }

    private func resolvedAsset(for choice: WallpaperChoice) -> String? {
        for name in choice.assetCandidates where UIImage(named: name) != nil {
            return name
        }
        return nil
    }

    @ViewBuilder
    private var scrimOverlay: some View {
        switch WallpaperScrim(rawValue: scrimRaw) ?? .none {
        case .none:    Color.clear
        case .darken:  Color.black.opacity(amount)
        case .lighten: Color.white.opacity(amount)
        }
    }
}

// =====================================================================
// MARK: - Читабельність тексту над заставкою
// =====================================================================

extension View {
    /// Додає тінь під текст ЛИШЕ коли активна заставка — щоб він не зливався з фото.
    func readableOnWallpaper() -> some View {
        modifier(WallpaperTextShadow())
    }
}

private struct WallpaperTextShadow: ViewModifier {
    @AppStorage(WallpaperStore.choiceKey) private var choiceRaw = WallpaperChoice.none.rawValue
    func body(content: Content) -> some View {
        let active = (WallpaperChoice(rawValue: choiceRaw) ?? .none) != .none
        return content
            .shadow(color: active ? Color.black.opacity(0.55) : .clear,
                    radius: active ? 3 : 0, x: 0, y: 1)
    }
}
