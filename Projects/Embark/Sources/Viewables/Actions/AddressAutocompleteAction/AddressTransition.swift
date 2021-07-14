import Flow
import Foundation
import Presentation
import UIKit

protocol AddressTransitionable {
	var boxFrame: ReadWriteSignal<CGRect?> { get }
}

class AddressTransition: NSObject, UIViewControllerAnimatedTransitioning {
	let duration = 0.8
	var presenting = true
	var originFrame = CGRect.zero
    var originView = UIView()

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		guard let autocompleteView = transitionContext.view(forKey: .to) else { return }

		let initialFrame = presenting ? originFrame : autocompleteView.frame
		let finalFrame = presenting ? autocompleteView.frame : originFrame

        guard let snapshot = originView.snapshotView(afterScreenUpdates: false) else { return }
        containerView.addSubview(snapshot)
        snapshot.frame = initialFrame
        originView.alpha = 0.0
        
        let moveTransform = CGAffineTransform(translationX: 0, y: initialFrame.origin.y)
        
        let finalCoords = autocompleteView.convert(CGPoint(x: 20, y: 0), to: containerView)
        
		if presenting {
			autocompleteView.transform = moveTransform
			autocompleteView.clipsToBounds = true
		}

		containerView.addSubview(autocompleteView)
		containerView.bringSubviewToFront(autocompleteView)
        containerView.bringSubviewToFront(snapshot)

		autocompleteView.alpha = 0.0

		UIView.animate(
			withDuration: duration,
			delay: 0.0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 0.2,
			animations: {
                autocompleteView.transform = self.presenting ? .identity : .identity
				autocompleteView.alpha = 1.0
                snapshot.frame = CGRect(x: finalCoords.x, y: finalCoords.y + 56 + 20, width: initialFrame.width, height: initialFrame.height)
				//autocompleteView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
				//autocompleteView.frame.origin = CGPoint(x: 0, y: 0)
			},
			completion: { _ in
				transitionContext.completeTransition(true)
                snapshot.removeFromSuperview()
                self.originView.alpha = 1.0
			}
		)
	}
}

class AddressTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
	let transition = AddressTransition()
	var transitionView: UIView

	init(
		transitionView: UIView
	) {
		self.transitionView = transitionView
	}

	func animationController(
		forPresented presented: UIViewController,
		presenting: UIViewController,
		source: UIViewController
	) -> UIViewControllerAnimatedTransitioning? {
		guard let transitionViewSuperview = transitionView.superview else { return nil }
		transition.originFrame = transitionViewSuperview.convert(transitionView.frame, to: nil)
        transition.originView = transitionView
		/*transition.originFrame = CGRect(
            x: transition.originFrame.origin.x + 20,
            y: transition.originFrame.origin.y + 20,
            width: transition.originFrame.size.width - 40,
            height: transition.originFrame.size.height - 40
        )*/

		transition.presenting = true
		return transition
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return nil
	}
}

extension PresentationStyle {
	private static func presentAddressHandler(
		_ viewController: UIViewController,
		_ from: UIViewController,
		_ options: PresentationOptions,
		with transitionView: UIView
	) -> PresentingViewController.Result {
		if #available(iOS 13.0, *) {
			let vc = viewController.embededInNavigationController(options)
			let bag = DisposeBag()
			let delegate = AddressTransitionDelegate(transitionView: transitionView)

			bag.hold(delegate)
			vc.transitioningDelegate = delegate
			vc.modalPresentationStyle = .automatic

			return from.modallyPresentQueued(vc, options: options) {
				return Future { completion in
					PresentationStyle.modalPresentationDismissalSetup(for: vc, options: options)
						.onResult(completion)
					return bag
				}
			}
		} else {
			return PresentationStyle.modal.present(
				viewController,
				from: from,
				options: options
			)
		}
	}

	// TODO: rewrite to variable with getter
	public static func address(view: UIView) -> PresentationStyle {
		PresentationStyle(
			name: "address",
			present: { viewController, from, options in
				return presentAddressHandler(viewController, from, options, with: view)
			}
		)
	}
}
