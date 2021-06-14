import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct MultiActionDropDownRow {
	let data: EmbarkDropDownActionData
	let isExpanded = ReadWriteSignal<Bool>(false)
}

extension MultiActionDropDownRow: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
		let bag = DisposeBag()

		let containerView = UIView()
		bag += containerView.traitCollectionSignal.onValue { trait in
			switch trait.userInterfaceStyle {
			case .dark: containerView.backgroundColor = .grayscale(.grayFive)
			default: containerView.backgroundColor = .brand(.primaryBackground())
			}
		}

		let mainStack = UIStackView()
		mainStack.axis = .vertical
		mainStack.distribution = .fill

		containerView.addSubview(mainStack)
		mainStack.snp.makeConstraints { make in make.edges.equalToSuperview() }

		let topStack = UIStackView()
		topStack.axis = .horizontal
		topStack.spacing = 10
		topStack.edgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
		topStack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		topStack.snp.makeConstraints { make in make.height.equalTo(50) }

		let titleLabel = UILabel()
		titleLabel.style = .brand(.body(color: .primary))
		titleLabel.text = data.label

		let options = data.options.map { $0.text }

		let buttonStack = UIStackView()
		buttonStack.axis = .horizontal
		buttonStack.alignment = .center
		buttonStack.spacing = 8
		buttonStack.isUserInteractionEnabled = false

		let buttonTitle = UILabel()
		buttonTitle.style = .brand(.body(color: .tertiary))
		buttonTitle.setContentHuggingPriority(.required, for: .vertical)
        buttonTitle.text = L10n.generalSelectButton

		let buttonIcon = UIImageView()
		buttonIcon.image = hCoreUIAssets.chevronUp.image
		buttonIcon.tintColor = .brand(.primaryText())

		buttonStack.addArrangedSubview(buttonTitle)
		buttonStack.addArrangedSubview(buttonIcon)

		let button = UIControl()
		button.addSubview(buttonStack)
		buttonStack.snp.makeConstraints { make in make.edges.equalToSuperview() }

		topStack.addArrangedSubview(titleLabel)
		topStack.addArrangedSubview(button)

		mainStack.addArrangedSubview(topStack)
		bag += mainStack.add(Divider(backgroundColor: .brand(.primaryShadowColor)))

		bag += button.signal(for: .touchUpInside).withLatestFrom(isExpanded.atOnce().plain()).map { !$1 }
			.bindTo(isExpanded)

		return (
			containerView,
			Signal { callback in let pickerView = PickerView(options: options)
				bag +=
					mainStack.addArranged(pickerView) { view in
						bag += isExpanded.atOnce()
							.animated(style: .lightBounce()) { isExpanded in
								view.isHidden = !isExpanded
								view.alpha = isExpanded ? 1.0 : 0.0
								let rotation = CGFloat(180 * Double.pi / 180)
								let transform =
									isExpanded
									? CGAffineTransform.identity
									: .init(rotationAngle: rotation)
								buttonIcon.transform = transform
							}
					}
					.map { option in data.options.first(where: { $0.value == option }) }
					.onValue { selectedOption in buttonTitle.style = .brand(.body(color: .primary))
						guard let selectedOption = selectedOption else { return }
						buttonTitle.value = selectedOption.value

						let value = MultiActionValue(
							inputValue: selectedOption.value,
							displayValue: nil,
                            isValid: true
						)
                        
                        let labelValue = MultiActionValue(inputValue: selectedOption.text, displayValue: nil, isValid: true)
                        
						callback([data.key: value, "\(data.key).Label": labelValue])
					}

				return bag
			}
		)
	}
}
