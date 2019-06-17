//
//  ReferralsTitle.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-18.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsTitle {}

extension ReferralsTitle: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 8

        let title = MultilineLabel(
            styledText: StyledText(
                text: String(key: .REFERRAL_PROGRESS_HEADLINE(numberOfFriendsLeft: "10")),
                style: TextStyle.standaloneLargeTitle.centerAligned
            )
        )

        bag += view.addArranged(title) { titleView in
            titleView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        let description = MultilineLabel(
            styledText: StyledText(
                text: String(key: .REFERRAL_PROGRESS_BODY(referralValue: "10")),
                style: TextStyle.bodyOffBlack.centerAligned
            )
        )

        bag += view.addArranged(description) { descriptionView in
            descriptionView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        return (view, bag)
    }
}
