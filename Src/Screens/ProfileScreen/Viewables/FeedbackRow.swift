//
//  HomeRow.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct FeedbackRow {
    let presentingViewController: UIViewController
}

extension FeedbackRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: String(key: .PROFILE_FEEDBACK_ROW), style: .rowTitle))

        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)

        row.append(arrow)

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        bag += events.onSelect.onValue {
            let feedback = Feedback()
            self.presentingViewController.present(
                feedback,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension FeedbackRow: Previewable {
    func preview() -> (Feedback, PresentationOptions) {
        let feedback = Feedback()
        return (feedback, [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
