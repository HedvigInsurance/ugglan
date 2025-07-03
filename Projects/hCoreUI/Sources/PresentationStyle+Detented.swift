import Combine
import Foundation
import SwiftUI
import hCore

@MainActor
func setGrabber(on presentationController: UIPresentationController, to value: Bool) {
    if #available(iOS 17.0, *) {
        let grabberKey = ["_", "setWants", "Grabber:"]
        let selector = NSSelectorFromString(grabberKey.joined())
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.prefersGrabberVisible = value
        } else if presentationController.responds(to: selector) {
            if value {
                presentationController.perform(selector, with: value)
            } else {
                presentationController.perform(selector, with: nil)
            }
        }
    }
}

@MainActor
var detentIndexKey = ["_", "indexOf", "CurrentDetent"].joined()

@MainActor
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

public struct PresentationOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    static let useBlur = PresentationOptions()

}

class DetentTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var detents: [Detent]
    var options: PresentationOptions
    var wantsGrabber: Bool
    var viewController: UIViewController
    var keyboardFrame: CGRect = .zero

    init(
        detents: [Detent],
        options: PresentationOptions,
        wantsGrabber: Bool,
        viewController: UIViewController
    ) {
        self.detents = detents
        self.options = options
        self.wantsGrabber = wantsGrabber
        self.viewController = viewController
        super.init()
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
                    useBlur: options.contains(.useBlur)
                )
                presentationController.preferredCornerRadius = .cornerRadiusXL
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
                        return 0
                    })
                ]
            }
        }

        Detent.set(
            [
                .custom(
                    "zero",
                    { viewController, containerView in
                        return 0
                    }
                )
            ],
            on: presentationController,
            viewController: viewController,
            unanimated: false
        )

        Task { @MainActor [weak presentationController] in
            for _ in 0...2 {
                try? await Task.sleep(nanoseconds: 50_000_000)
                if let presentationController {
                    Detent.set(
                        self.detents,
                        on: presentationController,
                        viewController: self.viewController,
                        unanimated: false
                    )
                }
            }
        }

        setGrabber(on: presentationController, to: wantsGrabber)

        return presentationController
    }
}

class CenteredModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var bottomView: AnyView?

    init(
        bottomView: AnyView? = nil
    ) {
        self.bottomView = bottomView
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return CenteredModalPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            bottomView: bottomView
        )
    }
}

final class CenteredModalPresentationController: UIPresentationController {
    private let blurView: PassThroughEffectView?
    let bottomView: AnyView?
    private var bottomHostingController: UIHostingController<AnyView>?

    private var startDragPosition: CGFloat = 0
    private var dragPercentage: CGFloat = 0
    private var dragOffset: CGFloat = 0
    private var dragState: ModalScaleState = .presentation

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        bottomView: AnyView?
    ) {
        self.bottomView = bottomView
        blurView = PassThroughEffectView(effect: UIBlurEffect(style: .light), options: [.centeredSheet, .gradient])

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        blurView?.alpha = 0

        if let bottomView = bottomView {
            bottomHostingController = UIHostingController(rootView: bottomView)
            bottomHostingController?.view.backgroundColor = .clear
        }
    }

    @objc private func dismissOnTapOutside() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let blurView = blurView else { return }

        containerView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.layoutIfNeeded()
        addGestures()
        if let bottomHostingView = bottomHostingController?.view {
            bottomHostingView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(bottomHostingView)
            bottomHostingView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }

        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { _ in
                blurView.alpha = 1
            })
    }

    private func addGestures() {
        guard let containerView = containerView, let blurView = blurView else { return }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(gesture:)))
        containerView.addGestureRecognizer(panGesture)
        // Dismiss on tap outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOnTapOutside))
        blurView.addGestureRecognizer(tapGesture)
    }

    override func dismissalTransitionWillBegin() {
        guard let blurView = blurView else { return }
        presentedViewController.transitionCoordinator?
            .animate(
                alongsideTransition: { [weak self] _ in
                    blurView.alpha = 0
                    self?.bottomHostingController?.view.removeFromSuperview()
                }
            )
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        blurView?.frame = containerView?.bounds ?? .zero

        guard let presentedView = presentedView
        else { return }
        switch dragState {
        case .presentation:
            presentedView.frame = frameOfPresentedViewInContainerView
        case .interaction:
            presentedView.frame.size = frameOfPresentedViewInContainerView.size
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }

        let width: CGFloat = min(containerView.bounds.width - 40, 400)
        let calculatedHeight = UIViewController.calculateScrollViewContentHeight(for: presentedViewController)

        let height = min(
            calculatedHeight,
            containerView.bounds.height - (bottomHostingController?.view.frame.height ?? .zero) * 2
        )
        let originX = (containerView.bounds.width - width) / 2
        let originY = (containerView.bounds.height - height) / 2

        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    enum ModalScaleState {
        case presentation
        case interaction
    }
}

