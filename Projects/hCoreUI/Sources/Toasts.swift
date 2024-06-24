import Combine
import Flow
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
                hText(toastModel.text, style: .footnote)
                    .foregroundColor(toastModel.type.textColor)

                if let action = toastModel.action {
                    Spacer()
                    if #available(iOS 16.0, *) {
                        hText(action.actionText, style: .footnote)
                            .underline()
                            .foregroundColor(toastModel.type.textColor)
                    } else {
                        hText(action.actionText, style: .footnote)
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
                    type: .disabled,
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
            let viewToShowFrom = UIApplication.shared.getRootViewController()!.view!
            viewToShowFrom.addSubview(viewToShow)
            viewToShow.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
            }
        }
    }

}

private class ToastUIView: UIView {
    private let vc: hHostingController<ToastBarView>
    private let onDeinit: () -> Void
    private let model: ToastBar
    private var timerSubscription: AnyCancellable?

    init(model: ToastBar, onDeinit: @escaping () -> Void) {
        let toastBarView = ToastBarView(toastModel: model)
        vc = hHostingController(rootView: toastBarView, contentName: "")
        self.model = model
        self.onDeinit = onDeinit
        super.init(frame: .zero)
        self.addSubview(vc.view)
        setAutoDismiss()
        self.transform = .init(translationX: 0, y: -200)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.transform = .identity
        }
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let drag = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        vc.view?.addGestureRecognizer(drag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        setAutoDismiss()
    }

    private func setAutoDismiss() {
        timerSubscription = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                UIView.animate(withDuration: 1) {
                    self?.transform = .init(translationX: 0, y: -200)
                } completion: { _ in
                    self?.removeFromSuperview()
                }
            }
    }

    deinit {
        onDeinit()
    }
}
