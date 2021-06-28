import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct CharityOption {
	let id: GraphQLID
	let name: String
	let title: String
	let description: String
	let paragraph: String

	private let onSelectCallbacker = Callbacker<UIView>()
	let onSelectSignal: Signal<UIView>

	init(
		id: GraphQLID,
		name: String,
		title: String,
		description: String,
		paragraph: String
	) {
		self.id = id
		self.name = name
		self.title = title
		self.description = description
		self.paragraph = paragraph
		onSelectSignal = onSelectCallbacker.signal()
	}
}

extension CharityOption: Reusable {
	static func makeAndConfigure() -> (make: UIStackView, configure: (CharityOption) -> Disposable) {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.distribution = .fill

		return (
			stackView,
			{ charityOption in stackView.arrangedSubviews.forEach { view in view.removeFromSuperview() }

				let bag = DisposeBag()

				let containerView = UIView()

				let contentView = UIStackView()
				contentView.axis = .vertical
				contentView.distribution = .fill
				contentView.spacing = 7.5

				contentView.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
				contentView.isLayoutMarginsRelativeArrangement = true

				containerView.backgroundColor = .brand(.secondaryBackground())

				let titleLabel = UILabel(
					value: charityOption.name,
					style: .brand(.headline(color: .primary))
				)
				contentView.addArrangedSubview(titleLabel)

				let descriptionLabel = MultilineLabel(
					styledText: StyledText(
						text: charityOption.description,
						style: .brand(.body(color: .primary))
					)
				)
				bag += contentView.addArranged(descriptionLabel)

				bag += contentView.addArranged(Spacing(height: 5))

				let buttonContainer = UIView()

				let button = Button(
					title: L10n.chartityPickOption,
					type: .standard(
						backgroundColor: .brand(.primaryButtonBackgroundColor),
						textColor: .brand(.primaryButtonTextColor)
					)
				)

				bag += buttonContainer.add(button) { buttonView in
					bag += button.onTapSignal.onValue {
						charityOption.onSelectCallbacker.callAll(with: buttonView)
					}
				}

				contentView.addArrangedSubview(buttonContainer)

				buttonContainer.snp.makeConstraints { make in
					make.height.equalTo(button.type.value.height)
				}

				containerView.addSubview(contentView)
				stackView.addArrangedSubview(containerView)

				contentView.snp.makeConstraints { make in make.edges.equalToSuperview() }

				bag += containerView.didLayoutSignal.onValue {
					containerView.layer.masksToBounds = false
					containerView.layer.cornerRadius = 8

					bag += containerView.applyShadow { _ in
						UIView.ShadowProperties(
							opacity: 0.08,
							offset: CGSize(width: 0, height: 10),
							blurRadius: 3,
							color: UIColor.brand(.primaryShadowColor),
							path: nil,
							radius: 8
						)
					}
				}

				return bag
			}
		)
	}
}
