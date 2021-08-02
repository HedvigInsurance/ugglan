import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

enum AddressAutocompleteError: Error {
	case cantFindAddress
}

struct EmbarkAddressAutocomplete: AddressTransitionable {
	var boxFrame: ReadWriteSignal<CGRect?> = ReadWriteSignal(CGRect.zero)
	let setIsFirstResponderSignal = ReadWriteSignal<Bool>(true)
	let box = UIControl()
	let state: EmbarkState
	let data: EmbarkAddressAutocompleteData
	let resultsSignal = ReadWriteSignal<[String]>([])
	let searchSignal = ReadWriteSignal<String>("")

	let addressState: AddressState
}

func ignoreNBSP(lhs: String, rhs: String) -> Bool {
	let cleanedLhs = lhs.replacingOccurrences(of: "\u{00a0}", with: " ")
	let cleanedRhs = rhs.replacingOccurrences(of: "\u{00a0}", with: " ")
	return cleanedLhs == cleanedRhs
}

func removeNBSP(from string: String) -> String {
	return string.replacingOccurrences(of: "\u{00a0}", with: " ")
}

extension EmbarkAddressAutocomplete: Presentable {
	func materialize() -> (UIViewController, Future<String?>) {
		let viewController = UIViewController()
		viewController.title = "Address"
		let bag = DisposeBag()

		let view = UIView()
		view.backgroundColor = .brand(.primaryBackground())
		viewController.view = view

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

		var addressInput = AddressInput(placeholder: data.addressAutocompleteActionData.placeholder, addressState: addressState)
		bag += box.add(addressInput) { addressInputView in
			addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
		}
		//bag += addressInput.textSignal.bindTo(textSignal)
		//bag += setTextSignal.onValue { newText in
		//	addressInput.text = newText
		//}

		bag += setIsFirstResponderSignal.bindTo(addressInput.setIsFirstResponderSignal)

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

		bag +=
			searchSignal.mapLatestToFuture { text in
				addressState.getSuggestions(
					searchTerm: text,
					suggestion: addressState.pickedSuggestionSignal.value
				)
			}
			.onValue { suggestions in
				var rows: [Either<AddressRow, AddressNotFoundRow>] = suggestions.map {
					.make(
						AddressRow(
							suggestion: $0,
							addressLine: addressState.formatAddressLine(from: $0),
							postalLine: addressState.formatPostalLine(from: $0)
						)
					)
				}
				rows.append(.make(AddressNotFoundRow()))
				var table = Table(rows: rows)
				table.removeEmptySections()
				tableKit.set(table, animation: .fade)
			}

		bag +=
            combineLatest(addressState.textSignal.atOnce().plain(), view.didLayoutSignal)
            .map { $0.0 }
			.distinct(ignoreNBSP)
			.filter { $0 != "" }
			.bindTo(searchSignal)

		bag += addressState.pickedSuggestionSignal
			.compactMap { $0 }
			.map { addressState.formatAddressLine(from: $0) }
			.onValue { addressLine in
                if ignoreNBSP(lhs: addressLine, rhs: addressState.textSignal.value) {
					searchSignal.value = addressLine
				} else {
                    addressState.textSignal.value = addressLine
				}
			}

		return (
			viewController,
			Future { completion in
				bag += tableKit.delegate.didSelectRow.onValueDisposePrevious { row -> Disposable? in
					let innerBag = DisposeBag()
					switch row {
					case .left(let addressRow):
						// did select suggestion
						let suggestion = addressRow.suggestion
						innerBag +=
							addressState.confirm(
								suggestion,
								withPreviousSuggestion: addressState
									.pickedSuggestionSignal.value
							)
							.valueSignal.compactMap { $0 }
							.bindTo(addressState.confirmedSuggestionSignal)
						addressState.pickedSuggestionSignal.value = suggestion
					case .right(_):
						// did select cannot find address
						completion(.failure(AddressAutocompleteError.cantFindAddress))
					}
					return innerBag
				}

				bag += addressState.confirmedSuggestionSignal.compactMap { $0 }
					.onValue { address in
                        addressState.textSignal.value = addressState.formatAddressLine(from: address)
						completion(.success(address.address))
					}

				return bag
			}
		)
	}
}
