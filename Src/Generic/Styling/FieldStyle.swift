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
    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .purple
        style.text = .rowValueEditableRight
    }
}
