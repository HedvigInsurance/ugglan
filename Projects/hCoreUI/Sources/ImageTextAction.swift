import Flow
import Form
import Foundation
import UIKit
import hCore

public struct ImageWithOptions {
	let image: UIImage
	let size: CGSize?
	let contentMode: UIView.ContentMode
	let insets: UIEdgeInsets

	public init(
		image: UIImage
	) {
		self.image = image
		size = nil
		contentMode = .scaleAspectFit
		insets = .zero
	}

	public init(
		image: UIImage,
		size: CGSize?,
		contentMode: UIView.ContentMode,
		insets: UIEdgeInsets? = nil
	) {
		self.image = image
		self.size = size
		self.contentMode = contentMode
		self.insets = insets ?? .zero
	}
}

public struct ImageTextAction<ActionResult> {
	public let image: ImageWithOptions
	@ReadWriteState public var title: String
	@ReadWriteState public var body: String
	public let actions: [(ActionResult, Button)]
	public let showLogo: Bool

	public init(
		image: ImageWithOptions,
		title: String,
		body: String,
		actions: [(ActionResult, Button)],
		showLogo: Bool
	) {
		self.image = image
		self.title = title
		self.body = body
		self.actions = actions
		self.showLogo = showLogo
	}
}

extension ImageTextAction: Viewable {
	public func materialize(events _: ViewableEvents) -> (UIScrollView, Signal<ActionResult>) {
		let bag = DisposeBag()
		let scrollView = FormScrollView()

		let containerView = UIStackView()
		containerView.axis = .horizontal
		containerView.alignment = .center
		containerView.layoutMargins = UIEdgeInsets(horizontalInset: 25, verticalInset: 25)
		containerView.isLayoutMarginsRelativeArrangement = true

		scrollView.embedView(containerView, scrollAxis: .vertical)

		let view = UIStackView()
		view.spacing = 24
		view.axis = .vertical
		view.alignment = .center

		if showLogo {
			let logoImageContainer = UIStackView()
			logoImageContainer.axis = .horizontal
			logoImageContainer.alignment = .center

			let logoImageView = UIImageView()
			logoImageView.image = hCoreUIAssets.wordmark.image
			logoImageView.contentMode = .scaleAspectFit

			logoImageView.snp.makeConstraints { make in make.height.equalTo(30) }

			logoImageContainer.addArrangedSubview(logoImageView)
			view.addArrangedSubview(logoImageContainer)
		}

		let headerImageContainer = UIStackView()
		headerImageContainer.axis = .horizontal
		headerImageContainer.alignment = .center
		headerImageContainer.edgeInsets = image.insets

		let headerImageView = UIImageView()
		headerImageView.image = image.image
		headerImageView.contentMode = .scaleAspectFit
		headerImageView.tintColor = .brand(.primaryTintColor)

		headerImageView.snp.makeConstraints { make in
			make.height.equalTo(image.size?.height ?? 270)
			if let width = image.size?.width { make.width.equalTo(width) }
		}

		headerImageContainer.addArrangedSubview(headerImageView)
		view.addArrangedSubview(headerImageContainer)

		var titleLabel = MultilineLabel(
			value: title,
			style: TextStyle.brand(.title2(color: .primary)).aligned(to: .center)
		)
		bag += view.addArranged(titleLabel)
		bag += $title.onValue { value in titleLabel.value = value }

		var bodyLabel = MultilineLabel(
			value: body,
			style: TextStyle.brand(.body(color: .secondary)).aligned(to: .center)
		)
		bag += view.addArranged(bodyLabel)
		bag += $body.onValue { value in bodyLabel.value = value }

		let buttonsContainer = UIStackView()
		buttonsContainer.axis = .vertical
		buttonsContainer.spacing = 15
		buttonsContainer.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
		buttonsContainer.isLayoutMarginsRelativeArrangement = true
		buttonsContainer.insetsLayoutMarginsFromSafeArea = false

		bag += buttonsContainer.didLayoutSignal.onValue { _ in
			buttonsContainer.layoutMargins = UIEdgeInsets(
				top: 0,
				left: 0,
				bottom: scrollView.safeAreaInsets.bottom == 0 ? 15 : scrollView.safeAreaInsets.bottom,
				right: 0
			)
		}

		let shadowView = UIView()

		let gradient = CAGradientLayer()
		gradient.locations = [0, 0.1, 0.9, 1]
		shadowView.layer.addSublayer(gradient)

		func setGradientColors() {
			let formBackground = scrollView.backgroundColor ?? UIColor.black
			gradient.colors = [formBackground.withAlphaComponent(0.2).cgColor, formBackground.cgColor]
		}

		bag += shadowView.traitCollectionSignal.onValue { _ in setGradientColors() }

		bag += shadowView.didLayoutSignal.onValue { _ in gradient.frame = shadowView.bounds }

		buttonsContainer.addSubview(shadowView)

		shadowView.snp.makeConstraints { make in make.width.height.centerY.centerX.equalToSuperview() }

		scrollView.addSubview(buttonsContainer)

		buttonsContainer.snp.makeConstraints { make in
			make.bottom.equalTo(scrollView.frameLayoutGuide.snp.bottom)
			make.trailing.leading.equalToSuperview()
		}

		bag += buttonsContainer.didLayoutSignal.onValue {
			let size = buttonsContainer.systemLayoutSizeFitting(.zero)
			scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
			scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
		}

		containerView.addArrangedSubview(view)

		return (
			scrollView,
			Signal { callback in
				bag += self.actions.map { _, button in
					let buttonInStackView = button.alignedTo(alignment: .fill)
						.insetted(UIEdgeInsets(horizontalInset: 15, verticalInset: 0))
					return buttonsContainer.addArranged(buttonInStackView)
				}

				bag += self.actions.map { result, button in
					button.onTapSignal.onValue { _ in callback(result) }
				}

				return bag
			}
		)
	}
}
