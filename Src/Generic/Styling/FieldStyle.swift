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
        style.cursorColor = .purple
        style.text = .bodyOffBlack
        style.placeholder = TextStyle.body.restyled { (textStyle: inout TextStyle) in
            textStyle.color = .darkGray
            textStyle.lineHeight = 2.4
        }
    }

    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .purple
        style.text = .rowValueEditableRight
    }
}
