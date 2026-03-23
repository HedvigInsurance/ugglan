import Combine
import Foundation
import SwiftUI
import hCore

class CenteredModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var bottomView: AnyView?
    var onUserDismiss: (() -> Void)?

    init(
        bottomView: AnyView? = nil,
        onUserDismiss: (() -> Void)? = nil
    ) {
        self.bottomView = bottomView
        self.onUserDismiss = onUserDismiss
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source _: UIViewController
    ) -> UIPresentationController? {
        let pc = CenteredModalPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            bottomView: bottomView
        )
        pc.onUserDismiss = onUserDismiss
        return pc
    }
}

final class CenteredModalPresentationController: UIPresentationController {
    private let blurView: PassThroughEffectView?
    private var bottomHostingController: UIHostingController<AnyView>?

    private var startDragPosition: CGFloat = 0
    private var dragPercentage: CGFloat = 0
    private var dragOffset: CGFloat = 0
    private var dragState: ModalScaleState = .presentation

    var onUserDismiss: (() -> Void)?

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        bottomView: AnyView?
    ) {
        blurView = PassThroughEffectView(effect: UIBlurEffect(style: .light), options: [.centeredSheet, .gradient])

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        blurView?.alpha = 0

        if let bottomView = bottomView {
            bottomHostingController = UIHostingController(rootView: bottomView)
            bottomHostingController?.view.backgroundColor = .clear
        }
    }

    @objc private func dismissOnTapOutside() {
        onUserDismiss?()
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

// drag gesture part
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
                        presented.transform = CGAffineTransform(translationX: 0, y: trueOffset)
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
                onUserDismiss?()
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
