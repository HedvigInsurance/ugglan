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
        style.cursorColor = .primaryTintColor
        style.text = .rowValueEditableMuted
        style.placeholder = .rowValueEditableMuted
    }
    
    static let defaultRight = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .primaryTintColor
        style.text = TextStyle.rowValueEditable.aligned(to: .right)
        style.placeholder = TextStyle.rowValueEditableMuted.aligned(to: .right)
    }

    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .purple
        style.text = .rowValueEditableRight
    }
}
