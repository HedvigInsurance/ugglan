import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import hCore

func setGrabber(on presentationController: UIPresentationController, to value: Bool) {
    let grabberKey = ["_", "setWants", "Grabber:"]

    let selector = NSSelectorFromString(grabberKey.joined())

    if #available(iOS 16.0, *) {
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.prefersGrabberVisible = value
        } else if presentationController.responds(to: selector) {
            if value {
                presentationController.perform(selector, with: value)
            } else {
                presentationController.perform(selector, with: nil)
            }
        }
    } else if presentationController.responds(to: selector) {
        if value {
            presentationController.perform(selector, with: value)
        } else {
            presentationController.perform(selector, with: nil)
        }
    }
}

var detentIndexKey = ["_", "indexOf", "CurrentDetent"].joined()

func getDetentIndex(on presentationController: UIPresentationController) -> Int {
    presentationController.value(forKey: detentIndexKey) as? Int ?? 0
}

func setDetentIndex(on presentationController: UIPresentationController, index: Int) {
    let key = ["_set", "IndexOf", "CurrentDetent:"]

    typealias SetIndexMethod = @convention(c) (UIPresentationController, Selector, Int) -> Void
    let selector = NSSelectorFromString(key.joined())
    let method = presentationController.method(for: selector)
    let castedMethod = unsafeBitCast(method, to: SetIndexMethod.self)

    castedMethod(presentationController, selector, index)
}

func setWantsBottomAttachedInCompactHeight(on presentationController: UIPresentationController, to value: Bool) {
    let key = ["_", "setWants", "BottomAttachedInCompactHeight:"]

    let selector = NSSelectorFromString(key.joined())

    if presentationController.responds(to: selector) {
        if value {
            presentationController.perform(selector, with: value)
        } else {
            presentationController.perform(selector, with: nil)
        }
    }
}

extension Notification {
    fileprivate var endFrame: CGRect? {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
}

class DetentedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var detents: [PresentationStyle.Detent]
    var options: PresentationOptions
    var wantsGrabber: Bool
    var viewController: UIViewController
    let bag = DisposeBag()
    var keyboardFrame: CGRect = .zero

    func listenToKeyboardFrame() {
        bag += viewController.view.keyboardSignal(priority: .highest)
            .onValue { [weak self] event in guard let self = self else { return }
                switch event {
                case let .willShow(frame, _): self.keyboardFrame = frame
                case .willHide: self.keyboardFrame = .zero
                }

                guard let navigationController = self.viewController.navigationController else {
                    return
                }

                guard
                    ![
                        .changed,
                        .began,
                        .cancelled,
                    ]
                    .contains(navigationController.interactivePopGestureRecognizer?.state)
                else {
                    return
                }

                if var topController = navigationController.view.window?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }

                    if topController == navigationController {
                        if let presentationController = navigationController
                            .presentationController,
                            let lastViewController = navigationController
                                .visibleViewController
                        {
                            PresentationStyle.Detent.set(
                                lastViewController.appliedDetents,
                                on: presentationController,
                                viewController: lastViewController,
                                keyboardAnimation: event.animation,
                                unanimated: false
                            )
                        }
                    }
                }

            }
    }

    init(
        detents: [PresentationStyle.Detent],
        options: PresentationOptions,
        wantsGrabber: Bool,
        viewController: UIViewController
    ) {
        self.detents = detents
        self.options = options
        self.wantsGrabber = wantsGrabber
        self.viewController = viewController
        super.init()
        listenToKeyboardFrame()
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source _: UIViewController
    ) -> UIPresentationController? {

        let presentationController: UIPresentationController = {
            if #available(iOS 16.0, *) {
                let presentationController = BlurredSheetPresenationController(
                    presentedViewController: presented,
                    presenting: presenting,
                    useBlur: options.contains(.blurredBackground)
                )
                presentationController.preferredCornerRadius = 16
                return presentationController
            } else {
                let key = ["_", "U", "I", "Sheet", "Presentation", "Controller"]
                let sheetPresentationController = NSClassFromString(key.joined()) as! UIPresentationController.Type
                let presentationController = sheetPresentationController.init(
                    presentedViewController: presented,
                    presenting: presenting
                )
                return presentationController
            }
        }()

        if #available(iOS 16.0, *) {
            if let presentationController = presentationController as? BlurredSheetPresenationController {
                presentationController.detents = [
                    .custom(resolver: { context in
                        return -50
                    })
                ]
            }
        }

        if options.contains(.unanimated) {
            PresentationStyle.Detent.set(
                [
                    .custom(
                        "zero",
                        { viewController, containerView in
                            return -50
                        }
                    )
                ],
                on: presentationController,
                viewController: viewController,
                unanimated: true
            )

            Signal(after: 0.001).future
                .onValue { [weak presentationController] _ in
                    guard let presentationController = presentationController else { return }
                    PresentationStyle.Detent.set(
                        self.detents,
                        on: presentationController,
                        viewController: self.viewController,
                        unanimated: true
                    )
                }
        } else {
            PresentationStyle.Detent.set(
                [
                    .custom(
                        "zero",
                        { viewController, containerView in
                            return -50
                        }
                    )
                ],
                on: presentationController,
                viewController: viewController,
                unanimated: false
            )

            Signal(after: 0.05).future
                .onValue { [weak presentationController] _ in
                    guard let presentationController = presentationController else { return }
                    PresentationStyle.Detent.set(
                        self.detents,
                        on: presentationController,
                        viewController: self.viewController,
                        unanimated: false
                    )
                }
        }

        setGrabber(on: presentationController, to: wantsGrabber)

        return presentationController
    }
}