//drag gesture part
extension CenteredModalPresentationController {
    @objc private func panGestureHandler(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let superView = view.superview,
            let presented = presentedView, let container = containerView
        else { return }

        let location = gesture.translation(in: superView)
        let x = gesture.location(in: containerView).y

        switch gesture.state {
        case .began:
            presented.frame.size.height = container.frame.height
            startDragPosition = gesture.location(in: containerView).y
            dragState = .interaction
        case .changed:
            switch dragState {
            case .interaction:
                var trueOffset = x - startDragPosition

                if trueOffset < 0 {
                    trueOffset = trueOffset / 5
                }
                let percentage = 1 - (trueOffset / view.frame.size.height)
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.9,
                    options: .curveEaseInOut,
                    animations: {
                        presented.transform = CGAffineTransform.init(translationX: 0, y: trueOffset)
                    }
                )
                dragPercentage = percentage
                dragOffset = trueOffset
                blurView?.alpha = percentage
            case .presentation:
                presented.frame.origin.y = location.y
            }
        case .ended:
            if dragOffset <= 100 {
                dragPercentage = 1
                dragOffset = 0
                resetDrag()
            } else {
                presentedViewController.dismiss(animated: true, completion: nil)
                gesture.isEnabled = false
            }
        default:
            resetDrag()
        }
    }

    private func resetDrag() {
        guard let presented = presentedView else { return }
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: { [weak self] in
                presented.transform = CGAffineTransform.identity
                self?.blurView?.alpha = self?.dragPercentage ?? 0
            },
            completion: { [weak self] _ in
                self?.dragState = .presentation
            }
        )
    }
}

extension UIViewController {
    private static var _appliedDetents: UInt8 = 1

