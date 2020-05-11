//
//  ExtraBuildingRow.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-07.
//

import Flow
import Form
import Foundation
import UIKit
import Core

struct ExtraBuildingRow {
    let data: ReadWriteSignal<ExtraBuildingFragment>
}

extension ExtraBuildingRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 5
        contentView.layoutMargins = UIEdgeInsets(inset: 15)

        let titleLabel = UILabel(value: "", style: .rowTitle)
        contentView.addArrangedSubview(titleLabel)

        bag += data.atOnce().map { $0.displayName }.onValue { displayName in
            titleLabel.text = displayName
        }

        let subtitleLabel = UILabel(value: "", style: .rowSubtitle)
        contentView.addArrangedSubview(subtitleLabel)

        bag += data.atOnce().map { (String($0.area), $0.hasWaterConnected) }.onValue { area, hasWaterConnected in
            let baseText = L10n.myHomeRowSizeValue(area)

            if hasWaterConnected {
                subtitleLabel.text = L10n.myHomeBuildingHasWaterSuffix(baseText)
            } else {
                subtitleLabel.text = baseText
            }
        }

        row.append(contentView)

        return (row, bag)
    }
}
