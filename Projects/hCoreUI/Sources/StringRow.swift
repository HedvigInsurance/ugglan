import Flow
import Form
import Foundation
import UIKit

public struct StringRow {
    public let value: String
    public let style: TextStyle

    public init(
        value: String,
        style: TextStyle = .brand(.body(color: .primary))
    ) {
        self.value = value
        self.style = style
    }
}

extension StringRow: Equatable, Hashable { public func hash(into hasher: inout Hasher) { hasher.combine(value) } }

extension StringRow: Reusable {
    public static func makeAndConfigure() -> (make: UIView, configure: (StringRow) -> Disposable) {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.insetsLayoutMarginsFromSafeArea = false
        view.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let label = UILabel(value: "", style: .default)
        view.addArrangedSubview(label)

        return (
            view,
            { `self` in label.style = self.style
                label.value = self.value
                return NilDisposer()
            }
        )
    }
}
