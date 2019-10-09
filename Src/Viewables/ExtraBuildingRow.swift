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
        contentView.spacing = 5
        contentView.layoutMargins = UIEdgeInsets(inset: 15)
        
        let titleLabel = UILabel(value: "TODO USE DISPLAY NAME HERE", style: .rowSubtitle)
        contentView.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel(value: "", style: .rowTertitle)
        contentView.addArrangedSubview(subtitleLabel)
                
        bag += data.atOnce().map { (String($0.area), $0.hasWaterConnected) }.onValue({ area, hasWaterConnected in
            let baseText = String(key: .MY_HOME_ROW_SIZE_VALUE(livingSpace: area))
            
            if hasWaterConnected {
                subtitleLabel.text = String(key: .MY_HOME_BUILDING_HAS_WATER_SUFFIX(base: baseText))
            } else {
                subtitleLabel.text = baseText
            }
        })
        
        row.append(contentView)
        
        return (row, bag)
    }
}