    public var appliedDetents: [Detent] {
        get {
            if let appliedDetents = objc_getAssociatedObject(self, &UIViewController._appliedDetents)
                as? [Detent]
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

    public var currentDetent: Detent? {
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

public enum Detent: Equatable {
    public static func == (lhs: Detent, rhs: Detent) -> Bool {
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

    @MainActor
    public static var height: Detent {
        .custom("scrollViewContentSize") { viewController, containerView in
            let allScrollViewDescendants = viewController.view.allDescendants(ofType: UIScrollView.self)

            guard
                let scrollView = allScrollViewDescendants.first(where: { _ in
                    true
                })
            else {
                return 0
            }
            let navigationController =
                viewController.navigationController ?? findNavigationController(from: viewController)
            let transitioningDelegate =
                navigationController?.transitioningDelegate
                as? DetentTransitioningDelegate
            let keyboardHeight = transitioningDelegate?.keyboardFrame.height ?? 0

            let largeTitleDisplayMode = viewController.navigationItem.largeTitleDisplayMode

            let hasLargeTitle =
                (navigationController?.navigationBar.prefersLargeTitles ?? false)
                && (largeTitleDisplayMode == .automatic || largeTitleDisplayMode == .always)
            let hasNavigationBar =
                navigationController?.navigationBar != nil
                && (navigationController?.isNavigationBarHidden ?? true) == false

            let navigationBarDynamicHeight = navigationController?.navigationBar.frame.height

            let navigationBarHeight: CGFloat = hasLargeTitle ? 107 : navigationBarDynamicHeight ?? 52

            let additionalNavigationSafeAreaInsets =
                navigationController?.additionalSafeAreaInsets ?? UIEdgeInsets()
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
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({ $0.activationState == .foregroundActive })
                    .map({ $0 as? UIWindowScene })
                    .compactMap({ $0 })
                    .first?
                    .windows
                    .filter({ $0.isKeyWindow }).first
                if let keyWindow {
                    let bottomPadding = keyWindow.safeAreaInsets.bottom
                    totalHeight -= bottomPadding
                }
            }
            return totalHeight
        }
    }

    @MainActor
    private static func findNavigationController(from vc: UIViewController?) -> UINavigationController? {

        if let viewController = vc?.children.first(where: { $0.isKind(of: UINavigationController.self) })
            as? UINavigationController
        {
            return viewController
        }
        return nil
    }

    @MainActor
    public static var preferredContentSize: Detent {
        .custom("preferredContentSize") { viewController, _ in
            viewController.preferredContentSize.height
        }
    }

    @MainActor
    static func set(
        _ detents: [Detent],
        on presentationController: UIPresentationController,
        viewController: UIViewController,
        lastDetentIndex: Int? = nil,
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

@MainActor
extension UIViewController {
    static func calculateScrollViewContentHeight(for viewController: UIViewController) -> CGFloat {
        let allScrollViewDescendants = viewController.view.allDescendants(ofType: UIScrollView.self)

        guard
            let scrollView = allScrollViewDescendants.first(where: { _ in
                true
            })
        else {
            return 0
        }
        let navigationController =
            viewController.navigationController ?? findNavigationController(from: viewController)
        let transitioningDelegate =
            navigationController?.transitioningDelegate
            as? DetentTransitioningDelegate
        let keyboardHeight = transitioningDelegate?.keyboardFrame.height ?? 0

        let largeTitleDisplayMode = viewController.navigationItem.largeTitleDisplayMode

        let hasLargeTitle =
            (navigationController?.navigationBar.prefersLargeTitles ?? false)
            && (largeTitleDisplayMode == .automatic || largeTitleDisplayMode == .always)
        let hasNavigationBar =
            navigationController?.navigationBar != nil
            && (navigationController?.isNavigationBarHidden ?? true) == false

        let navigationBarDynamicHeight = navigationController?.navigationBar.frame.height

        let navigationBarHeight: CGFloat = hasLargeTitle ? 107 : navigationBarDynamicHeight ?? 52

        let additionalNavigationSafeAreaInsets =
            navigationController?.additionalSafeAreaInsets ?? UIEdgeInsets()
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
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?
                .windows
                .filter({ $0.isKeyWindow }).first
            if let keyWindow {
                let bottomPadding = keyWindow.safeAreaInsets.bottom
                totalHeight -= bottomPadding
            }
        }
        return totalHeight
    }

    @MainActor
    private static func findNavigationController(from vc: UIViewController?) -> UINavigationController? {
        if let viewController = vc?.children.first(where: { $0.isKind(of: UINavigationController.self) })
            as? UINavigationController
        {
            return viewController
        }
        return nil
    }
}

public class BlurredSheetPresenationController: UISheetPresentationController {
    var effectView: PassThroughEffectView?

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        useBlur: Bool
    ) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        effectView = useBlur ? PassThroughEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial)) : nil
        effectView?.clipsToBounds = true
        self.presentedViewController.view.layer.cornerRadius = 16
        self.presentedViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        effectView?.addGestureRecognizer(tap)
        effectView?.isUserInteractionEnabled = true
    }

    @objc private func didTapBackground() {
        presentedViewController.dismiss(animated: true)
    }

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        if let effectView, effectView.superview == nil {
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

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { [weak self] context in
                guard let self = self else { return }
                self.effectView?.alpha = 0
            })
    }
}

public enum PassThroughEffectOptions {
    case centeredSheet
    case gradient
}

public class PassThroughEffectView: UIVisualEffectView {
    let options: [PassThroughEffectOptions]
    private let gradientLayer = CAGradientLayer()

