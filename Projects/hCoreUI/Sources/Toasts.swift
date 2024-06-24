import Combine
import Flow
import Form
import Foundation
import SwiftUI
import hCore

public struct ToastBar {
    let type: NotificationType
    let text: String
    let action: ToastBarAction?
    let duration: Double

    public init(
        type: NotificationType,
        text: String,
        action: ToastBarAction? = nil,
        duration: Double = 3
    ) {
        self.type = type
        self.text = text
        self.action = action
        self.duration = duration
    }

    public struct ToastBarAction {
        let actionText: String
        let onClick: () -> Void
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
        HStack(spacing: 8) {
            Image(uiImage: toastModel.type.image)
                .resizable()
                .foregroundColor(toastModel.type.imageColor)
                .frame(width: 20, height: 20)
            hText(toastModel.text)
                .foregroundColor(toastModel.type.textColor)

            if let action = toastModel.action {
                Spacer()
                if #available(iOS 16.0, *) {
                    hText(action.actionText)
                        .underline()
                        .foregroundColor(toastModel.type.textColor)
                } else {
                    hText(action.actionText)
                        .foregroundColor(toastModel.type.textColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.padding16)
        .modifier(NotificationStyle(type: toastModel.type))
    }

    public struct ToastBarAction {
        let actionText: String
        let onClick: () -> Void
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

public enum ToastSymbol: Equatable {
    public static func == (lhs: ToastSymbol, rhs: ToastSymbol) -> Bool {
        switch (lhs, rhs) {
        case let (.character(lhsCharacter), .character(rhsCharacter)):
            return lhsCharacter == rhsCharacter
        case let (.icon(lhsIcon), .icon(rhsIcon)):
            return lhsIcon == rhsIcon
        default:
            return false
        }
    }

    case character(_ character: Character)
    case icon(_ icon: UIImage)
}

public struct Toast: Equatable {
    public static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }

    private let id = UUID()
    let symbol: ToastSymbol?
    let body: String
    let subtitle: String?
    let infoText: String?
    let textColor: UIColor
    let backgroundColor: UIColor
    let symbolColor: UIColor
    let borderColor: UIColor
    let duration: TimeInterval
    public var onTap: Signal<Void> {
        onTapCallbacker.providedSignal
    }

    private let onTapCallbacker = Callbacker<Void>()
    let shouldHideCallbacker = Callbacker<Void>()

    public init(
        symbol: ToastSymbol?,
        body: String,
        subtitle: String? = nil,
        infoText: String? = nil,
        textColor: UIColor = .brand(.toasterTitle),
        backgroundColor: UIColor = UIColor.brand(.toasterBackground),
        borderColor: UIColor = UIColor.brand(.toasterBorder),
        symbolColor: UIColor = UIColor(dynamic: { trait -> UIColor in
            UIColor(
                hSignalColor.Green.element.colorFor(trait.userInterfaceStyle == .dark ? .dark : .light, .base)
                    .color
            )
        }),
        duration: TimeInterval = 3.0
    ) {
        self.symbol = symbol
        self.body = body
        self.subtitle = subtitle
        self.infoText = infoText
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.symbolColor = symbolColor
        self.duration = duration
    }
}

extension Toast: Viewable {
    var symbolView: UIView {
        switch symbol {
        case let .character(character):
            let view = UILabel(value: String(character), style: UIColor.brandStyle(.primaryText()))
            view.minimumScaleFactor = 0.5
            view.adjustsFontSizeToFitWidth = true
            return view
        case let .icon(icon):
            let view = UIImageView()
            view.image = icon
            view.tintColor = symbolColor
            view.contentMode = .scaleAspectFit

            view.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            return view
        case .none:
            return UIView()
        }
    }

    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let wrapperView = UIView()

        let containerView = UIControl()
        containerView.layer.cornerRadius = 8
        wrapperView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        bag += containerView.signal(for: .touchUpInside)
            .atValue {
                self.onTapCallbacker.callAll()
                self.shouldHideCallbacker.callAll()
            }

        bag += containerView.signal(for: .touchDown)
            .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                if !self.onTapCallbacker.isEmpty {
                    containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            }

        bag += containerView.delayedTouchCancel(delay: 0.1)
            .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                if !self.onTapCallbacker.isEmpty {
                    containerView.transform = CGAffineTransform.identity
                }
            }

        containerView.backgroundColor = backgroundColor
        containerView.layer.borderColor = borderColor.cgColor
        containerView.layer.borderWidth = 0.5

        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 11, verticalInset: 15.5)
        stackView.spacing = 8.25
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        if symbol != nil {
            let symbolContainer = UIStackView()
            symbolContainer.axis = .horizontal
            symbolContainer.insetsLayoutMarginsFromSafeArea = false

            stackView.addArrangedSubview(symbolContainer)
            symbolContainer.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            symbolContainer.addArrangedSubview(symbolView)
        }

