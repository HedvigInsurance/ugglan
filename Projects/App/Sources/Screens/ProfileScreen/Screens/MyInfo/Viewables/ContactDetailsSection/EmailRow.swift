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
import UIKit

struct EmailRow {
    let state: MyInfoState
}

extension EmailRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: L10n.emailRowTitle, style: .rowTitle)

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
        valueTextField.textContentType = .emailAddress

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

        bag += valueTextField
            .withLatestFrom(state.emailSignal)
            .skip(first: 1)
            .filter { $0 != $1 }
            .map { _ in false }
            .bindTo(state.emailInputPristineSignal)

        bag += valueTextField.bindTo(state.emailInputValueSignal)

        bag += state.onSaveSignal.filter { $0.isSuccess() }.onValue { _ in
            valueTextField.endEditing(true)
        }

        return (row, bag)
    }
}
