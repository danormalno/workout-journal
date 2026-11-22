import SwiftUI

struct CardioCard: View {
    let cardio: Cardio
    let position: CardioPosition
    let weekId: UUID
    let workoutId: UUID
    
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    @State private var minutesText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.run")
                .foregroundStyle(theme.accent)
                .frame(width: 24)
            
            Text(cardio.name)
                .font(.subheadline)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 4) {
                TextField("0", text: $minutesText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                    .focused($isFocused)
                    .onChange(of: minutesText) { _, newVal in
                        commitMinutes(newVal)
                    }
                Text(s.min)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            
            Menu {
                Button(role: .destructive) {
                    appState.deleteCardio(id: cardio.id, position: position, workoutId: workoutId, weekId: weekId)
                } label: {
                    Label(s.delete, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear { syncFromModel() }
        .onReceive(NotificationCenter.default.publisher(for: KeyboardToolbar.dismissRequested)) { _ in
            isFocused = false
        }
        .onChange(of: cardio) { _, _ in syncFromModel() }
    }
    
    private func syncFromModel() {
        minutesText = cardio.minutes == 0 ? "" : "\(cardio.minutes)"
    }
    
    private func commitMinutes(_ text: String) {
        let value = Int(text) ?? 0
        guard value != cardio.minutes else { return }
        var newCardio = cardio
        newCardio.minutes = value
        appState.updateCardio(newCardio, position: position, workoutId: workoutId, weekId: weekId)
    }
}
