import Flow
import Form
import Foundation
import UIKit
import hCore

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
    let textColor: UIColor
    let backgroundColor: UIColor
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
        textColor: UIColor = .brand(.primaryText()),
        backgroundColor: UIColor = UIColor.brand(.secondaryBackground()),
        duration: TimeInterval = 3.0
    ) {
        self.symbol = symbol
        self.body = body
        self.subtitle = subtitle
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.duration = duration
    }
}

extension Toast: Viewable {
    var symbolView: UIView {
        switch symbol {
        case let .character(character):
            let view = UILabel(value: String(character), style: .brand(.headline(color: .primary)))
            view.minimumScaleFactor = 0.5
            view.adjustsFontSizeToFitWidth = true
            return view
        case let .icon(icon):
            let view = UIImageView()
            view.image = icon
            view.tintColor = textColor
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
        bag += containerView.applyShadow { trait in
            UIView.ShadowProperties(
                opacity: trait.userInterfaceStyle == .dark ? 0 : 0.25,
                offset: CGSize(width: 0, height: 0),
                blurRadius: 3,
                color: UIColor.darkGray,
                path: nil,
                radius: 10
            )
        }

        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 15)
        stackView.spacing = 12.5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false

        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
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
            style: TextStyle.brand(.headline(color: .primary)).colored(textColor)
        )
        textContainer.addArrangedSubview(bodyLabel)

        if let subtitle = subtitle {
            let bodySubtitleLabel = UILabel(
                value: subtitle,
                style: TextStyle.brand(.subHeadline(color: .secondary)).colored(textColor)
            )
            textContainer.addArrangedSubview(bodySubtitleLabel)
        }

        stackView.addArrangedSubview(textContainer)

        let chevronImageView = UIImageView()
        chevronImageView.tintColor = textColor
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.isHidden = true
        chevronImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        chevronImageView.image = hCoreUIAssets.chevronRight.image

        stackView.addArrangedSubview(chevronImageView)

        bag += stackView.didMoveToWindowSignal.onValue {
            if !self.onTapCallbacker.isEmpty {
                chevronImageView.isHidden = false
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

extension Toasts: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = PassThroughView()

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

        containerView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }

        self.bag += containerView.subviewsSignal.onValue { subviews in
            containerView.isHidden = subviews.isEmpty

            containerView.snp.updateConstraints { make in
                make.height.equalTo(
                    subviews.max { (lhs, rhs) -> Bool in
                        if lhs.frame.height > rhs.frame.height {
                            return true
                        }

                        return false
                    }?
                    .frame.height ?? 0
                )
            }
        }

        bag +=
            toastCallbacker
            .compactMap { $0 }
            .wait(until: pauseSignal.distinct().map { !$0 })
            .distinct()
            .onValueDisposePrevious { toast in
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
