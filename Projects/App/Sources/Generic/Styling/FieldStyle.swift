import Flow
import Form
import Foundation
import UIKit

extension FieldStyle {
    static let `default` = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brand(.primaryText())
        style.text = UIColor.brandStyle(.secondaryText)
        style.placeholder = UIColor.brandStyle(.secondaryText)
    }

    static let defaultRight = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brand(.primaryText())
        style.text = UIColor.brandStyle(.secondaryText).aligned(to: .right)
        style.placeholder = UIColor.brandStyle(.secondaryText).aligned(to: .right)
    }

    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brand(.primaryText())
        style.text = UIColor.brandStyle(.secondaryText).aligned(to: .right)
    }
}
