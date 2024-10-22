import Combine
import Foundation
import SwiftUI
import hCore

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

public struct PresentationOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    static let useBlur = PresentationOptions()

}

class DetentedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
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
                        return -50
                    })
                ]
            }
        }

        Detent.set(
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

        Task { @MainActor [weak presentationController] in
            for i in 0...2 {
                let date = Date()
                try? await Task.sleep(nanoseconds: 50_000_000)
                let date2 = Date()
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
                as? DetentedTransitioningDelegate
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

    private static func findNavigationController(from vc: UIViewController?) -> UINavigationController? {

        if let viewController = vc?.children.first(where: { $0.isKind(of: UINavigationController.self) })
            as? UINavigationController
        {
            return viewController
        }
        return nil
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
//}

@available(iOS 16.0, *)
public class BlurredSheetPresenationController: UISheetPresentationController {

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
            return .light
        }
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

public class PassThroughEffectView: UIVisualEffectView {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        }

        return hitView
    }
}

public protocol ParentChildRelational {
    associatedtype Member: ParentChildRelational where Member.Member == Member
    var parent: Member? { get }
    var children: [Member] { get }
}

extension UIView: ParentChildRelational {
    public var parent: UIView? { return superview }
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
