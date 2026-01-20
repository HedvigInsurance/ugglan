import ObjectiveC
import UIKit

@MainActor private var transitioningDelegateKey: UInt8 = 0

public class AnimatedBackgroundTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let backgroundColor: UIColor
    private let backgroundAnimationDuration: TimeInterval
    private let viewControllerAnimationDuration: TimeInterval

    public init(
        backgroundColor: UIColor,
        backgroundAnimationDuration: TimeInterval = 0.25,
        viewControllerAnimationDuration: TimeInterval = 0.3
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundAnimationDuration = backgroundAnimationDuration
        self.viewControllerAnimationDuration = viewControllerAnimationDuration
        super.init()
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        AnimatedBackgroundDismissAnimator(
            backgroundAnimationDuration: backgroundAnimationDuration,
            viewControllerAnimationDuration: viewControllerAnimationDuration
        )
    }

    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        AnimatedBackgroundPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            backgroundColor: backgroundColor
        )
    }

    /// Applies this delegate to the view controller and retains it for the duration of the presentation.
    /// Use this method instead of setting `transitioningDelegate` directly to ensure the delegate is not deallocated.
    public func apply(to viewController: UIViewController) {
        objc_setAssociatedObject(
            viewController,
            &transitioningDelegateKey,
            self,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .custom
    }
}

// MARK: - Dismissal Animator
private class AnimatedBackgroundDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let backgroundAnimationDuration: TimeInterval
    private let viewControllerAnimationDuration: TimeInterval

    init(
        backgroundAnimationDuration: TimeInterval,
        viewControllerAnimationDuration: TimeInterval
    ) {
        self.backgroundAnimationDuration = backgroundAnimationDuration
        self.viewControllerAnimationDuration = viewControllerAnimationDuration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        viewControllerAnimationDuration + backgroundAnimationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let fromView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView

        // Get the background view from presentation controller
        let presentationController =
            fromViewController.presentationController as? AnimatedBackgroundPresentationController
        let backgroundView = presentationController?.backgroundView

        // Animate view controller out and background fade out together
        UIView.animate(
            withDuration: viewControllerAnimationDuration,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                fromView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
                backgroundView?.alpha = 0
            },
            completion: { _ in
                fromView.transform = .identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// MARK: - Presentation Controller
private class AnimatedBackgroundPresentationController: UIPresentationController {
    let backgroundView: UIView
    private let bgColor: UIColor

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        backgroundColor: UIColor
    ) {
        self.bgColor = backgroundColor
        self.backgroundView = UIView()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        backgroundView.backgroundColor = bgColor
        backgroundView.alpha = 0
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        backgroundView.frame = containerView.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(backgroundView, at: 0)

        // Animate background fade-in alongside the presentation transition
        presentedViewController.transitionCoordinator?
            .animate(
                alongsideTransition: { [weak self] _ in
                    self?.backgroundView.alpha = 1
                }
            )
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return containerView.bounds
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        backgroundView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