        let textContainer = UIStackView()
        textContainer.axis = .vertical
        textContainer.alignment = .leading
        textContainer.insetsLayoutMarginsFromSafeArea = false
        textContainer.spacing = 5
        let bodyLabel = UILabel(
            value: body,
            style: UIColor.brandStyle(.toasterTitle).colored(textColor)
        )
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.numberOfLines = 0

        textContainer.addArrangedSubview(bodyLabel)

        if let subtitle = subtitle {
            let bodySubtitleLabel = UILabel(
                value: subtitle,
                style: UIColor.brandStyle(.toasterSubtitle).colored(textColor)
            )
            textContainer.addArrangedSubview(bodySubtitleLabel)
        }

        stackView.addArrangedSubview(textContainer)
        if let infoText {
            let bodyLabel = UILabel(
                value: infoText,
                style: UIColor.brandStyle(.toasterTitle).colored(textColor)
            )
            bodyLabel.lineBreakMode = .byWordWrapping
            bodyLabel.numberOfLines = 0
            stackView.addArrangedSubview(UIImageView())
            stackView.addArrangedSubview(bodyLabel)
        } else {
            let chevronImageView = UIImageView()
            chevronImageView.tintColor = textColor
            chevronImageView.contentMode = .scaleAspectFit
            chevronImageView.isHidden = true
            chevronImageView.isUserInteractionEnabled = false
            chevronImageView.snp.makeConstraints { make in
                make.width.equalTo(20)
            }
            chevronImageView.image = hCoreUIAssets.arrowRight.image

            stackView.addArrangedSubview(chevronImageView)

            bag += stackView.didMoveToWindowSignal.onValue {
                if !self.onTapCallbacker.isEmpty {
                    chevronImageView.isHidden = false
                }
            }
        }

        return (wrapperView, bag)
    }
}

public struct Toasts {
    public static let shared = Toasts()

    let bag = DisposeBag()
    let toastCallbacker = Callbacker<Toast>()
    let window = UIApplication.shared.windows.first!
    public func displayToast(toast: Toast) {
        toastCallbacker.callAll(with: toast)
    }

    init() {
        let (view, disposable) = materialize(events: ViewableEvents(wasAddedCallbacker: .init()))
        bag += disposable
        window.rootView.addSubview(view)
    }
}

public class ToastsHandler {
    public static let shared = ToastsHandler()
    //list of toast bar models
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
        let toastBarView = ToastBarView(toastModel: .init(type: .info, text: "Test"))
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

extension Toasts: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()
        let heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        containerView.layer.zPosition = .greatestFiniteMagnitude

        bag += containerView.didMoveToWindowSignal.take(first: 1)
            .onValue {
                containerView.snp.makeConstraints { make in
                    make.top.equalTo(self.window.safeAreaLayoutGuide.snp.top).priority(.medium)
                    make.top.greaterThanOrEqualTo(5).priority(.required)
                    make.width.equalToSuperview().inset(10).priority(.high)
                    make.width.lessThanOrEqualToSuperview().inset(10).priority(.required)
                    make.width.lessThanOrEqualTo(400).priority(.required)
                    make.centerX.equalToSuperview()
                }
            }

        let hideBag = DisposeBag()
        let pauseSignal = ReadWriteSignal<Bool>(false)

        self.bag += containerView.didLayoutSignal.onValue { _ in
            if let parent = containerView.parent {
                parent.bringSubviewToFront(containerView)
            }
        }
        heightConstraint.isActive = true

