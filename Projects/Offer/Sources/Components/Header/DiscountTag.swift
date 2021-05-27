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

struct DiscountTag {
    @Inject var state: OfferState
}

extension DiscountTag: Presentable {
    func materialize() -> (UIView, Disposable) {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .tint(.lavenderOne)
        let bag = DisposeBag()
        
        let horizontalCenteringStackView = UIStackView()
        horizontalCenteringStackView.edgeInsets = UIEdgeInsets(inset: 10)
        horizontalCenteringStackView.axis = .vertical
        horizontalCenteringStackView.alignment = .center
        horizontalCenteringStackView.distribution = .equalCentering
        view.addSubview(horizontalCenteringStackView)
        
        horizontalCenteringStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 2
        contentStackView.alignment = .center
        contentStackView.distribution = .equalCentering
        horizontalCenteringStackView.addArrangedSubview(contentStackView)
        
        let textStyle = TextStyle.brand(.caption1(color: .primary(state: .positive))).centerAligned.uppercased
        
        let titleLabel = UILabel(
            value: "",
            style: textStyle
        )
        contentStackView.addArrangedSubview(titleLabel)
        
        bag += state.dataSignal.map { $0.redeemedCampaigns.first }.onValue { campaign in
            guard let displayValue = campaign?.displayValue else {
                view.isHidden = true
                return
            }
            
            view.isHidden = false
            titleLabel.value = displayValue
        }
                
        return (view, bag)
    }
}
