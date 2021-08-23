import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct AddressNotFoundRow: Hashable {
    let id = UUID()
    var cellHeight: CGFloat = 54
}

extension AddressNotFoundRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (AddressNotFoundRow) -> Disposable) {
        let stackView = UIStackView()
        stackView.spacing = 10

        let mainTextContainer = UIStackView()
        mainTextContainer.axis = .vertical
        mainTextContainer.alignment = .leading
        stackView.addArrangedSubview(mainTextContainer)

        mainTextContainer.snp.makeConstraints { make in make.width.equalToSuperview().priority(.medium) }

        let addressLabel = UILabel(value: "", style: .brand(.headline(color: .destructive)))
        mainTextContainer.addArrangedSubview(addressLabel)

        return (
            stackView,
            { `self` in
                addressLabel.value = L10n.embarkAddressAutocompleteNoAddress

                return NilDisposer()
            }
        )
    }
}