extension PresentationOptions {
    // adds a grabber to DetentedModals
    public static let wantsGrabber = PresentationOptions()
    public static let blurredBackground = PresentationOptions()
    public static let preffersLargerNavigationBar = PresentationOptions()
    public static let withAdditionalSpaceForProgressBar = PresentationOptions()
    public static let largeNavigationBar: PresentationOptions = [
        embedInNavigationController, .preffersLargerNavigationBar, .wantsGrabber,
    ]
    public static let largeNavigationBarWithoutGrabber: PresentationOptions = [
        embedInNavigationController, .preffersLargerNavigationBar,
    ]
}

extension UIViewController {
    private static var _appliedDetents: UInt8 = 1

    public var appliedDetents: [PresentationStyle.Detent] {
        get {
            if let appliedDetents = objc_getAssociatedObject(self, &UIViewController._appliedDetents)
                as? [PresentationStyle.Detent]
            {
                return appliedDetents
            }

            return []
        }
        set {
            objc_setAssociatedObject(
                self,
                &UIViewController._appliedDetents,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public var currentDetent: PresentationStyle.Detent? {
        get {
            guard let presentationController = navigationController?.presentationController else {
                return nil
            }

            let index = getDetentIndex(on: presentationController)

            if appliedDetents.indices.contains(index) { return appliedDetents[index] }

            return nil
        }
        set {
            guard let presentationController = navigationController?.presentationController,
                let newValue = newValue, let index = appliedDetents.firstIndex(of: newValue)
            else { return }
            weak var presentationControllerWeak = presentationController
            func apply() {
                if let presentationControllerWeak {
                    setDetentIndex(on: presentationControllerWeak, index: index)
                }
            }

            if let sheetPresentationController = presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    apply()
                }
            } else {
                apply()

                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 5,
                    initialSpringVelocity: 1,
                    options: .allowUserInteraction,
                    animations: {
                        presentationController.containerView?.layoutSuperviewsIfNeeded()
                    },
                    completion: nil
                )
            }
        }
    }

