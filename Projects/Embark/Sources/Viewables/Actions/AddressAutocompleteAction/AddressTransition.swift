import Flow
import Foundation
import Presentation
import UIKit

protocol AddressTransitionable {
	var boxFrame: ReadWriteSignal<CGRect> { get }
}

class AddressTransition: NSObject, UIViewControllerAnimatedTransitioning {
	let duration = 5.8
	var presenting = true
	var originFrame = CGRect.zero

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		guard let toView = transitionContext.view(forKey: .to) else { return }
		let autocompleteView = toView

		let initialFrame = presenting ? originFrame : autocompleteView.frame
		let finalFrame = presenting ? autocompleteView.frame : originFrame

		let xScaleFactor =
			presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width

		let yScaleFactor =
			presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height

		let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: 1)
		let moveTransform = CGAffineTransform(translationX: 0, y: initialFrame.origin.y)

		if presenting {
			autocompleteView.transform = scaleTransform.concatenating(moveTransform)
			//autocompleteView.frame.origin = CGPoint(x: initialFrame.minX, y: -initialFrame.origin.y)
			//CGPoint(
			//    x: initialFrame.midX,
			//y: initialFrame.midY
			//    y: initialFrame.origin.y

			autocompleteView.clipsToBounds = true
		}

		containerView.addSubview(autocompleteView)
		containerView.bringSubviewToFront(autocompleteView)

		autocompleteView.alpha = 0.0

		UIView.animate(
			withDuration: duration,
			delay: 0.0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 0.2,
			animations: {
				autocompleteView.transform = self.presenting ? .identity : scaleTransform
				autocompleteView.alpha = 1.0
				//autocompleteView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
				//autocompleteView.frame.origin = CGPoint(x: 0, y: 0)
			},
			completion: { _ in
				transitionContext.completeTransition(true)
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
