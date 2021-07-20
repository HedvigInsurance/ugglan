import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct EmbarkAddressAutocomplete: AddressTransitionable {
	var boxFrame: ReadWriteSignal<CGRect?> = ReadWriteSignal(CGRect.zero)
    let textSignal = ReadWriteSignal<String>("")
    private let setTextSignal = ReadWriteSignal<String>("")
    let setIsFirstResponderSignal = ReadWriteSignal<Bool>(true)
    let box = UIControl()
	let state: EmbarkState
	let data: EmbarkAddressAutocompleteData
    
    var text: String {
        get {
            return textSignal.value
        }
        set(newText) {
            setTextSignal.value = newText
        }
    }
}

extension EmbarkAddressAutocomplete: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = "Address"
		let bag = DisposeBag()

		let view = UIStackView()
		view.axis = .vertical
		view.distribution = .equalSpacing
        view.alignment = .top
		//view.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
		view.isLayoutMarginsRelativeArrangement = true
		view.spacing = 15
        
        let headerBackground = UIView()
        headerBackground.backgroundColor = .brand(.secondaryBackground())
        let headerView = UIStackView()
        headerView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 20)
        headerView.isLayoutMarginsRelativeArrangement = true
        view.addArrangedSubview(headerBackground)
        headerBackground.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        let headerBorder = UIView()
        headerBorder.backgroundColor = .brand(.primaryBorderColor)
        headerBackground.addSubview(headerBorder)
        headerBorder.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(CGFloat.hairlineWidth)
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .brand(.primaryBackground())
        viewController.view = backgroundView
        
        backgroundView.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
        }

		//form.append(view)
        headerView.addArrangedSubview(box)

        var addressInput = AddressInput(placeholder: data.addressAutocompleteActionData.placeholder)
        bag += box.add(addressInput) { addressInputView in
            addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
        }
        bag += addressInput.textSignal.bindTo(textSignal)
        bag += setTextSignal.onValue { newText in
            addressInput.text = newText
        }
        
        bag += setIsFirstResponderSignal.bindTo(addressInput.setIsFirstResponderSignal)
		//        let textField = UITextField()
		//        textField.autocorrectionType = .no
		//        form.append(textField)
		//        textField.becomeFirstResponder()

		return (viewController, bag)
	}
}