    public var currentDetentSignal: ReadWriteSignal<PresentationStyle.Detent?> {
        Signal { [weak self] callback in guard let self = self else { return NilDisposer() }
            let bag = DisposeBag()

            bag += (self.view as? UIScrollView)?.panGestureRecognizer
                .onValue { _ in
                    callback(self.currentDetent)
                }
            bag += self.view.didLayoutSignal.onValue({ _ in
                callback(self.currentDetent)
            })

            bag += self.view.didLayoutSignal
                .map({ _ in
                    self.currentDetent
                })
                .distinct()
                .onValue({ _ in
                    if let scrollView = self.view as? UIScrollView {
                        let desiredOffset = CGPoint(x: 0, y: -scrollView.adjustedContentInset.top)
                        scrollView.setContentOffset(desiredOffset, animated: true)
                    }
                })

            return bag
        }
        .distinct()
        .readable { [weak self] in
            self?.currentDetent
        }
        .writable { [weak self] detent in
            self?.currentDetent = detent
        }
    }

    private static var _lastDetentIndex: UInt8 = 1

    internal var lastDetentIndex: Int? {
        get {
            if let lastDetentIndex = objc_getAssociatedObject(self, &UIViewController._lastDetentIndex)
                as? Int
            {
                return lastDetentIndex
            }

            return nil
        }
        set {
            objc_setAssociatedObject(
                self,
                &UIViewController._lastDetentIndex,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension PresentationStyle {
    public enum Detent: Equatable {
        public static func == (lhs: PresentationStyle.Detent, rhs: PresentationStyle.Detent) -> Bool {
            switch (lhs, rhs) {
            case (.large, .large): return true
            case (.medium, .medium): return true
            case let (.custom(lhsName, _), .custom(rhsName, _)): return lhsName == rhsName
            default: return false
            }
        }

        case medium, large
        case custom(
            _ name: String,
            _ containerViewBlock: (_ viewController: UIViewController, _ containerView: UIView) -> CGFloat
        )

        public static var scrollViewContentSize: Detent {
            .custom("scrollViewContentSize") { viewController, containerView in
                let allScrollViewDescendants = viewController.view.allDescendants(ofType: UIScrollView.self)

                guard
                    let scrollView = allScrollViewDescendants.first(where: { _ in
                        true
                    })
                else {
                    return 0
                }

                let transitioningDelegate =
                    viewController.navigationController?.transitioningDelegate
                    as? DetentedTransitioningDelegate
                let keyboardHeight = transitioningDelegate?.keyboardFrame.height ?? 0

                let largeTitleDisplayMode = viewController.navigationItem.largeTitleDisplayMode

                let hasLargeTitle =
                    (viewController.navigationController?.navigationBar.prefersLargeTitles ?? false)
                    && (largeTitleDisplayMode == .automatic || largeTitleDisplayMode == .always)

                let hasNavigationBar =
                    viewController.navigationController?.navigationBar != nil
                    && (viewController.navigationController?.isNavigationBarHidden ?? true) == false

                let navigationBarDynamicHeight = viewController.navigationController?.navigationBar.frame.height

                let navigationBarHeight: CGFloat = hasLargeTitle ? 107 : navigationBarDynamicHeight ?? 52

                let additionalNavigationSafeAreaInsets =
                    viewController.navigationController?.additionalSafeAreaInsets ?? UIEdgeInsets()
                let additionalNavigationHeight =
                    additionalNavigationSafeAreaInsets.top + additionalNavigationSafeAreaInsets.bottom

                let additionalViewHeight =
                    viewController.additionalSafeAreaInsets.top + viewController.additionalSafeAreaInsets.bottom
                var totalHeight: CGFloat =
                    scrollView.contentSize.height
                    + (hasNavigationBar ? navigationBarHeight : 0)
                    + additionalNavigationHeight
                    + additionalViewHeight
                if keyboardHeight > 0 {
                    if let window = UIApplication.shared.windows.first {
                        let bottomPadding = window.safeAreaInsets.bottom
                        totalHeight -= bottomPadding
                    }
                }
                return totalHeight
            }
        }

        public static var preferredContentSize: Detent {
            .custom("preferredContentSize") { viewController, _ in
                viewController.preferredContentSize.height
            }
        }

        static func set(
            _ detents: [Detent],
            on presentationController: UIPresentationController,
            viewController: UIViewController,
            lastDetentIndex: Int? = nil,
            keyboardAnimation: KeyboardAnimation? = nil,
            unanimated: Bool
        ) {
            guard !detents.isEmpty else { return }
            weak var weakViewController = viewController
            weak var weakPresentationController = presentationController
            func apply() {
                if #available(iOS 16.0, *) {
                    weakViewController?.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
                    weakViewController?.appliedDetents = detents
                    weakViewController?.sheetPresentationController?.detents =
                        weakViewController?.appliedDetents
                        .map({
                            switch $0 {
                            case .large:
                                return .large()
                            case .medium:
                                return .medium()
                            case let .custom(name, block):
                                return UISheetPresentationController.Detent.custom(
                                    identifier: UISheetPresentationController.Detent.Identifier.init(name)
                                ) { context in
                                    if let weakViewController {
                                        return block(weakViewController, weakViewController.view)
                                    }
                                    return 0
                                }
                            }
                        }) ?? [.medium()]
                    if let lastDetentIndex = lastDetentIndex {
                        setDetentIndex(on: presentationController, index: lastDetentIndex)
                    }
                } else {
                    let key = ["_", "set", "Detents", ":"]
                    let selector = NSSelectorFromString(key.joined())
                    weakViewController?.appliedDetents = detents
                    if let weakViewController {
                        weakPresentationController?
                            .perform(
                                selector,
                                with: NSArray(array: detents.map { $0.getDetent(weakViewController) })
                            )

                    }
                    if let weakPresentationController {
                        setWantsBottomAttachedInCompactHeight(on: weakPresentationController, to: true)
                    }

                    if let lastDetentIndex = lastDetentIndex, let weakPresentationController {
                        setDetentIndex(on: weakPresentationController, index: lastDetentIndex)
                    }
                }
            }
            if unanimated {
                apply()
            } else if let sheetPresentationController = presentationController as? UISheetPresentationController {
                sheetPresentationController.animateChanges {
                    apply()
                }
            }
        }

        var rawValue: String {
            switch self {
            case .large: return "large"
            case .medium: return "medium"
            case .custom: return "custom"
            }
        }

        func getDetent(_ presentedViewController: UIViewController) -> NSObject {
            let key = ["_", "U", "I", "S", "h", "e", "e", "t", "D", "e", "t", "e", "n", "t"]

            let DetentsClass = NSClassFromString(key.joined()) as! NSObject.Type

            switch self {
            case .large, .medium: return DetentsClass.value(forKey: "_\(rawValue)Detent") as! NSObject
            case let .custom(_, containerViewBlock):
                typealias ContainerViewBlockMethod = @convention(c) (
                    NSObject.Type, Selector, @escaping (_ containerView: UIView) -> Double
                ) -> NSObject
                let customKey = ["_detent", "WithContainerViewBlock", ":"]
                let selector = NSSelectorFromString(customKey.joined())
                let method = DetentsClass.method(for: selector)
                let castedMethod = unsafeBitCast(method, to: ContainerViewBlockMethod.self)

                return castedMethod(DetentsClass, selector) { view in
                    Double(containerViewBlock(presentedViewController, view))
                }
            }
        }
    }

    private static func presentDetentedHandler(
        _ viewController: UIViewController,
        _ from: UIViewController,
        _ options: PresentationOptions,
        detents: [Detent],
        modally: Bool,
        bgColor: UIColor?
    ) -> PresentingViewController.Result {
        viewController.setLargeTitleDisplayMode(options)

        if modally {
            let vc = viewController.embededInNavigationController(options)

            let bag = DisposeBag()

            let delegate = DetentedTransitioningDelegate(
                detents: detents,
                options: options,
                wantsGrabber: options.contains(.wantsGrabber),
                viewController: viewController
            )
            bag.hold(delegate)
            vc.transitioningDelegate = delegate
            vc.modalPresentationStyle = .custom
            vc.view.backgroundColor = bgColor
            return from.modallyPresentQueued(vc, options: options) {
                return Future { completion in
                    let dismissal =
                        PresentationStyle.modalPresentationDismissalSetup(
                            for: vc,
                            options: options
                        )
                        .onResult(completion)
                    return Disposer {
                        bag.dispose()
                        dismissal.cancel()
                    }
                }
            }
        } else {
            let bag = DisposeBag()

            if let navigationController = from.navigationController,
                let presentationController = navigationController.presentationController
            {
                from.lastDetentIndex = getDetentIndex(on: presentationController)

                bag += navigationController
                    .willShowViewControllerSignal
                    .filter {
                        $0.viewController == viewController
                    }
                    .onFirstValue { _ in
                        DispatchQueue.main.async {
                            Self.Detent.set(
                                detents,
                                on: presentationController,
                                viewController: viewController,
                                unanimated: options.contains(.unanimated)
                            )
                            setGrabber(
                                on: presentationController,
                                to: options.contains(.wantsGrabber)
                            )
                        }
                    }

                bag += navigationController.willPopViewControllerSignal
                    .wait(
                        until: navigationController
                            .interactivePopGestureRecognizer?
                            .map {
                                $0 == .possible || $0 == .ended || $0 == .failed
                            }
                            ?? ReadSignal(true)
                    )
                    .filter(predicate: { $0 == viewController })
                    .onValue { _ in
                        guard
                            let previousViewController =
                                navigationController.viewControllers
                                .last
                        else { return }

                        func handleDismiss() {
                            Self.Detent.set(
                                previousViewController.appliedDetents,
                                on: presentationController,
                                viewController: previousViewController,
                                lastDetentIndex: previousViewController
                                    .lastDetentIndex,
                                unanimated: options.contains(.unanimated)
                            )
                        }

                        if navigationController.interactivePopGestureRecognizer?
                            .state == .ended,
                            !(navigationController.transitionCoordinator?
                                .isCancelled ?? false)
                        {
                            handleDismiss()
                        } else if navigationController
                            .interactivePopGestureRecognizer?
                            .state == .possible
                        {
                            handleDismiss()
                        }
                    }
            }

            let defaultPresentation = PresentationStyle.default.present(
                viewController,
                from: from,
                options: options
            )

            return (
                defaultPresentation.result,
                {
                    bag.dispose()
                    return defaultPresentation.dismisser()
                }
            )
        }
    }

    public static func detented(
        _ detents: Detent...,
        modally: Bool = true,
        bgColor: UIColor? = .brand(.primaryBackground())
    ) -> PresentationStyle {
        PresentationStyle(
            name: "detented",
            present: { viewController, from, options in
                return presentDetentedHandler(
                    viewController,
                    from,
                    options,
                    detents: detents,
                    modally: modally,
                    bgColor: bgColor
                )
            }
        )
    }
}

@available(iOS 16.0, *)
class BlurredSheetPresenationController: UISheetPresentationController {

    var effectView: PassThroughEffectView?

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        useBlur: Bool
    ) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        effectView = useBlur ? PassThroughEffectView(effect: UIBlurEffect(style: getBlurEffectStyle)) : nil
        effectView?.clipsToBounds = true
        self.presentedViewController.view.layer.cornerRadius = 16
        self.presentedViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        self.detents = [
            .custom(resolver: { context in
                return 0
            })
        ]
    }

    var getBlurEffectStyle: UIBlurEffect.Style {
        if self.traitCollection.userInterfaceStyle == .dark {
            return .light
        } else {
            return .regular
        }
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        if let effectView {
            containerView?.addSubview(effectView)
            effectView.snp.makeConstraints { make in
                make.top.leading.bottom.trailing.equalToSuperview()
            }
            effectView.alpha = 0
        }
        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { [weak self] _ in
                guard let self = self else { return }
                self.effectView?.alpha = 1
            })
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { [weak self] context in
                guard let self = self else { return }
                self.effectView?.alpha = 0
            })
    }
}

public class PassThroughEffectView: UIVisualEffectView {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        }

        return hitView
    }
}
