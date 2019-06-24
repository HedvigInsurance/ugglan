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
    let invitationsSignal: Signal<[InvitationsListRow]>
    let peopleLeftToInviteSignal: Signal<Int>
}

extension ReferralsContent: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15

        let referralsProgressBar = ReferralsProgressBar(amountOfBlocks: 20, amountOfCompletedBlocks: 2)
        bag += stackView.addArranged(referralsProgressBar) { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(350)
            }
        }

        let referralsTitle = ReferralsTitle(peopleLeftToInviteSignal: peopleLeftToInviteSignal)
        bag += stackView.addArranged(referralsTitle)

        let referralsCodeContainer = ReferralsCodeContainer(codeSignal: codeSignal)
        bag += stackView.addArranged(referralsCodeContainer)

        let referralsInvitationsTable = ReferralsInvitationsTable(invitationsSignal: invitationsSignal)
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
