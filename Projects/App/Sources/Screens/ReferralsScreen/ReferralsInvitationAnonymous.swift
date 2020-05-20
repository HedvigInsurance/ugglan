//
//  ReferralsInvitationAnonymous.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Flow
import Form
import Foundation
import UIKit
import hCore

struct ReferralsInvitationAnonymous: Reusable {
    let count: Int?

    static func makeAndConfigure() -> (make: UIView, configure: (ReferralsInvitationAnonymous) -> Disposable) {
        let view = UIStackView()
        view.spacing = 10

        let ghostIconContainer = UIView()

        let ghostIcon = Icon(icon: Asset.ghost, iconWidth: 40)
        ghostIconContainer.addSubview(ghostIcon)

        ghostIcon.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.center.equalToSuperview()
        }

        view.addArrangedSubview(ghostIconContainer)

        ghostIconContainer.snp.makeConstraints { make in
            make.width.equalTo(50)
        }

        let contentContainer = UIStackView()
        contentContainer.axis = .vertical
        contentContainer.spacing = 5

        let titleLabel = UILabel(value: "", style: .rowTitleBold)
        contentContainer.addArrangedSubview(titleLabel)

        let descriptionLabel = UILabel(value: "", style: .rowSubtitle)
        contentContainer.addArrangedSubview(descriptionLabel)

        view.addArrangedSubview(contentContainer)

        return (view, { invitation in
            let bag = DisposeBag()

            guard let count = invitation.count else {
                titleLabel.text = L10n.referralInviteEmptystateTitle
                descriptionLabel.text = L10n.referralInviteEmptystateDescription
                return bag
            }

            if count > 1 {
                titleLabel.text = L10n.referralInviteAnons
                descriptionLabel.text = L10n.referralInviteOpenedstate
            } else {
                titleLabel.text = L10n.referralInviteAnon
                descriptionLabel.text = L10n.referralInviteOpenedstate
            }

            return bag
        })
    }
}
