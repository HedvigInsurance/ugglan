import Combine
import Form
import Foundation
import SwiftUI
import hCore

public struct ToastBar {
    let type: NotificationType
    let icon: UIImage?
    let text: String
    let action: ToastBarAction?
    let duration: Double

    public init(
        type: NotificationType,
        icon: UIImage? = nil,
        text: String,
        action: ToastBarAction? = nil,
        duration: Double = 3
    ) {
        self.type = type
        self.icon = icon
        self.text = text
        self.action = action
        self.duration = duration
    }

    public struct ToastBarAction {
        let actionText: String
        let onClick: () -> Void

        public init(
            actionText: String,
            onClick: @escaping () -> Void
        ) {
            self.actionText = actionText
            self.onClick = onClick
        }
    }
}

public struct ToastBarView: View {
    private let toastModel: ToastBar

    public init(
        toastModel: ToastBar
    ) {
        self.toastModel = toastModel
    }

    public var body: some View {
        hSection {
            HStack(spacing: 8) {
                Image(uiImage: toastModel.icon ?? toastModel.type.image)
                    .resizable()
                    .foregroundColor(iconColor)
                    .frame(width: 20, height: 20)
                hText(toastModel.text, style: .label)
                    .foregroundColor(toastModel.type.textColor)

                if let action = toastModel.action {
                    Spacer()
                    if #available(iOS 16.0, *) {
                        hText(action.actionText, style: .label)
                            .underline()
                            .foregroundColor(toastModel.type.textColor)
                    } else {
                        hText(action.actionText, style: .label)
                            .foregroundColor(toastModel.type.textColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.padding16)
            .modifier(NotificationStyle(type: toastModel.type))
        }
        .sectionContainerStyle(.transparent)
    }

    @hColorBuilder
    private var iconColor: some hColor {
        if toastModel.icon != nil {
            hSignalColor.Green.element
        } else {
            toastModel.type.imageColor
        }
    }
}

#Preview{
    VStack {
        hSection {
            ToastBarView(
                toastModel: .init(
                    type: .attention,
                    text: "testing toast bar"
                )
            )
        }
        hSection {
            ToastBarView(
                toastModel: .init(
                    type: .info,
                    text: "testing toast bar action",
                    action: .init(actionText: "action", onClick: {})
                )
            )
        }
        hSection {
            ToastBarView(
                toastModel: .init(
                    type: .neutral,
                    text: "disabled toast bar"
                )
            )
        }
    }
}

public class Toasts {
    public static let shared = Toasts()
    var list = [ToastBar]()
    public func displayToastBar(toast: ToastBar) {
        list.append(toast)
        if list.count == 1 {
            showNext()
        }
    }

    init() {

    }

    private func showNext() {
        if let toast = list.first {
            let viewToShow = ToastUIView(model: toast) { [weak self] in
                self?.list.removeFirst()
                self?.showNext()
            }
            if let viewToShowFrom = UIApplication.shared.getRootViewController()?.view {
                viewToShowFrom.addSubview(viewToShow)
                viewToShow.snp.makeConstraints { make in
                    make.leading.top.trailing.equalToSuperview()
                }
            }
        }
    }

}

private class ToastUIView: UIView {
    private let onDeinit: () -> Void
    private let model: ToastBar
    private var timerSubscription: Cancellable?
    private var offsetForPanGesture: CGFloat = 0
    init(model: ToastBar, onDeinit: @escaping () -> Void) {
        let toastBarView = ToastBarView(toastModel: model)
        let vc = hHostingController(rootView: toastBarView, contentName: "")
        self.model = model
        self.onDeinit = onDeinit
        super.init(frame: .zero)
        self.addSubview(vc.view)
        setAutoDismiss()
        self.transform = .init(translationX: 0, y: -200)
        self.backgroundColor = .clear
        UIView.animate(withDuration: 1) { [weak self] in
            self?.transform = .identity
        }
        vc.view.backgroundColor = .clear
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let drag = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(drag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        disableAutoDismiss()
        var ended = false
        switch sender.state {
        case .began:
            offsetForPanGesture = 0
        case .possible:
            break
        case .changed:
            offsetForPanGesture = sender.translation(in: self).y
        case .ended:
            let velocity = sender.velocity(in: self).y
            // dismiss if swiped with negative velocity or ended in position thats should dismiss toast
            if velocity < 0 || (self.frame.height / 2 < -(offsetForPanGesture) && offsetForPanGesture < 0) {
                dismiss()
                return
            } else {
                ended = true
                offsetForPanGesture = 0
            }
            setAutoDismiss()
        case .cancelled:
            offsetForPanGesture = 0
            setAutoDismiss()
        case .failed:
            offsetForPanGesture = 0
            setAutoDismiss()
        case .recognized:
            offsetForPanGesture = 0
        @unknown default:
            break
        }

        //do slower animation if ended
        let duration: TimeInterval = {
            if ended {
                return 0.5
            }
            return 0.1
        }()
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 1) {
            [weak self] in
            if self?.offsetForPanGesture ?? 0 > 0 {
                let maxOffsetToAnimate: CGFloat = 200
                let offset = min(maxOffsetToAnimate, self?.offsetForPanGesture ?? 0)
                let scale = (offset / maxOffsetToAnimate) * 0.1
                self?.transform = .init(translationX: 0, y: 0).scaledBy(x: 1 + scale / 4, y: 1 + scale)
            } else {
                self?.transform = .init(translationX: 0, y: self?.offsetForPanGesture ?? 0)
            }

        }
    }

    private func disableAutoDismiss() {
        timerSubscription = nil
    }

    private func setAutoDismiss() {
        let runLoop = RunLoop.main
        timerSubscription = runLoop.schedule(
            after: runLoop.now.advanced(by: .seconds(model.duration)),
            interval: .seconds(6),
            tolerance: .milliseconds(100),
            options: nil
        ) { [weak self] in
            self?.dismiss()
        }
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.transform = .init(translationX: 0, y: -200)
        } completion: { [weak self] _ in
            self?.removeFromSuperview()
        }
    }

    deinit {
        onDeinit()
    }
}

#Preview{
    VStack {
        Button(
            action: {
                let model = ToastBar(type: .attention, text: "TEST")
                Toasts.shared.displayToastBar(toast: model)
            },
            label: {
                Text("Button")
            }
        )
    }
}
