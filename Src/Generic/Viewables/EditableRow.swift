//
//  EditableRow.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-30.
//

import Foundation
import Flow
import Form

/// A row that the user can edit
/// Signal emits everytime save is clicked
struct EditableRow {
    let valueSignal: ReadWriteSignal<String>
    let placeholderSignal: ReadWriteSignal<String>
}

extension EditableRow: Viewable {
    func materialize(events: ViewableEvents) -> (RowView, Signal<String>) {
        let bag = DisposeBag()
        
        let row = RowView()

        let textField = UITextField(
            value: valueSignal.value,
            placeholder: placeholderSignal.value,
            style: .default
        )
        bag += placeholderSignal.atOnce().bindTo(textField, \.placeholder)
        bag += valueSignal.atOnce().bindTo(textField, \.value)
        
        let button = Button(
            title: String(key: .EDITABLE_ROW_EDIT),
            type: .outline(borderColor: .transparent, textColor: .primaryTintColor)
        )
       
        bag += textField.signal(for: .editingDidBegin)
            .map { _ in String(key: .EDITABLE_ROW_SAVE) }
           .bindTo(
               animate: AnimationStyle.easeOut(duration: 0.25),
               button.title,
               \.value
            )
        
        bag += textField.signal(for: .editingDidEnd)
            .map { _ in String(key: .EDITABLE_ROW_EDIT) }
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
            bag += button.onTapSignal.onValue { _ in
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
