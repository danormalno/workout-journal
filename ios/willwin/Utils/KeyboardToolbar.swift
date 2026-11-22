import SwiftUI
import UIKit

@MainActor
enum KeyboardToolbar {
    static let dismissRequested = Notification.Name("willwin.dismissKeyboard")
    fileprivate static var doneTitle = "Готово"

    static func install(doneTitle: String) {
        self.doneTitle = doneTitle
        let target = ToolbarTarget.shared
        NotificationCenter.default.removeObserver(target)
        for name in [UITextField.textDidBeginEditingNotification, UITextView.textDidBeginEditingNotification] {
            NotificationCenter.default.addObserver(target, selector: #selector(ToolbarTarget.didBeginEditing(_:)), name: name, object: nil)
        }
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }

    fileprivate static func makeToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: doneTitle, style: .done, target: ToolbarTarget.shared,
                            action: #selector(ToolbarTarget.dismissKeyboard))
        ]
        toolbar.items?.last?.accessibilityIdentifier = "keyboardDone"
        return toolbar
    }
}

@MainActor
final class ToolbarTarget: NSObject {
    static let shared = ToolbarTarget()
    private weak var editingView: UIView?

    @objc func didBeginEditing(_ notification: Notification) {
        guard let view = notification.object as? UIView else { return }
        editingView = view
        // Дочекатися налаштування поля SwiftUI, потім встановити саму панель.
        DispatchQueue.main.async { [weak view] in
            guard let view, view.isFirstResponder else { return }
            if let field = view as? UITextField {
                field.inputAccessoryView = KeyboardToolbar.makeToolbar()
            } else if let textView = view as? UITextView {
                textView.inputAccessoryView = KeyboardToolbar.makeToolbar()
            }
            view.reloadInputViews()
        }
    }

    @objc func dismissKeyboard() {
        // Спочатку очистити SwiftUI FocusState, інакше він може повернути фокус.
        NotificationCenter.default.post(name: KeyboardToolbar.dismissRequested, object: nil)
        editingView?.resignFirstResponder()
        editingView?.window?.endEditing(true)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
