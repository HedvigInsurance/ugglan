//
//  AppSection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit
import hCore

struct OtherSection {
    let presentingViewController: UIViewController
}

extension OtherSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(
            header: L10n.otherSectionTitle,
            footer: nil,
            style: .sectionPlain
        )

        let aboutRow = AboutRow(presentingViewController: presentingViewController)
        bag += section.append(aboutRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: aboutRow
            )
        }

        return (section, bag)
    }
}
