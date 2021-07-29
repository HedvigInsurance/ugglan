import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

protocol AddressTransitionable {
	var boxFrame: ReadWriteSignal<CGRect?> { get }
}

public class AddressTransition: NSObject, UIViewControllerAnimatedTransitioning {
	let duration = 0.5
	var presenting = true
	let firstBox: UIView
	let secondBox: UIView
	let interimAddressInput: AddressInput
    var initialBoxFrame = CGRect.zero

	init(
		firstBox: UIView,
		secondBox: UIView,
		addressInput: AddressInput
	) {
		self.firstBox = firstBox
		self.secondBox = secondBox
		self.interimAddressInput = addressInput
	}

	private let didEndTransitionCallbacker = Callbacker<Bool>()
	var didEndTransitionSignal: Signal<Bool> {
		didEndTransitionCallbacker.providedSignal
	}

	private let didStartTransitionCallbacker = Callbacker<Bool>()
	var didStartTransitionSignal: Signal<Bool> {
		didStartTransitionCallbacker.providedSignal
	}

	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}

	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		var _autocompleteView = transitionContext.view(forKey: .to)
		if let fromView = transitionContext.view(forKey: .from), !presenting {
			_autocompleteView = fromView
		}
		guard let autocompleteView = _autocompleteView else { return }

		if presenting {
			containerView.addSubview(autocompleteView)
			containerView.bringSubviewToFront(autocompleteView)
			autocompleteView.alpha = 0.0
		}

		firstBox.alpha = 0.0
		secondBox.alpha = 0.0

        if presenting {
            guard let firstBoxSuperview = firstBox.superview else { return }
            initialBoxFrame = firstBoxSuperview.convert(firstBox.frame, to: nil)
        }
        
		guard let secondBoxSuperview = secondBox.superview else { return }
		var destinationFrame = secondBoxSuperview.convert(secondBox.frame, to: nil)
        if presenting {
            // Hack. autocompleteView should layout first, then we get the correct y position, but then animations are not working.
            destinationFrame.origin.y = destinationFrame.origin.y + 12
        }
        
		let initialFrame = presenting ? initialBoxFrame : destinationFrame
		let finalFrame = presenting ? destinationFrame : initialBoxFrame

		let bag = DisposeBag()
		let box = UIControl()
		containerView.addSubview(box)
		bag += box.add(interimAddressInput) { addressInputView in
			addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
		}
		box.frame = initialFrame
        
        didStartTransitionCallbacker.callAll(with: presenting)

		containerView.bringSubviewToFront(box)

		if presenting {
			autocompleteView.transform = CGAffineTransform(translationX: 0, y: initialFrame.origin.y)
			autocompleteView.clipsToBounds = true
		}
		UIView.animate(
			withDuration: duration,
			delay: 0.0,
			usingSpringWithDamping: 1.5,
			initialSpringVelocity: 0.2,
			animations: {
				autocompleteView.transform =
					self.presenting
					? .identity : CGAffineTransform(translationX: 0, y: finalFrame.origin.y)
				autocompleteView.alpha = self.presenting ? 1.0 : 0.0
				box.frame = finalFrame
			},
			completion: { _ in
				self.didEndTransitionCallbacker.callAll(with: self.presenting)
				transitionContext.completeTransition(true)
				box.removeFromSuperview()
				self.firstBox.alpha = 1.0
				self.secondBox.alpha = 1.0
				bag.dispose()
			}
		)
	}
}

class AddressTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
	let transition: AddressTransition

	init(
		transition: AddressTransition
	) {
		self.transition = transition
	}

	func animationController(
		forPresented presented: UIViewController,
		presenting: UIViewController,
		source: UIViewController
	) -> UIViewControllerAnimatedTransitioning? {
		transition.presenting = true
		return transition
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		transition.presenting = false
		return transition
	}
}

extension PresentationStyle {
	private static func presentAddressHandler(
		_ viewController: UIViewController,
		_ from: UIViewController,
		_ options: PresentationOptions,
		with transition: AddressTransition
	) -> PresentingViewController.Result {
		if #available(iOS 13.0, *) {
			let vc = viewController.embededInNavigationController(options)
			let bag = DisposeBag()
			let delegate = AddressTransitionDelegate(transition: transition)

			bag.hold(delegate)
			vc.transitioningDelegate = delegate
			vc.modalPresentationStyle = .automatic
			vc.isModalInPresentation = true

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

	public static func address(transition: AddressTransition) -> PresentationStyle {
		PresentationStyle(
			name: "address",
			present: { viewController, from, options in
				return presentAddressHandler(viewController, from, options, with: transition)
			}
		)
	}
}
