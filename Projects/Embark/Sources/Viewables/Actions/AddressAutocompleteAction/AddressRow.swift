import Flow
import Form
import Foundation
import UIKit
import hCore

struct AddressRow: Hashable {
    let address: String
    let cellHeight: CGFloat = 54
}

extension AddressRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (AddressRow) -> Disposable) {
        let stackView = UIStackView()
        stackView.spacing = 10

        let mainTextContainer = UIStackView()
        mainTextContainer.axis = .vertical
        mainTextContainer.alignment = .leading
        stackView.addArrangedSubview(mainTextContainer)

        mainTextContainer.snp.makeConstraints { make in make.width.equalToSuperview().priority(.medium) }

        let addressLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        mainTextContainer.addArrangedSubview(addressLabel)

        return (
            stackView,
            { `self` in addressLabel.value = self.address
                return NilDisposer()
            }
        )
    }
}
