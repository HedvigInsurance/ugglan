import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct AddressInput {
	let placeholder: String
	let setIsFirstResponderSignal = ReadWriteSignal<Bool>(true)
	let shouldReturn = Delegate<String, Bool>()
	let postalCodeSignal = ReadWriteSignal<String>("")
	let masking = Masking(type: .none)

	let addressState: AddressState
    
    private func layoutPostalCode(withCode postalCode: String, label: UILabel) {
        if postalCode == "" {
            label.alpha = 0.0
            label.animationSafeIsHidden = true
        } else {
            label.text = postalCode
            label.alpha = 1.0
            label.animationSafeIsHidden = false
        }
    }
}

extension AddressInput: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()

		let box = UIView()
		box.backgroundColor = .brand(.secondaryBackground())
		box.layer.cornerRadius = 8
		bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }

		box.snp.makeConstraints { make in
			make.height.equalTo(70)
		}
		box.isUserInteractionEnabled = false

		let boxStack = UIStackView()
		boxStack.axis = .vertical
		boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		boxStack.isLayoutMarginsRelativeArrangement = true
		box.addSubview(boxStack)
		boxStack.snp.makeConstraints { make in
			make.center.right.left.equalToSuperview()
		}

		let input = EmbarkInput(
			placeholder: placeholder,
			autocapitalisationType: .none,
			masking: masking,
			shouldAutoFocus: false,
			fieldStyle: .embarkInputSmall,
			shouldAutoSize: true
		)

		let inputTextSignal = boxStack.addArranged(input)

		bag += addressState.textSignal.distinct(masking.equalUnmasked).bidirectionallyBindTo(inputTextSignal)

		bag += box.didLayoutSignal.atOnce()
			.onValue { _ in
				inputTextSignal.value = addressState.textSignal.value
				box.layoutSubviews()
				box.layoutIfNeeded()
			}

		let postalCodeLabel = UILabel(
			value: "",
			style: .brand(.subHeadline(color: .secondary)).centerAligned
		)
		boxStack.addArrangedSubview(postalCodeLabel)
		postalCodeLabel.animationSafeIsHidden = true
		postalCodeLabel.alpha = 0.0

		bag += addressState.pickedSuggestionSignal.atOnce()
			.map { addressState.formatPostalLine(from: $0) }
			.onValue { postalLine in
				postalCodeSignal.value = postalLine ?? ""
			}

		bag +=
			addressState.textSignal
			.distinct(masking.equalUnmasked)
			.map { masking.unmaskedValue(text: $0) }
			.onValue { text in
				// Reset suggestion for empty input field
				if text == "" { addressState.pickedSuggestionSignal.value = nil }
				// Reset confirmed address if it doesn't match the updated search term
				if let previousPickedSuggestion = addressState.pickedSuggestionSignal.value {
					if !addressState.isMatchingStreetName(text, previousPickedSuggestion) {
						addressState.pickedSuggestionSignal.value = nil
					}
					if text
						!= addressState.formatAddressLine(
							from: addressState.confirmedSuggestionSignal.value
						)
					{
						addressState.confirmedSuggestionSignal.value = nil
					}
				}
				if let previousPickedSuggestion = addressState.pickedSuggestionSignal.value,
					!addressState.isMatchingStreetName(text, previousPickedSuggestion)
				{
					addressState.pickedSuggestionSignal.value = nil
				}
			}
        
        bag += postalCodeSignal.atOnce().take(first: 1).onValue { postalCode in
            layoutPostalCode(withCode: postalCode, label: postalCodeLabel)
        }

        bag += postalCodeSignal.distinct().animated(
                style: .lightBounce(),
				animations: { postalCode in
                    layoutPostalCode(withCode: postalCode, label: postalCodeLabel)
				}
			)

		bag += input.shouldReturn.set { value -> Bool in self.shouldReturn.call(value) ?? false }

		bag += setIsFirstResponderSignal.bindTo(input.setIsFirstResponderSignal)

		return (box, bag)
	}
}
