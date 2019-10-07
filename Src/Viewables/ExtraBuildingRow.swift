//
//  ExtraBuildingRow.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-07.
//

import Foundation
import Flow
import UIKit
import Form

struct ExtraBuildingRow {
    let data: ReadWriteSignal<MyHomeQuery.Data.Insurance.ExtraBuilding>
}

extension ExtraBuildingRow: Viewable {
    func materialize(events: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()
        
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.layoutMargins = UIEdgeInsets(inset: 15)
        
        let titleLabel = UILabel(value: "Garage", style: .rowSubtitle)
        contentView.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel(value: "", style: .rowTertitle)
        contentView.addArrangedSubview(subtitleLabel)
        
        bag += data.atOnce().map { String($0.area) }.onValue({ area in
            subtitleLabel.text = area
        })
        
        row.append(contentView)
        
        return (row, bag)
    }
}