        bag +=
            toastCallbacker
            .compactMap { $0 }
            .wait(until: pauseSignal.distinct().map { !$0 })
            .distinct()
            .onValueDisposePrevious { toast in
                containerView.layer.zPosition = .greatestFiniteMagnitude
                let innerBag = bag.innerBag()
                pauseSignal.value = true
                hideBag.dispose()

                if let previousToast = containerView.subviews.last {
                    bag += Signal(after: 0)
                        .animated(style: .lightBounce(duration: 1)) {
                            previousToast.transform = previousToast.transform.concatenating(
                                CGAffineTransform(scaleX: 0.5, y: 0.5)
                            )
                        }

                    bag += Signal.animatedDelay(after: 0.5)
                        .animated(style: .lightBounce(duration: 0.25)) {
                            previousToast.alpha = 0
                        }
                        .onValue { _ in
                            previousToast.removeFromSuperview()
                        }
                }

                bag += containerView.add(toast) { toastView in
                    toastView.transform = CGAffineTransform(translationX: 0, y: -125)

                    toastView.snp.makeConstraints { make in
                        make.top.leading.trailing.equalToSuperview()
                    }

                    let panGestureRecognizer = UIPanGestureRecognizer()
                    innerBag += toastView.install(panGestureRecognizer)

                    innerBag += panGestureRecognizer.signal(forState: .began)
                        .onValue {
                            pauseSignal.value = true

                            if toastView.layer.animationKeys() != nil {
                                panGestureRecognizer.state = .cancelled
                            }
                        }

                    innerBag += panGestureRecognizer.signal(forState: .changed)
                        .onValue {
                            let location = panGestureRecognizer.translation(in: toastView)

                            var translationY = min(location.y, 0)

                            if location.y > 0 {
                                translationY += location.y / 100
                            }

                            toastView.transform = CGAffineTransform(
                                translationX: 0,
                                y: translationY
                            )
                        }

                    innerBag += Signal(after: 0).feedback(type: .impactLight)

                    innerBag += Signal(after: 0)
                        .animated(
                            style: SpringAnimationStyle.lightBounce(delay: 0, duration: 1)
                        ) { _ in
                            toastView.transform = CGAffineTransform.identity
                        }
                        .onValue { _ in
                            pauseSignal.value = false
                        }
                    innerBag += toastView.didLayoutSignal.onValue { _ in
                        if toastView.frame.height > 0 {
                            heightConstraint.constant = toastView.frame.height
                        }
                    }
                    let hideCallbacker = Callbacker<Void>()

                    bag +=
                        hideCallbacker.atValue { _ in
                            pauseSignal.value = true
                        }
                        .throttle(1)
                        .filter(predicate: { containerView.subviews.count == 1 })
                        .animated(style: .lightBounce(duration: 1)) { _ in
                            toastView.transform = CGAffineTransform(
                                translationX: 0,
                                y: -125
                            )
                        }
                        .onValue { _ in
                            toastView.removeFromSuperview()
                            heightConstraint.constant = 0
                            innerBag.dispose()
                            pauseSignal.value = false
                        }

                    hideBag += Signal.animatedDelay(after: toast.duration)
                        .onValue { _ in
                            hideCallbacker.callAll()
                        }
                    innerBag += hideBag

                    innerBag += panGestureRecognizer.signal(forState: .ended)
                        .onValue {
                            let location = panGestureRecognizer.translation(in: toastView)
                            let velocity = panGestureRecognizer.velocity(in: toastView)

                            if location.y < -20 || velocity.y > 1300 {
                                hideCallbacker.callAll()
                            } else {
                                innerBag += Signal(after: 0)
                                    .animated(style: .lightBounce()) { _ in
                                        toastView.transform =
                                            CGAffineTransform.identity
                                    }
                                    .onValue { _ in
                                        pauseSignal.value = false
                                    }
                            }
                        }

                    innerBag += toast.shouldHideCallbacker
                        .atValue {
                            pauseSignal.value = true
                        }
                        .delay(by: 0.25)
                        .onValue {
                            hideCallbacker.callAll()
                        }

                    innerBag += pauseSignal.distinct()
                        .onValue { pause in
                            if pause {
                                hideBag.dispose()
                            } else {
                                hideBag += Signal.animatedDelay(after: toast.duration)
                                    .onValue { _ in
                                        hideCallbacker.callAll()
                                    }
                            }
                        }
                }

                return innerBag
            }

        return (containerView, bag)
    }
}
