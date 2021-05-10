import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Kingfisher
import UIKit

struct AttachGIFImage {
	let url: URL
	let chatstate: ChatState
	weak var uploadGifDelegate = Flow.Delegate<String, Signal<Void>>()

	init(
		url: URL,
		chatState: ChatState
	) {
		self.url = url
		chatstate = chatState
	}
}

extension AttachGIFImage: Reusable {
	static func makeAndConfigure() -> (make: UIView, configure: (AttachGIFImage) -> Disposable) {
		let view = UIControl()
		view.backgroundColor = .clear
		let imageView = UIImageView()
		view.addSubview(imageView)
		view.clipsToBounds = true

		imageView.isUserInteractionEnabled = false
		imageView.backgroundColor = .clear
		imageView.snp.makeConstraints { make in make.top.right.left.equalTo(view)
			make.bottom.equalTo(view.safeAreaLayoutGuide)
		}
		imageView.contentMode = .scaleAspectFill

		return (
			view, { `self` in let bag = DisposeBag()
				let sendOverlayBag = bag.innerBag()
				imageView.kf.setImage(
					with: self.url,
					options: [.preloadAllAnimationData, .transition(.fade(1))]
				)

				bag += view.signal(for: .touchUpInside)
					.onValue { _ in
						if !sendOverlayBag.isEmpty {
							sendOverlayBag.dispose()
							return
						}

						let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
						effectView.layer.cornerRadius = 5
						effectView.clipsToBounds = true
						effectView.alpha = 0
						imageView.addSubview(effectView)

						let hideOverlayControl = UIControl()
						effectView.contentView.addSubview(hideOverlayControl)

						sendOverlayBag += hideOverlayControl.signal(for: .touchUpInside)
							.onValue { _ in sendOverlayBag.dispose() }

						hideOverlayControl.snp.makeConstraints { make in
							make.width.height.centerX.centerY.equalToSuperview()
						}

						view.addSubview(hideOverlayControl)
						hideOverlayControl.snp.makeConstraints { make in
							make.left.right.top.equalToSuperview()
							make.bottom.equalTo(view.safeAreaLayoutGuide)
						}

						let button = Button(
							title: L10n.attachGifImageSend,
							type: .standard(
								backgroundColor: .brand(.primaryButtonBackgroundColor),
								textColor: .brand(.primaryButtonTextColor)
							)
						)
						let loadableButton = LoadableButton(
							button: button,
							initialLoadingState: false
						)

						sendOverlayBag += loadableButton.onTapSignal.onValue { _ in
							loadableButton.isLoadingSignal.value = true
							bag += self.uploadGifDelegate.call(self.url.absoluteString)?
								.onValue { _ in

									loadableButton.isLoadingSignal.value = false
									sendOverlayBag.dispose()
								}
						}

						bag += hideOverlayControl.add(loadableButton) { buttonView in
							buttonView.snp.makeConstraints { make in
								make.center.equalToSuperview()
							}

							buttonView.transform = CGAffineTransform(
								translationX: 0,
								y: -view.frame.height
							)

							sendOverlayBag += Signal(after: 0)
								.animated(style: .mediumBounce()) { _ in
									buttonView.transform =
										CGAffineTransform.identity
								}

							sendOverlayBag += {
								bag += Signal(after: 0)
									.animated(style: .mediumBounce()) { _ in
										buttonView.transform =
											CGAffineTransform(
												translationX: 0,
												y: -view.frame.height
											)
									}
							}
						}
						effectView.snp.makeConstraints { make in
							make.width.height.centerX.centerY.equalToSuperview()
						}

						sendOverlayBag += Signal(after: 0)
							.animated(style: .easeOut(duration: 0.25)) { _ in
								effectView.alpha = 1
							}

						sendOverlayBag += {
							bag += Signal(after: 0)
								.animated(style: .easeOut(duration: 0.25)) { _ in
									effectView.alpha = 0
								}
								.onValue { _ in effectView.removeFromSuperview()
									hideOverlayControl.removeFromSuperview()
								}
						}
					}
				return bag
			}
		)
	}
}
