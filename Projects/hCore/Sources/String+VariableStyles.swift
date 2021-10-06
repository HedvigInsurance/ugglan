import Form
import Foundation
import UIKit

extension String {
    // applies a text style to a subset of a string
    // - fallbackStyle: TextStyle to apply to the rest of the text
    public func attributedStringWithVariableStyles(
        _ variables: [String: TextStyle],
        fallbackStyle: TextStyle
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(text: self, style: fallbackStyle)
        for variable in variables {
            let range = (self as NSString).range(of: variable.key)

            for attribute in variable.value.attributes {
                attributedString.addAttribute(attribute.key, value: attribute.value, range: range)
            }
        }

        return attributedString
    }
}
