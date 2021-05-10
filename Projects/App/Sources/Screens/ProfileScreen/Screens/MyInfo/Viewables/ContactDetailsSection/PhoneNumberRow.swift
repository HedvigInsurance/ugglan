import Flow
import Form
import Foundation
import hCore
import UIKit

struct PhoneNumberRow { let state: MyInfoState }

extension PhoneNumberRow: Viewable {
	func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
		let bag = DisposeBag()
		let row = RowView(title: L10n.phoneNumberRowTitle, style: .brand(.headline(color: .primary)))

		let textFieldStyle = FieldStyle.editableRow.restyled { (style: inout FieldStyle) in
			style.autocorrection = .no
			style.autocapitalization = .none
			style.keyboard = .phonePad
		}

		let valueTextField = UITextField(value: "", placeholder: "", style: textFieldStyle)
		valueTextField.textContentType = .telephoneNumber

		row.append(valueTextField)

		valueTextField.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.5) }

		bag += valueTextField.isEditingSignal.bindTo(state.isEditingSignal)
		bag += state.phoneNumberSignal.bindTo(valueTextField, \.value)
		bag += valueTextField.bindTo(state.phoneNumberInputValueSignal)

		bag += valueTextField.withLatestFrom(state.phoneNumberSignal).skip(first: 1).filter { $0 != $1 }
			.map { _ in false }.bindTo(state.phoneNumberInputPristineSignal)

		bag += state.onSaveSignal.filter { $0.isSuccess() }.onValue { _ in valueTextField.endEditing(true) }

		return (row, bag)
	}
}
