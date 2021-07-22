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
	var cellHeight: CGFloat = 54
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

		let invitedByOtherLabel = UILabel(
			value: L10n.ReferallsInviteeStates.invitedYou,
			style: .brand(.subHeadline(color: .secondary))
		)
		invitedByOtherLabel.animationSafeIsHidden = true
		mainTextContainer.addArrangedSubview(invitedByOtherLabel)

		return (
			stackView,
			{ `self` in
				addressLabel.value = self.suggestion.address
				// If has postal code etc.
				//invitedByOtherLabel.animationSafeIsHidden = !self.invitation.invitedByOther

				return NilDisposer()
			}
		)
	}
}
