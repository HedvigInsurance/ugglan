import UIKit

class ModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        ModalPresentationAnimator(duration: duration)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ModalDismissalAnimator(duration: duration)
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

private class ModalPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)

        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)

        // Add dimming background
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        dimmingView.tag = 999
        containerView.insertSubview(dimmingView, at: 0)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                toViewController.view.frame = finalFrame
                dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}

private class ModalDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = fromViewController.view.frame.offsetBy(dx: 0, dy: fromViewController.view.frame.height)

        let dimmingView = containerView.viewWithTag(999)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                fromViewController.view.frame = finalFrame
                dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            },
            completion: { finished in
                dimmingView?.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        )
    }
}

private class ModalPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return containerView.bounds
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        containerView.frame = containerView.bounds
    }
}

struct AssociatedKeys {
    @MainActor static var transitionDelegate: UInt8 = 0
}