    public init(effect: UIVisualEffect?, options: [PassThroughEffectOptions]? = []) {
        self.options = options ?? []
        super.init(effect: effect)
        if self.options.contains(.gradient) {
            setupGradient()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGradient() {
        gradientLayer.locations = [0.0, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let blurColor = hBackgroundColor.primary.asCgColor

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            blurColor,
            blurColor,
        ]
        gradientLayer.frame = contentView.bounds
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if options.contains(.centeredSheet) {
            return bounds.contains(point) ? self : nil
        }
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        }

        return hitView
    }
}

@MainActor
public protocol ParentChildRelational {
    associatedtype Member: ParentChildRelational where Member.Member == Member
    var parent: Member? { get }
    var children: [Member] { get }
}

@MainActor
extension UIView: ParentChildRelational {
    @MainActor
    public var parent: UIView? { return superview }
    @MainActor
    public var children: [UIView] { return subviews }
}

extension UIViewController: ParentChildRelational {
}

extension CALayer: ParentChildRelational {
    public var parent: CALayer? { return superlayer }
    public var children: [CALayer] { return sublayers ?? [] }
}

extension ParentChildRelational {
    /// Returns all descendant members.
    public var allDescendants: AnySequence<Member> {
        return AnySequence { () -> AnyIterator<Member> in
            var children = self.children.makeIterator()
            var childDesendants: AnyIterator<Member>?
            return AnyIterator {
                if let desendants = childDesendants, let next = desendants.next() {
                    return next
                }

                guard let next = children.next() else { return nil }

                childDesendants = next.allDescendants.makeIterator()
                return next
            }
        }
    }

    /// Returns all descendant members of type `type`.
    public func allDescendants<T>(ofType type: T.Type) -> AnySequence<T> {
        return AnySequence(allDescendants.lazy.compactMap { $0 as? T })
    }

    /// Returns all descendant members of class `class`.
    public func allDescendants(ofClass class: AnyClass) -> AnySequence<Member> {
        let className = "\(`class`)"
        let classRange = className.startIndex..<className.endIndex
        return AnySequence(
            allDescendants.lazy.filter {
                let name = "\(type(of: $0))"
                guard let range = name.range(of: className), !range.isEmpty else { return false }

                if range == classRange {
                    return true
                }

                /// Make sure to handle views that has been setup for KVO as well.
                if range.upperBound == name.endIndex && name.hasPrefix("NSKVONotifying_") {
                    return true
                }

                return false
            }
        )
    }

    /// Returns all descendant members of class named `name`.
    public func allDescendants(ofClassNamed name: String) -> AnySequence<Member> {
        return allDescendants(ofClass: NSClassFromString(name)!)
    }

    /// Returns all ancestors sorted from the closest to the farthest.
    public var allAncestors: AnySequence<Member> {
        return AnySequence { () -> AnyIterator<Member> in
            var parent = self.parent
            return AnyIterator {
                defer { parent = parent?.parent }
                return parent
            }
        }
    }

    ///Returns the first ancestor of type `type` if any.
    public func firstAncestor<T>(ofType type: T.Type) -> T? {
        guard let parent = parent else { return nil }
        if let matching = parent as? T {
            return matching
        }
        return parent.firstAncestor(ofType: type)
    }
}

extension ParentChildRelational where Member == Self {
    /// Returns the root member of `self`.
    public var rootParent: Member {
        return parent?.rootParent ?? self
    }
}

extension ParentChildRelational where Member: Equatable {
    /// Returns all ancestors that are decendant to `member`, sorted from the closest to the farthest.
    /// - Note: If `member` is not found, nil is returned.
    public func allAncestors(descendantsOf member: Member) -> AnySequence<Member>? {
        var found = false
        let result = allAncestors.prefix {
            found = $0 == member
            return !found
        }
        return found ? AnySequence(result) : nil
    }

    /// Returns the closest common ancestor of `self` and `other` if any.
    public func closestCommonAncestor(with other: Member) -> Member? {
        let common = self.allAncestors.filter(other.allAncestors.contains)
        return common.first
    }
}

extension UIView {
    /// Returns the frame of `self` in the `rootView`s coordinate system.
    public var absoluteFrame: CGRect {
        return convert(bounds, to: rootView)
    }

    /// Returns the root view of `self`.
    public var rootView: UIView {
        return window ?? superview?.rootView ?? self
    }
}
