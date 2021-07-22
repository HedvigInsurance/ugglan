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
		view.backgroundColor = .brand(.primaryBackground())
		viewController.view = view
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

		/*let scrollView = UIScrollView()
        let form = FormView()
        scrollView.embedView(form, scrollAxis: .vertical)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBackground.snp.bottom)
            make.bottom.trailing.leading.equalToSuperview()
        }


        let section = form.appendSection(header: nil, footer: nil)

        bag += resultsSignal
            .atOnce()
            .onValueDisposePrevious { addresses -> Disposable? in let innerBag = DisposeBag()
                innerBag += addresses.map { address -> Disposable in
                    let row = KeyValueRow()
                    row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

                    row.keySignal.value = address
                    return section.append(row)
                }
                return innerBag
            }*/
		let tableKit = TableKit<EmptySection, Either<AddressRow, AddressNotFoundRow>>(
			style: .default,
			holdIn: bag
		)

		bag += tableKit.delegate.heightForCell.set { index -> CGFloat in
			switch tableKit.table[index] {
			case .left(let addressRow):
				return addressRow.cellHeight
			case .right(let notFoundROw):
				return notFoundROw.cellHeight
			}
		}

		view.addSubview(tableKit.view)
		tableKit.view.backgroundColor = .brand(.primaryBackground())
		tableKit.view.snp.makeConstraints { make in
			make.top.equalTo(headerBackground.snp.bottom)
			make.bottom.trailing.leading.equalToSuperview()
		}

		bag += addressInput.textSignal.filter { $0 != "" }
			.mapLatestToFuture { text in
				addressState.getSuggestions(
					searchTerm: text,
					suggestion: addressState.pickedSuggestionSignal.value
				)
			}
			.onValue { suggestions in
				var rows: [Either<AddressRow, AddressNotFoundRow>] = suggestions.map {
					.make(AddressRow(suggestion: $0))
				}
				rows.append(.make(AddressNotFoundRow()))
				var table = Table(rows: rows)
				table.removeEmptySections()
				tableKit.set(table, animation: .fade)
			}

		bag += tableKit.delegate.didSelectRow.onValue { row in
			switch row {
			case .left(let addressRow):
				// did select suggestion
				let suggestion = addressRow.suggestion
				addressState.pickedSuggestionSignal.value = suggestion
				addressInput.textSignal.value = addressState.formatAddressLine(from: suggestion)
				print(suggestion.address)
			case .right(let notFoundRow):
				// did select cannot find address
				()
			}
		}

		bag += addressState.pickedSuggestionSignal.onValue { suggestion in

		}

		/*bag += addressInput.textSignal.filter { $0 != "" }.mapLatestToFuture { text in
            addressState.getSuggestions(searchTerm: text, suggestion: addressState.pickedSuggestionSignal.value)
        }
        .onValueDisposePrevious { addressSuggestions -> Disposable? in
            let innerBag = DisposeBag()
            innerBag += addressSuggestions.autoCompleteAddress.map { address -> Disposable in
                let rowWrapper = UIControl()
                let row = KeyValueRow()
                row.valueStyleSignal.value = .brand(.headline(color: .quartenary))
                row.keySignal.value = address.address

                return section.append(row)
            }
            return innerBag
        }*/

		/*bag += addressInput.textSignal.onValue { text in
			bag += addressState.getSuggestions(searchTerm: text, suggestion: addressState.pickedSuggestionSignal.value)
				.map { data in
					data.autoCompleteAddress.map { $0.address }
				}
				.bindTo(resultsSignal)
		}*/

		return (viewController, bag)
	}
}
