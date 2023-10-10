import Flow
import Form
import Foundation
import UIKit

extension FieldStyle {
    static let `default` = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brandNew(.primaryText())
        style.text = UIColor.brandNewStyle(.secondaryText)
        style.placeholder = UIColor.brandNewStyle(.secondaryText)
    }

    static let defaultRight = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brandNew(.primaryText())
        style.text = UIColor.brandNewStyle(.secondaryText).aligned(to: .right)
        style.placeholder = UIColor.brandNewStyle(.secondaryText).aligned(to: .right)
    }

    static let editableRow = FieldStyle.default.restyled { (style: inout FieldStyle) in
        style.cursorColor = .brandNew(.primaryText())
        style.text = UIColor.brandNewStyle(.secondaryText).aligned(to: .right)
    }
}
