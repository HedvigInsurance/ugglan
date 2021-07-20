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
    let resultsSignal = ReadWriteSignal<[String]>([])
    
    let addressState = AddressState()

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

		let view = UIView()
		//view.axis = .vertical
		//view.distribution = .equalSpacing
		//view.alignment = .top
		//view.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
		//view.isLayoutMarginsRelativeArrangement = true
		//view.spacing = 15

		let headerBackground = UIView()
		headerBackground.backgroundColor = .brand(.secondaryBackground())
		let headerView = UIStackView()
		headerView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 20)
		headerView.isLayoutMarginsRelativeArrangement = true
		view.addSubview(headerBackground)
        headerBackground.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
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
            make.top.right.left.bottom.equalToSuperview()
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
		
        let tableKit = TableKit<String, AddressRow>(style: .brandInset, holdIn: bag)
        bag += tableKit.delegate.heightForCell.set { index -> CGFloat in tableKit.table[index].cellHeight }
        
        view.addSubview(tableKit.view)
        tableKit.view.backgroundColor = .brand(.primaryBackground())
        tableKit.view.snp.makeConstraints { make in
            make.top.equalTo(headerBackground.snp.bottom)
            make.bottom.trailing.leading.equalToSuperview()
        }
        
        bag += resultsSignal.atOnce().onValue { addresses in
            print(addresses)
            var table = Table(sections: [
                (
                    "",
                    addresses.map { AddressRow(address: $0) }
                )
            ])
            table.removeEmptySections()
            tableKit.set(table)
        }
        
        bag += addressInput.textSignal.onValue { text in
            bag += addressState.getSuggestions(searchTerm: text).map { data in
                data.autoCompleteAddress.map { $0.address}
            }.bindTo(resultsSignal)
        }

		return (viewController, bag)
	}
}
