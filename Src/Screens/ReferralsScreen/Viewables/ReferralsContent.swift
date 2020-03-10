//
//  ReferralsContent.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-19.
//

import Flow
import Foundation
import UIKit
import ComponentKit

struct ReferralsContent {
    let codeSignal: Signal<String>
    let referredBySignal: ReadSignal<InvitationsListRow?>
    let invitationsSignal: ReadSignal<[InvitationsListRow]?>
    let peopleLeftToInviteSignal: ReadSignal<Int?>
    let incentiveSignal: ReadSignal<Int?>
    let netPremiumSignal: ReadSignal<Int?>
    let grossPremiumSignal: ReadSignal<Int?>
    let presentingViewController: UIViewController
}

extension ReferralsContent: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15

        let progressBarContainer = UIStackView()

        bag += grossPremiumSignal.compactMap { $0 }.distinct().onValueDisposePrevious { grossPremium in
            let innerBag = DisposeBag()

            if grossPremium > 200 {
                let referralsProgressHighPremium = ReferralsProgressHighPremium(
                    grossPremiumSignal: self.grossPremiumSignal,
                    netPremiumSignal: self.netPremiumSignal
                )
                innerBag += progressBarContainer.addArranged(referralsProgressHighPremium)
            } else {
                let referralsProgressBar = ReferralsProgressBar(
                    incentiveSignal: self.incentiveSignal,
                    grossPremiumSignal: self.grossPremiumSignal,
                    netPremiumSignal: self.netPremiumSignal
                )
                innerBag += progressBarContainer.addArranged(referralsProgressBar)
            }

            return innerBag
        }

        stackView.addArrangedSubview(progressBarContainer)

        let referralsTitle = ReferralsTitle(
            peopleLeftToInviteSignal: peopleLeftToInviteSignal,
            incentiveSignal: incentiveSignal
        )
        bag += stackView.addArranged(referralsTitle)

        let referralsCodeContainer = ReferralsCodeContainer(codeSignal: codeSignal, presentingViewController: presentingViewController)
        bag += stackView.addArranged(referralsCodeContainer)

        let referralsInvitationsTable = ReferralsInvitationsTable(referredBySignal: referredBySignal, invitationsSignal: invitationsSignal)
        bag += stackView.addArranged(referralsInvitationsTable) { tableView in
            bag += tableView.didLayoutSignal.onValue { _ in
                bag += referralsInvitationsTable.changedDataSignal.onValue { _ in
                    tableView.snp.remakeConstraints { make in
                        make.height.equalTo(tableView.contentSize.height)
                    }
                }
            }
        }

        return (stackView, bag)
    }
}
