//
//  ReferralsInvitation.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsInvitation: Reusable {
    enum InviteState {
        case onboarding, member, left, invitedYou

        var description: String {
            switch self {
            case .invitedYou:
                return L10n.referralInviteInvitedyoustate
            case .onboarding:
                return L10n.referralInviteStartedstate
            case .member:
                return L10n.referralInviteNewstate
            case .left:
                return L10n.referralInviteQuitstate
            }
        }
    }

    let name: String?
    let state: InviteState

    static let circleSize = 32

    static func makeAndConfigure() -> (make: UIView, configure: (ReferralsInvitation) -> Disposable) {
        let view = UIStackView()
        view.spacing = 12

        let circleContainer = UIView()
        circleContainer.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(circleSize)
        }

        view.addArrangedSubview(circleContainer)

        let circle = UIView()
        circleContainer.addSubview(circle)
        circle.layer.cornerRadius = CGFloat(circleSize / 2)

        circle.snp.makeConstraints { make in
            make.width.equalTo(circleSize)
            make.height.equalTo(circleSize)
            make.center.equalToSuperview()
        }

        let circleLabel = UILabel()
        circle.addSubview(circleLabel)

        circleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        let contentContainer = UIStackView()
        contentContainer.axis = .vertical
        contentContainer.spacing = 5

        let titleLabel = UILabel(value: "", style: .rowTitleBold)
        contentContainer.addArrangedSubview(titleLabel)

        let descriptionLabel = UILabel(value: "", style: .rowSubtitle)
        contentContainer.addArrangedSubview(descriptionLabel)

        view.addArrangedSubview(contentContainer)

        let iconContainer = UIStackView()

        view.addArrangedSubview(iconContainer)

        return (view, { invitation in
            let bag = DisposeBag()

            let textStyle = TextStyle(
                font: HedvigFonts.favoritStdBook!,
                color: UIColor.white
            ).resized(to: 16).lineHeight(20).centerAligned

            if let name = invitation.name {
                circleLabel.styledText = StyledText(text: String(name.prefix(1)), style: textStyle)
                circle.backgroundColor = String(name.prefix(1)).hedvigColor
                titleLabel.text = name
            } else {
                titleLabel.text = L10n.referralInviteAnons
            }

            descriptionLabel.text = invitation.state.description

            iconContainer.subviews.forEach { subview in
                subview.removeFromSuperview()
            }

            switch invitation.state {
            case .onboarding:
                bag += iconContainer.addArranged(ReferralsInvitationOnboardingIcon())

                iconContainer.snp.remakeConstraints { make in
                    make.width.equalTo(16)
                }
            case .member, .invitedYou:
                bag += iconContainer.addArranged(ReferralsInvitationMemberIcon())

                iconContainer.snp.remakeConstraints { make in
                    make.width.equalTo(76)
                }
            case .left:
                bag += iconContainer.addArranged(ReferralsInvitationLeftIcon())

                iconContainer.snp.remakeConstraints { make in
                    make.width.equalTo(16)
                }
            }

            return bag
        })
    }
}
