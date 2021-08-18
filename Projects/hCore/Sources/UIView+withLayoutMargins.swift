import Foundation
import UIKit

extension UIView {
    public func withLayoutMargins(_ layoutMargins: UIEdgeInsets) -> UIStackView {
        let stackView = UIStackView()
        stackView.edgeInsets = layoutMargins
        stackView.addArrangedSubview(self)
        return stackView
    }
}
