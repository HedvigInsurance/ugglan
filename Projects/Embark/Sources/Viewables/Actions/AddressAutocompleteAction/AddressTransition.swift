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

	init(
		firstBox: UIView,
		secondBox: UIView,
		addressInput: AddressInput
	) {
		self.firstBox = firstBox
		self.secondBox = secondBox
		self.interimAddressInput = addressInput
	}

	private let didEndTransitionCallbacker = Callbacker<Void>()
	var didEndTransitionSignal: Signal<Void> {
		didEndTransitionCallbacker.providedSignal
	}

	private let didStartTransitionCallbacker = Callbacker<Void>()
	var didStartTransitionSignal: Signal<Void> {
		didStartTransitionCallbacker.providedSignal
	}

	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}

	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		guard let autocompleteView = transitionContext.view(forKey: .to) else { return }

		guard let firstBoxSuperview = firstBox.superview else { return }
		let originFrame = firstBoxSuperview.convert(firstBox.frame, to: nil)

		let initialFrame = presenting ? originFrame : autocompleteView.frame
		let finalFrame = presenting ? autocompleteView.frame : originFrame

		guard let snapshot = firstBox.snapshotView(afterScreenUpdates: false) else { return }
		//containerView.addSubview(firstBox)
		//snapshot.frame = initialFrame
		//firstBox.alpha = 0.0

		let bag = DisposeBag()
		let box = UIControl()
		containerView.addSubview(box)

		bag += box.add(interimAddressInput) { addressInputView in
			addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
		}
		box.frame = initialFrame

		didStartTransitionCallbacker.callAll()

		let moveTransform = CGAffineTransform(translationX: 0, y: initialFrame.origin.y)

		let finalCoords = autocompleteView.convert(CGPoint(x: 20, y: 0), to: containerView)

		containerView.addSubview(autocompleteView)
		containerView.bringSubviewToFront(autocompleteView)
		//containerView.bringSubviewToFront(snapshot)
		containerView.bringSubviewToFront(box)

		autocompleteView.alpha = 0.0
		firstBox.alpha = 0.0
		secondBox.alpha = 0.0

		guard let secondBoxSuperview = secondBox.superview else { return }
		let destinationFrame = secondBoxSuperview.convert(secondBox.frame, to: nil)
		print("FRAME:", originFrame, destinationFrame)

		if presenting {
			autocompleteView.transform = moveTransform
			autocompleteView.clipsToBounds = true
		}

		/*bag += autocompleteView.didLayoutSignal
            .map { _ in secondBoxSuperview.convert(self.secondBox.frame, to: nil)}
            .animated(style: .lightBounce(delay: 0, duration: duration), animations: { frame in
                autocompleteView.transform = .identity
                autocompleteView.alpha = 1.0
                box.frame = frame
            })
            .onValue { _ in
                print("frame done")
                self.didEndTransitionCallbacker.callAll()
                transitionContext.completeTransition(true)
                box.removeFromSuperview()
                self.firstBox.alpha = 1.0
                self.secondBox.alpha = 1.0
                bag.dispose()
            }*/

		/*bag += autocompleteView.didLayoutSignal
            .map { _ in secondBoxSuperview.convert(self.secondBox.frame, to: nil)}
            .animated(style: .easeOut(duration: duration), animations: { frame in
                box.frame = frame
            })
            .onValue { frame in
                print("frame done", frame)
            }*/

		UIView.animate(
			withDuration: duration,
			delay: 0.0,
			usingSpringWithDamping: 1.5,
			initialSpringVelocity: 0.2,
			animations: {
				autocompleteView.transform = self.presenting ? .identity : .identity
				autocompleteView.alpha = 1.0
				//box.frame = destinationFrame
				box.frame = CGRect(
					x: destinationFrame.origin.x,
					y: destinationFrame.origin.y + 12,
					width: initialFrame.width,
					height: initialFrame.height
				)
				//box.frame = destinationFrame
				//autocompleteView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
				//autocompleteView.frame.origin = CGPoint(x: 0, y: 0)
			},
			completion: { _ in
				self.didEndTransitionCallbacker.callAll()
				transitionContext.completeTransition(true)
				box.removeFromSuperview()
				self.firstBox.alpha = 1.0
				self.secondBox.alpha = 1.0
				bag.dispose()
			}
		)
	}
}

class AddressTransitionNew: NSObject, UIViewControllerAnimatedTransitioning {
	var transitionDuration: TimeInterval
	var firstBox: UIView
	var secondBox: UIView

	let didBeginTransitionCallbacker = Callbacker<UIView>()
	let didEndTransitionCallbacker = Callbacker<Void>()

	var didBeginTransitionSignal: Signal<UIView> {
		didBeginTransitionCallbacker.providedSignal
	}
	var didEndTransitionSignal: Signal<Void> {
		didEndTransitionCallbacker.providedSignal
	}

	init(
		duration: TimeInterval,
		firstBox: UIView,
		secondBox: UIView
	) {
		self.transitionDuration = duration
		self.firstBox = firstBox
		self.secondBox = secondBox
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionDuration
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let bag = DisposeBag()
		didBeginTransitionCallbacker.callAll(with: transitionContext.containerView)

		bag += didEndTransitionSignal.onValue { _ in
			transitionContext.completeTransition(true)
			bag.dispose()
		}
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
		/*guard let transitionViewSuperview = firstView.superview else { return nil }
		transition.originFrame = transitionViewSuperview.convert(firstView.frame, to: nil)
		transition.firstBox = firstView
        transition.secondBox = secondView*/
		/*transition.originFrame = CGRect(
            x: transition.originFrame.origin.x + 20,
            y: transition.originFrame.origin.y + 20,
            width: transition.originFrame.size.width - 40,
            height: transition.originFrame.size.height - 40
        )*/

		//transition.presenting = true
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
		with transition: AddressTransition
	) -> PresentingViewController.Result {
		if #available(iOS 13.0, *) {
			let vc = viewController.embededInNavigationController(options)
			let bag = DisposeBag()
			let delegate = AddressTransitionDelegate(transition: transition)

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
	public static func address(transition: AddressTransition) -> PresentationStyle {
		PresentationStyle(
			name: "address",
			present: { viewController, from, options in
				return presentAddressHandler(viewController, from, options, with: transition)
			}
		)
	}
}
