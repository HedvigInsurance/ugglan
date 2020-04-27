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
                titleLabel.text = String(key: .REFERRAL_INVITE_EMPTYSTATE_TITLE)
                descriptionLabel.text = String(key: .REFERRAL_INVITE_EMPTYSTATE_DESCRIPTION)
                return bag
            }

            if count > 1 {
                titleLabel.text = String(key: .REFERRAL_INVITE_ANONS)
                descriptionLabel.text = String(key: .REFERRAL_INVITE_OPENEDSTATE)
            } else {
                titleLabel.text = String(key: .REFERRAL_INVITE_ANON)
                descriptionLabel.text = String(key: .REFERRAL_INVITE_OPENEDSTATE)
            }

            return bag
        })
    }
}
