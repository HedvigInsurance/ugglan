import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct AddressRow: Hashable {
	let id = UUID()

	static func == (lhs: AddressRow, rhs: AddressRow) -> Bool {
		return lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) { hasher.combine(id) }

	let suggestion: AddressSuggestion
	let addressLine: String
	let postalLine: String?
	var cellHeight: CGFloat { postalLine != nil ? 66 : 54 }
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

		let postalCodeLabel = UILabel(
			value: L10n.ReferallsInviteeStates.invitedYou,
			style: .brand(.subHeadline(color: .secondary))
		)
		postalCodeLabel.animationSafeIsHidden = true
		mainTextContainer.addArrangedSubview(postalCodeLabel)

		return (
			stackView,
			{ `self` in
				addressLabel.value = self.addressLine
				if let postalLine = self.postalLine {
					postalCodeLabel.value = postalLine
					postalCodeLabel.animationSafeIsHidden = false
				}

				return NilDisposer()
			}
		)
	}
}
