import Flow
import Form
import Foundation
import UIKit
import hCore

struct InvitationRow: Hashable {
	let invitation: ForeverInvitation
	var cellHeight: CGFloat { invitation.invitedByOther ? 66 : 54 }
}

extension InvitationRow: Reusable {
	static func makeAndConfigure() -> (make: UIView, configure: (InvitationRow) -> Disposable) {
		let stackView = UIStackView()
		stackView.spacing = 10

		let iconContainer = UIView()

		let iconImageView = UIImageView()
		iconImageView.contentMode = .scaleAspectFill
		iconContainer.addSubview(iconImageView)

		iconImageView.snp.makeConstraints { make in make.height.width.equalTo(18)
			make.center.equalToSuperview()
		}

		stackView.addArrangedSubview(iconContainer)

		iconContainer.snp.makeConstraints { make in make.width.equalTo(18) }

		let mainTextContainer = UIStackView()
		mainTextContainer.axis = .vertical
		mainTextContainer.alignment = .leading
		stackView.addArrangedSubview(mainTextContainer)

		mainTextContainer.snp.makeConstraints { make in make.width.equalToSuperview().priority(.medium) }

		let nameLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
		mainTextContainer.addArrangedSubview(nameLabel)

		let invitedByOtherLabel = UILabel(
			value: L10n.ReferallsInviteeStates.invitedYou,
			style: .brand(.subHeadline(color: .secondary))
		)
		invitedByOtherLabel.animationSafeIsHidden = true
		mainTextContainer.addArrangedSubview(invitedByOtherLabel)

		let discountAmountLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
		stackView.addArrangedSubview(discountAmountLabel)

		return (
			stackView,
			{ `self` in nameLabel.value = self.invitation.name
				invitedByOtherLabel.animationSafeIsHidden = !self.invitation.invitedByOther

				switch self.invitation.state {
				case .active:
					iconImageView.image = Asset.activeInvite.image
					discountAmountLabel.value = self.invitation.discount?.formattedAmount ?? ""
					nameLabel.style = .brand(.headline(color: .primary))
					discountAmountLabel.style = .brand(.headline(color: .primary))
					invitedByOtherLabel.style = .brand(.subHeadline(color: .secondary))
				case .pending:
					iconImageView.image = Asset.pendingInvite.image
					nameLabel.style = .brand(.headline(color: .primary))
					discountAmountLabel.value = L10n.ReferallsInviteeStates.awaiting
					discountAmountLabel.style = .brand(.headline(color: .tertiary))
					invitedByOtherLabel.style = .brand(.subHeadline(color: .secondary))
				case .terminated:
					iconImageView.image = Asset.terminatedInvite.image
					iconImageView.tintColor = .brand(.tertiaryText)
					nameLabel.style = .brand(.headline(color: .tertiary))
					discountAmountLabel.value = L10n.ReferallsInviteeStates.terminated
					discountAmountLabel.style = .brand(.headline(color: .tertiary))
					invitedByOtherLabel.style = .brand(.subHeadline(color: .tertiary))
				}

				return NilDisposer()
			}
		)
	}
}
