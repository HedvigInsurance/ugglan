//
//  PriceRow.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct PriceRow {}

extension PriceRow: Presentable {
    func materialize() -> (RowView, Disposable) {
        let row = RowView()
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5
        
        let priceLabel = UILabel(value: "109", style: TextStyle.brand(.largeTitle(color: .primary)).centerAligned)
        view.addArrangedSubview(priceLabel)
        
        let perMonthLabel = UILabel(value: "SEK/mo", style: TextStyle.brand(.subHeadline(color: .primary)).centerAligned)
        view.addArrangedSubview(perMonthLabel)
        
        row.append(view)
        
        return (row, bag)
    }
}
