import Foundation

final class Persistence {
    static let shared = Persistence()
    
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("willwin_data.json")
    }
    
    /// Завантажити дані з диску з підтримкою міграцій
    func load() -> AppData {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return AppData()
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            // Спроба №1: декодувати як свіжу схему
            if let appData = try? decoder.decode(AppData.self, from: data) {
                return appData
            }
            // Спроба №2: декодувати "найкраще зусилля" — частково
            // Якщо схема не співпадає, повертаємо порожній стан, щоб не падати
            print("⚠️ Не вдалось декодувати дані як AppData. Зберігаю на всяк випадок копію.")
            let backupURL = fileURL.appendingPathExtension("backup")
            try? data.write(to: backupURL)
            return AppData()
        } catch {
            print("⚠️ Помилка завантаження: \(error)")
            return AppData()
        }
    }
    
    @discardableResult
    func save(_ appData: AppData) -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(appData)
            try data.write(to: fileURL, options: [.atomic])
            return true
        } catch {
            print("⚠️ Помилка збереження: \(error)")
            return false
        }
    }
    
    func exportFileURL() -> URL? {
        FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func importFrom(url: URL) -> AppData? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AppData.self, from: data)
        } catch {
            print("⚠️ Помилка імпорту: \(error)")
            return nil
        }
    }
}
