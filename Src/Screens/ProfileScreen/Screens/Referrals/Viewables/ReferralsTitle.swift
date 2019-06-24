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
    let incentiveSignal: Signal<Int>
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
        
        bag += peopleLeftToInviteSignal
            .map { String(key: .REFERRAL_PROGRESS_HEADLINE(numberOfFriendsLeft: String($0))) }
            .map { StyledText(text: $0, style: TextStyle.standaloneLargeTitle.centerAligned) }
            .bindTo(title.styledTextSignal)

        bag += view.addArranged(title) { titleView in
            titleView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        let description = MultilineLabel(
            value: "",
            style: TextStyle.bodyOffBlack.centerAligned
        )
        
        bag += incentiveSignal
            .map { String(key: .REFERRAL_PROGRESS_BODY(referralValue: String($0))) }
            .map { StyledText(text: $0, style: TextStyle.bodyOffBlack.centerAligned) }
            .bindTo(description.styledTextSignal)

        bag += view.addArranged(description) { descriptionView in
            descriptionView.snp.makeConstraints { make in
                make.width.equalToSuperview().inset(20)
            }
        }

        return (view, bag)
    }
}
