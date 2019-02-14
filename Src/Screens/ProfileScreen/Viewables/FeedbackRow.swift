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
        row.append(UILabel(value: "Feedback", style: .rowTitle))
        
        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)
        
        row.append(arrow)
        
        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        bag += events.onSelect.onValue {
            let about = Feedback(presentingViewController: self.presentingViewController)
            self.presentingViewController.present(
                about,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }
        
        return (row, bag)
    }
}

