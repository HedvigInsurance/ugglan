import Combine
import Foundation
import SwiftUI

class _PasteView: UIView {
    var onPaste: () -> Void
    private lazy var editMenuInteraction = UIEditMenuInteraction(delegate: self)

    init(
        onPaste: @escaping () -> Void
    ) {
        self.onPaste = onPaste
        super.init(frame: .zero)
        addInteraction(editMenuInteraction)
    }

    @available(*, unavailable)
    required init?(
        coder _: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        switch action {
        case #selector(paste(_:)):
            return true
        default:
            return false
        }
    }

    override func paste(_: Any?) {
        onPaste()
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    func presentEditMenu() {
        let configuration = UIEditMenuConfiguration(
            identifier: nil,
            sourcePoint: CGPoint(x: bounds.midX, y: bounds.midY)
        )
        editMenuInteraction.presentEditMenu(with: configuration)
    }
}

extension _PasteView: @preconcurrency UIEditMenuInteractionDelegate {
    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        targetRectFor configuration: UIEditMenuConfiguration
    ) -> CGRect {
        bounds
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
        public var cancellables = Set<AnyCancellable>()
        let longPressGesture = UILongPressGestureRecognizer()

        override init() {
            super.init()
            longPressGesture.delegate = self
            longPressGesture.addTarget(self, action: #selector(longGesture(_:)))
        }

        public var longGestureDidBeginPublisher: AnyPublisher<Bool, Never> {
            longGestureDidBegin.eraseToAnyPublisher()
        }

        private let longGestureDidBegin = PassthroughSubject<Bool, Never>()
        public func gestureRecognizer(
            _: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
        ) -> Bool {
            true
        }

        @objc func longGesture(_ sender: UILongPressGestureRecognizer) {
            if sender.state == UIGestureRecognizer.State.began {
                longGestureDidBegin.send(true)
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> some UIView {
        let view = _PasteView(onPaste: onPaste)
        view.addGestureRecognizer(context.coordinator.longPressGesture)
        context.coordinator.longGestureDidBeginPublisher
            .sink { _ in
                view.becomeFirstResponder()
                view.presentEditMenu()
            }
            .store(in: &context.coordinator.cancellables)
        return view
    }

    public func updateUIView(_: UIViewType, context _: Context) {}
}
