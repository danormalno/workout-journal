import SwiftUI
import PhotosUI
import Combine

// MARK: - Модель

struct ProgressPhoto: Codable, Identifiable, Hashable {
    var id = UUID()
    var fileName: String
    var date: Date = Date()
    var note: String = ""
    var weight: Double? = nil
}

// MARK: - Сховище (файли в Documents + метадані в UserDefaults)

final class ProgressPhotoStore: ObservableObject {
    static let shared = ProgressPhotoStore()
    @Published private(set) var photos: [ProgressPhoto] = []
    private let key = "willwin_progress_photos_v1"

    private var dir: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let d = base.appendingPathComponent("ProgressPhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: d.path) {
            try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        }
        return d
    }

    private init() { load() }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ProgressPhoto].self, from: data) else { return }
        photos = decoded.sorted { $0.date > $1.date }
    }

    private func persist() {
        photos.sort { $0.date > $1.date }
        if let data = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func url(for photo: ProgressPhoto) -> URL {
        dir.appendingPathComponent(photo.fileName)
    }

    func image(for photo: ProgressPhoto) -> UIImage? {
        UIImage(contentsOfFile: url(for: photo).path)
    }

    func add(imageData: Data, note: String = "", weight: Double? = nil) {
        let id = UUID()
        let fileName = "\(id.uuidString).jpg"
        // стискаємо у JPEG для економії місця
        let dataToSave: Data
        if let ui = UIImage(data: imageData), let jpeg = ui.jpegData(compressionQuality: 0.7) {
            dataToSave = jpeg
        } else {
            dataToSave = imageData
        }
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            try dataToSave.write(to: fileURL, options: [.atomic])
            var photo = ProgressPhoto(fileName: fileName, date: Date(), note: note, weight: weight)
            photo.id = id
            photos.append(photo)
            persist()
        } catch {
            print("ProgressPhoto save error: \(error)")
        }
    }

    func update(_ photo: ProgressPhoto) {
        guard let idx = photos.firstIndex(where: { $0.id == photo.id }) else { return }
        photos[idx] = photo
        persist()
    }

    func remove(_ photo: ProgressPhoto) {
        try? FileManager.default.removeItem(at: url(for: photo))
        photos.removeAll { $0.id == photo.id }
        persist()
    }
}

// MARK: - Сітка

struct ProgressPhotosView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @StateObject private var store = ProgressPhotoStore.shared

    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var selected: ProgressPhoto? = nil
    @State private var isImporting = false

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 8)]

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            if store.photos.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(store.photos) { photo in
                            Button { selected = photo } label: {
                                ProgressPhotoThumb(photo: photo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
            }
            if isImporting {
                ProgressView().controlSize(.large)
            }
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "plus")
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            isImporting = true
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { store.add(imageData: data) }
                }
                await MainActor.run {
                    isImporting = false
                    pickerItem = nil
                }
            }
        }
        .sheet(item: $selected) { photo in
            ProgressPhotoDetailView(photo: photo)
                .environmentObject(appState)
                .environment(\.strings, s)
                .environment(\.appTheme, theme)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 54))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text(emptyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 32)
            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                Label(addLabel, systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var screenTitle: String {
        L("Фото прогресу", "Progress Photos", "Фото прогресса", "Fotos de progreso", "Fortschrittsfotos",
          "Photos de progrès", "Fotos de progresso", "Zdjęcia postępów", "Foto dei progressi")
    }
    private var emptyText: String {
        L("Додавай фото, щоб бачити зміни з часом.",
          "Add photos to track changes over time.",
          "Добавляй фото, чтобы видеть изменения со временем.",
          "Añade fotos para ver los cambios con el tiempo.",
          "Füge Fotos hinzu, um Veränderungen zu sehen.",
          "Ajoute des photos pour suivre l'évolution.",
          "Adicione fotos para acompanhar a evolução.",
          "Dodawaj zdjęcia, aby śledzić zmiany.",
          "Aggiungi foto per vedere i cambiamenti.")
    }
    private var addLabel: String {
        L("Додати фото", "Add photo", "Добавить фото", "Añadir foto", "Foto hinzufügen",
          "Ajouter une photo", "Adicionar foto", "Dodaj zdjęcie", "Aggiungi foto")
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

// MARK: - Мініатюра

struct ProgressPhotoThumb: View {
    let photo: ProgressPhoto
    @Environment(\.appTheme) var theme
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                theme.textSecondary.opacity(0.1)
            }
            Text(photo.date, style: .date)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
                .padding(4)
                .background(.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(4)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onAppear {
            if image == nil { image = ProgressPhotoStore.shared.image(for: photo) }
        }
    }
}

// MARK: - Деталі

struct ProgressPhotoDetailView: View {
    let photo: ProgressPhoto

    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @Environment(\.dismiss) var dismiss

    @State private var note: String = ""
    @State private var weightText: String = ""
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let img = ProgressPhotoStore.shared.image(for: photo) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }

                        Text(photo.date, style: .date)
                            .font(.headline)
                            .foregroundStyle(theme.textPrimary)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(weightLabel).foregroundStyle(theme.textSecondary)
                                TextField("—", text: $weightText)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                Text(s.kg).foregroundStyle(theme.textSecondary)
                            }
                            Divider()
                            Text(noteLabel).font(.caption).foregroundStyle(theme.textSecondary)
                            TextField(notePlaceholder, text: $note, axis: .vertical)
                                .lineLimit(2...5)
                        }
                        .padding(14)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label(deleteLabel, systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(s.save) { saveAndClose() }.bold()
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(s.done) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                        to: nil, from: nil, for: nil)
                    }.bold()
                }
            }
            .confirmationDialog(deleteConfirmText, isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button(deleteLabel, role: .destructive) {
                    ProgressPhotoStore.shared.remove(photo)
                    dismiss()
                }
                Button(s.cancel, role: .cancel) { }
            }
            .onAppear {
                note = photo.note
                weightText = photo.weight.map { $0 == floor($0) ? "\(Int($0))" : "\($0)" } ?? ""
            }
        }
    }

    private func saveAndClose() {
        var updated = photo
        updated.note = note
        let w = Double(weightText.replacingOccurrences(of: ",", with: "."))
        updated.weight = (w ?? 0) > 0 ? w : nil
        ProgressPhotoStore.shared.update(updated)
        dismiss()
    }

    private var weightLabel: String {
        L("Вага", "Weight", "Вес", "Peso", "Gewicht", "Poids", "Peso", "Waga", "Peso")
    }
    private var noteLabel: String {
        L("Нотатка", "Note", "Заметка", "Nota", "Notiz", "Note", "Nota", "Notatka", "Nota")
    }
    private var notePlaceholder: String {
        L("Як почуваєшся, що змінилось…", "How you feel, what changed…", "Как самочувствие, что изменилось…",
          "Cómo te sientes, qué cambió…", "Wie du dich fühlst…", "Comment tu te sens…",
          "Como te sentes…", "Jak się czujesz…", "Come ti senti…")
    }
    private var deleteLabel: String {
        L("Видалити", "Delete", "Удалить", "Eliminar", "Löschen", "Supprimer", "Eliminar", "Usuń", "Elimina")
    }
    private var deleteConfirmText: String {
        L("Видалити це фото?", "Delete this photo?", "Удалить это фото?", "¿Eliminar esta foto?",
          "Dieses Foto löschen?", "Supprimer cette photo ?", "Eliminar esta foto?", "Usunąć to zdjęcie?", "Eliminare questa foto?")
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
