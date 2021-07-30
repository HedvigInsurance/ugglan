import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct AddressInput {
	let placeholder: String
	let textSignal = ReadWriteSignal<String>("")
	private let setTextSignal = ReadWriteSignal<String>("")
	let setIsFirstResponderSignal = ReadWriteSignal<Bool>(true)
	let shouldReturn = Delegate<String, Bool>()
    let postalCodeSignal = ReadWriteSignal<String>("")

	var text: String {
		get {
			return textSignal.value
		}
		set(newText) {
			setTextSignal.value = newText
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

		let boxStack = UIStackView()
		boxStack.axis = .vertical
		boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		boxStack.isLayoutMarginsRelativeArrangement = true
		box.addSubview(boxStack)
		boxStack.snp.makeConstraints { make in
			make.top.bottom.right.left.equalToSuperview()
		}
		box.isUserInteractionEnabled = false

		let input = EmbarkInput(
			placeholder: placeholder,
			autocapitalisationType: .none,
			masking: Masking(type: .none),
			shouldAutoFocus: false,
            fieldStyle: .embarkInputLarge,
			shouldAutoSize: true
		)

		let inputTextSignal = boxStack.addArranged(input)
		bag += inputTextSignal.bindTo(textSignal)
		bag += setTextSignal.bindTo(inputTextSignal)
        
        let postalCodeLabel = UILabel(
            value: "7100 Vejle",
            style: .brand(.subHeadline(color: .secondary)).centerAligned
        )
        boxStack.addArrangedSubview(postalCodeLabel)
        postalCodeLabel.animationSafeIsHidden = true
        
        bag += postalCodeSignal.distinct().onValue { postalCode in
            postalCodeLabel.text = postalCode
            if postalCode == "" {
                postalCodeLabel.animationSafeIsHidden = true
                input.fieldStyleSignal.value = .embarkInputLarge
            } else {
                postalCodeLabel.animationSafeIsHidden = false
                input.fieldStyleSignal.value = .embarkInputSmall
            }
        }

		bag += input.shouldReturn.set { value -> Bool in self.shouldReturn.call(value) ?? false }

		bag += setIsFirstResponderSignal.bindTo(input.setIsFirstResponderSignal)

		return (box, bag)
	}
}
