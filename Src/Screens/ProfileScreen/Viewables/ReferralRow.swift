//
//  ReferralRow.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-15.
//

import Flow
import Foundation
import Presentation
import UIKit

struct ReferralRow {
    let presentingViewController: UIViewController
}

extension ReferralRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let incentive = RemoteConfigContainer().referralsIncentive()

        let row = IconRow(
            title: String(.REFERRALS_ROW_TITLE),
            subtitle: String(.REFERRALS_ROW_SUBTITLE(incentive: String(incentive))),
            iconAsset: Asset.share,
            options: [.withArrow, .whiteContent]
        )

        bag += events.onSelect.onValue { _ in
            self.presentingViewController.present(
                Referrals(),
                options: [.largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}
