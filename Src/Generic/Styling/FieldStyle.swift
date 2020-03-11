//
//  TextFieldStyle.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-16.
//

import Flow
import Form
import Foundation
import UIKit

extension FieldStyle {
    static let `default` = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .hedvig(.primaryTintColor)
        style.text = .rowValueEditableMuted
        style.placeholder = .rowValueEditablePlaceholder
    }

    static let defaultRight = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .hedvig(.primaryTintColor)
        style.text = TextStyle.rowValueEditableMuted.aligned(to: .right)
        style.placeholder = TextStyle.rowValueEditablePlaceholder.aligned(to: .right)
    }

    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .hedvig(.primaryTintColor)
        style.text = .rowValueEditableRight
    }
}
