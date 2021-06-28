import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct Card {
	@ReadWriteState var titleIcon: UIImage
	@ReadWriteState var title: DisplayableString
	@ReadWriteState var body: DisplayableString
	@ReadWriteState var buttonText: DisplayableString
	var backgroundColor: UIColor
	var buttonType: ButtonType
}

extension Card: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<UIControl>) {
		let bag = DisposeBag()
		let view = UIView()
		view.accessibilityIdentifier = "Card"
		view.layer.cornerRadius = .defaultCornerRadius
		view.layer.borderWidth = .hairlineWidth
		bag += view.applyBorderColor { _ -> UIColor in .brand(.primaryBorderColor) }

		view.backgroundColor = backgroundColor

		let contentView = UIStackView()
		contentView.axis = .vertical
		contentView.spacing = 16
		contentView.edgeInsets = UIEdgeInsets(horizontalInset: 24, verticalInset: 18)
		view.addSubview(contentView)

		contentView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

		let headerWrapperView = UIStackView()
		headerWrapperView.axis = .vertical
		headerWrapperView.alignment = .center
		contentView.addArrangedSubview(headerWrapperView)

		let headerView = UIStackView()
		headerView.alignment = .center
		headerView.spacing = 8
		headerWrapperView.addArrangedSubview(headerView)

		headerView.addArrangedSubview(
			{
				let imageView = UIImageView()
				imageView.image = titleIcon
				imageView.contentMode = .scaleAspectFit
				imageView.tintColor = .typographyColor(.primary(state: .matching(backgroundColor)))

				bag += $titleIcon.bindTo(imageView, \.image)

				imageView.snp.makeConstraints { make in make.height.width.equalTo(24) }

				return imageView
			}()
		)

		let titleLabel = UILabel(
			value: title,
			style: TextStyle.brand(.headline(color: .primary(state: .matching(backgroundColor))))
				.centerAligned
		)
		bag += $title.bindTo(titleLabel, \.value)

		headerView.addArrangedSubview(titleLabel)

		let bodyLabel = MultilineLabel(
			value: body,
			style: TextStyle.brand(.subHeadline(color: .secondary(state: .matching(backgroundColor))))
				.centerAligned
		)
		bag += $body.bindTo(bodyLabel.$value)

		bag += contentView.addArranged(bodyLabel) { view in contentView.setCustomSpacing(24, after: view) }

		let button = Button(title: buttonText, type: buttonType)
		bag += $buttonText.bindTo(button.title)

		let onTapCallbacker = Callbacker<UIControl>()

		bag += contentView.addArranged(
			button.alignedTo(alignment: .center) { buttonView in
				bag += button.onTapSignal.onValue { onTapCallbacker.callAll(with: buttonView) }
			}
		)

		return (view, onTapCallbacker.providedSignal.hold(bag))
	}
}
