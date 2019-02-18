//
//  EmailRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct EmailRow {
    let state: MyInfoState
}

extension EmailRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: String(.EMAIL_ROW_TITLE), style: .rowTitle)

        let textFieldStyle = FieldStyle.editableRow.restyled { (style: inout FieldStyle) in
            style.autocorrection = .no
            style.autocapitalization = .none
            style.keyboard = .emailAddress
        }

        let valueTextField = UITextField(
            value: "",
            placeholder: "",
            style: textFieldStyle
        )

        if #available(iOS 10.0, *) {
            valueTextField.textContentType = .emailAddress
        }

        row.append(valueTextField)

        valueTextField.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        bag += valueTextField.shouldReturn.set { _ in
            bag += self.state.save()
            return true
        }

        bag += valueTextField.isEditingSignal.bindTo(state.isEditingSignal)
        bag += state.emailSignal.bindTo(valueTextField, \.value)
        bag += valueTextField.bindTo(state.emailInputValueSignal)

        bag += state.onSaveSignal.filter { $0.isSuccess() }.onValue { _ in
            valueTextField.endEditing(true)
        }

        return (row, bag)
    }
}
