//
//  ReferralsContent.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-19.
//

import Flow
import Foundation
import UIKit

struct ReferralsContent {
    let codeSignal: Signal<String>
    let referredBySignal: Signal<InvitationsListRow?>
    let invitationsSignal: Signal<[InvitationsListRow]>
    let peopleLeftToInviteSignal: Signal<Int>
    let incentiveSignal: Signal<Int>
    let netPremiumSignal: Signal<Int>
    let grossPremiumSignal: Signal<Int>
}

extension ReferralsContent: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15

        let referralsProgressBar = ReferralsProgressBar(
            incentiveSignal: incentiveSignal,
            grossPremiumSignal: grossPremiumSignal,
            netPremiumSignal: netPremiumSignal
        )
        bag += stackView.addArranged(referralsProgressBar)

        let referralsTitle = ReferralsTitle(
            peopleLeftToInviteSignal: peopleLeftToInviteSignal,
            incentiveSignal: incentiveSignal
        )
        bag += stackView.addArranged(referralsTitle)

        let referralsCodeContainer = ReferralsCodeContainer(codeSignal: codeSignal)
        bag += stackView.addArranged(referralsCodeContainer)

        let referralsInvitationsTable = ReferralsInvitationsTable(referredBySignal: referredBySignal, invitationsSignal: invitationsSignal)
        bag += stackView.addArranged(referralsInvitationsTable) { tableView in
            bag += tableView.didLayoutSignal.onValue { _ in
                tableView.snp.remakeConstraints { make in
                    make.height.equalTo(tableView.contentSize.height)
                }
            }
        }

        return (stackView, bag)
    }
}
