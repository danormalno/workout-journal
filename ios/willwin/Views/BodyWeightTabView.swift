import SwiftUI
import Charts

struct BodyWeightTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    @State private var kgInt: Int = 70
    @State private var frac: Int = 0
    @State private var showingDateError: Bool = false
    
    private var entries: [BodyWeightEntry] {
        appState.data.bodyWeights.sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                WallpaperBackground()
                
                ScrollView {
                    VStack(spacing: 16) {
                        inputCard
                        
                        if entries.filter({ $0.date != nil }).count >= 2 {
                            chartCard
                        } else if entries.count == 1 {
                            singleEntryHint
                        }
                        
                        if !entries.isEmpty {
                            historyList
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(s.bodyWeight)
            .onAppear { seedFromLast() }
        }
    }
    
    // MARK: - Введення (барабан кг + соті)
    
    private var inputCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Picker("", selection: $kgInt) {
                    ForEach(30...250, id: \.self) { v in
                        Text("\(v)").tag(v)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                
                Text(",")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                
                Picker("", selection: $frac) {
                    ForEach(0...99, id: \.self) { v in
                        Text(String(format: "%02d", v)).tag(v)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                
                Text(s.kg)
                    .font(.headline)
                    .foregroundStyle(theme.textSecondary)
                    .padding(.leading, 6)
            }
            .frame(height: 130)
            
            Button {
                saveCurrentWeight()
            } label: {
                Label(s.save, systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            if showingDateError {
                Text("⚠️ \(dateErrorText)")
                    .font(.caption)
                    .foregroundStyle(theme.danger)
            }
        }
        .padding(14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var dateErrorText: String {
        switch appState.data.settings.language {
        case .en: return "Could not get the date. Try again later."
        case .ru: return "Не удалось получить дату. Попробуй позже."
        case .es: return "No se pudo obtener la fecha. Intenta más tarde."
        case .de: return "Datum konnte nicht ermittelt werden. Versuche es später."
        case .fr: return "Impossible d'obtenir la date. Réessaie plus tard."
        case .pt: return "Não foi possível obter a data. Tente mais tarde."
        case .pl: return "Nie udało się pobrać daty. Spróbuj później."
        case .it: return "Impossibile ottenere la data. Riprova più tardi."
        default: return "Не вдалось підтягнути дату. Спробуй пізніше."
        }
    }
    
    private func seedFromLast() {
        guard let last = entries.last?.weight, last > 0 else { return }
        kgInt = min(250, max(30, Int(last)))
        let f = Int((((last - floor(last)) * 100).rounded()))
        frac = min(99, max(0, f))
    }
    
    private func saveCurrentWeight() {
        let v = Double(kgInt) + Double(frac) / 100.0
        guard v > 0 else { return }
        let date = Date()
        if date.timeIntervalSince1970 < 1 {
            showingDateError = true
            return
        }
        showingDateError = false
        appState.addBodyWeightEntry(weight: v)
    }
    
    // MARK: - Графік
    
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(chartTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)
            
            let dataPoints = entries.compactMap { e -> (Date, Double)? in
                guard let d = e.date else { return nil }
                return (d, e.weight)
            }
            
            Chart {
                ForEach(Array(dataPoints.enumerated()), id: \.offset) { _, point in
                    LineMark(
                        x: .value("Date", point.0),
                        y: .value("Weight", point.1)
                    )
                    .foregroundStyle(theme.accent)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", point.0),
                        y: .value("Weight", point.1)
                    )
                    .foregroundStyle(theme.accent)
                }
            }
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(chartDateLabel(date))
                                .font(.caption2)
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                    AxisGridLine().foregroundStyle(theme.textSecondary.opacity(0.2))
                }
            }
            .chartXScale(domain: chartXDomain())
            .chartYAxis {
                AxisMarks { value in
                    if let v = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatWeight(v))
                                .font(.caption2)
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                    AxisGridLine().foregroundStyle(theme.textSecondary.opacity(0.2))
                }
            }
        }
        .padding(14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var chartTitle: String {
        switch appState.data.settings.language {
        case .en: return "Weight history"
        case .ru: return "История веса"
        case .es: return "Historial de peso"
        case .de: return "Gewichtsverlauf"
        case .fr: return "Historique du poids"
        case .pt: return "Histórico de peso"
        case .pl: return "Historia wagi"
        case .it: return "Storico del peso"
        default: return "Історія ваги"
        }
    }
    
    private var singleEntryHint: some View {
        Text(singleEntryHintText)
            .font(.caption)
            .foregroundStyle(theme.textSecondary)
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var singleEntryHintText: String {
        switch appState.data.settings.language {
        case .en: return "Need at least 2 values to draw a progress line"
        case .ru: return "Нужно минимум 2 значения для линии прогресса"
        case .es: return "Se necesitan al menos 2 valores para mostrar el progreso"
        case .de: return "Mindestens 2 Werte erforderlich, um den Verlauf zu zeichnen"
        case .fr: return "Au moins 2 valeurs sont nécessaires pour tracer la progression"
        case .pt: return "Necessários pelo menos 2 valores para mostrar o progresso"
        case .pl: return "Potrzeba co najmniej 2 wartości, aby narysować postęp"
        case .it: return "Servono almeno 2 valori per disegnare la linea di progresso"
        default: return "Треба більше 2 значень для створення лінії прогресу"
        }
    }
    
    // MARK: - Історія
    
    private var historyList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(historyTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)
            
            VStack(spacing: 6) {
                ForEach(entries.reversed()) { entry in
                    HStack {
                        Text(formatWeight(entry.weight) + " " + s.kg)
                            .fontWeight(.medium)
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                        if let d = entry.date {
                            Text(shortDate(d))
                                .font(.subheadline)
                                .foregroundStyle(theme.textSecondary)
                        } else {
                            Text("—")
                                .foregroundStyle(theme.textSecondary)
                        }
                        Button {
                            appState.deleteBodyWeightEntry(entry.id)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(theme.textSecondary.opacity(0.5))
                        }
                    }
                    .padding(12)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }
    
    private var historyTitle: String {
        switch appState.data.settings.language {
        case .en: return "History"
        case .ru: return "История"
        case .es: return "Historial"
        case .de: return "Verlauf"
        case .fr: return "Historique"
        case .pt: return "Histórico"
        case .pl: return "Historia"
        case .it: return "Cronologia"
        default: return "Історія"
        }
    }
    
    private func chartDateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        let calendar = Calendar.current
        let allInCurrentYear = entries.compactMap { $0.date }.allSatisfy {
            calendar.component(.year, from: $0) == calendar.component(.year, from: Date())
        }
        if allInCurrentYear {
            f.dateFormat = "dd.MM"
        } else {
            f.dateFormat = "dd.MM.yy"
        }
        return f.string(from: date)
    }
    
    private func chartXDomain() -> ClosedRange<Date> {
        let dates = entries.compactMap { $0.date }
        guard let minDate = dates.min(), let maxDate = dates.max() else {
            return Date()...Date()
        }
        if Calendar.current.isDate(minDate, inSameDayAs: maxDate) {
            let start = Calendar.current.date(byAdding: .day, value: -1, to: minDate) ?? minDate
            let end = Calendar.current.date(byAdding: .day, value: 1, to: maxDate) ?? maxDate
            return start...end
        }
        let interval = maxDate.timeIntervalSince(minDate)
        let pad = interval * 0.05
        return minDate.addingTimeInterval(-pad)...maxDate.addingTimeInterval(pad)
    }
    
    private func formatWeight(_ value: Double) -> String {
        if value == floor(value) { return "\(Int(value))" }
        return String(format: "%.2f", value)
    }
    
    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: date)
    }
}
