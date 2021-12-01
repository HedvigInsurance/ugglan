import Flow
import Foundation
import SwiftUI

class _PasteView: UIView {
    var onPaste: () -> Void

    init(
        onPaste: @escaping () -> Void
    ) {
        self.onPaste = onPaste
        super.init(frame: .zero)
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(paste(_:)):
            return true
        default:
            return false
        }
    }

    override func paste(_ sender: Any?) {
        onPaste()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}

public struct PasteView: UIViewRepresentable {
    var onPaste: () -> Void

    public init(
        onPaste: @escaping () -> Void
    ) {
        self.onPaste = onPaste
    }

    public class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let bag = DisposeBag()

        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> some UIView {
        let view = _PasteView(onPaste: onPaste)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.delegate = context.coordinator
        context.coordinator.bag += view.install(longPressGesture)

        context.coordinator.bag += longPressGesture.signal(forState: .began)
            .onValue { _ in
                let menu = UIMenuController.shared
                guard !menu.isMenuVisible else { return }
                view.becomeFirstResponder()
                menu.showMenu(from: view, rect: view.bounds)
            }

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}
