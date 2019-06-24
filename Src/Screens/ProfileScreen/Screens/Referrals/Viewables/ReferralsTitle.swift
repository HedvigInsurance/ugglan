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

struct ReferralsTitle {
    let peopleLeftToInviteSignal: Signal<Int>
}

extension ReferralsTitle: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 8

        let title = MultilineLabel(
            value: "",
            style: TextStyle.standaloneLargeTitle.centerAligned
        )
        
        bag += peopleLeftToInviteSignal.onValue { peopleLeftToInvite in
            title.styledTextSignal.value.text = String(
                key: .REFERRAL_PROGRESS_HEADLINE(numberOfFriendsLeft: String(peopleLeftToInvite))
            )
        }

        bag += view.addArranged(title) { titleView in
            titleView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        let description = MultilineLabel(
            value: String(key: .REFERRAL_PROGRESS_BODY(referralValue: "10")),
            style: TextStyle.bodyOffBlack.centerAligned
        )

        bag += view.addArranged(description) { descriptionView in
            descriptionView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        return (view, bag)
    }
}
