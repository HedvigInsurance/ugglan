import Form
import Foundation
import UIKit

extension DynamicSectionStyle {
    // sets row insets to provided UIEdgeInsets
    public func rowInsets(_ insets: UIEdgeInsets) -> DynamicSectionStyle {
        self.restyled { (style: inout SectionStyle) in
            style.rowInsets = insets
        }
    }
}
