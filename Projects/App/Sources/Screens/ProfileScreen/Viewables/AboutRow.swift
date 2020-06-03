//
//  AboutRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct AboutRow {
    let presentingViewController: UIViewController
}

extension AboutRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView()
        row.append(UILabel(value: L10n.profileAboutRow, style: .rowTitle))

        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)

        row.append(arrow)

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        bag += events.onSelect.onValue {
            let about = About(state: .loggedIn)
            self.presentingViewController.present(
                about,
                style: .default,
                options: [.autoPop, .largeTitleDisplayMode(.never)]
            )
        }

        return (row, bag)
    }
}

extension AboutRow: Previewable {
    func preview() -> (About, PresentationOptions) {
        let about = About(state: .loggedIn)
        return (about, [.autoPop, .largeTitleDisplayMode(.never)])
    }
}
