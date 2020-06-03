//
//  EditableRow.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-30.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

/// A row that the user can edit
/// Signal emits everytime save is clicked
struct EditableRow {
    let valueSignal: ReadWriteSignal<String>
    let placeholderSignal: ReadWriteSignal<String>
}

extension EditableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Signal<String>) {
        let bag = DisposeBag()

        let row = RowView()

        let textField = UITextField(
            value: valueSignal.value,
            placeholder: placeholderSignal.value,
            style: .default
        )
        textField.autocorrectionType = .no

        bag += placeholderSignal.atOnce().bindTo(textField, \.placeholder)
        bag += valueSignal.atOnce().bindTo(textField, \.value)

        let button = Button(
            title: L10n.editableRowEdit,
            type: .outline(borderColor: .transparent, textColor: .primaryTintColor)
        )

        bag += textField.signal(for: .editingDidBegin)
            .map { _ in L10n.editableRowSave }
            .bindTo(
                animate: AnimationStyle.easeOut(duration: 0.25),
                button.title,
                \.value
            )

        bag += textField.signal(for: .editingDidEnd)
            .map { _ in L10n.editableRowEdit }
            .bindTo(
                animate: AnimationStyle.easeOut(duration: 0.25),
                button.title,
                \.value
            )

        row.append(textField)

        bag += row.append(
            button
        )

        return (row, Signal { callback in
            bag += merge(
                textField.signal(for: .primaryActionTriggered),
                button.onTapSignal
            ).onValue { _ in
                if textField.isFirstResponder {
                    callback(textField.value)
                    textField.resignFirstResponder()
                } else {
                    textField.becomeFirstResponder()
                }
            }

            return bag
        })
    }
}
