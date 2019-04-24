//
//  MoreInfo.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-10.
//

import Flow
import Form
import Foundation
import UIKit

struct MoreInfo {}

extension MoreInfo: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let contentEdgeInsets: CGFloat = 20
        
        let contentViewInsets = UIEdgeInsets(
            top: 20,
            left: contentEdgeInsets,
            bottom: 20,
            right: contentEdgeInsets
        )
        
        let moreInfoStackView = UIStackView()
        moreInfoStackView.spacing = 6
        moreInfoStackView.axis = .vertical
        moreInfoStackView.edgeInsets = contentViewInsets
        
        let selfRiskCheckmark = CheckmarkLabel(
            styledText: StyledText(
                text: String(key: .DASHBOARD_INFO_DEDUCTIBLE),
                style: .bodyOffBlack
            )
        )
        bag += moreInfoStackView.addArranged(selfRiskCheckmark)
        
        let totalInsuranceCheckmark = CheckmarkLabel(
            styledText: StyledText(
                text: String(key: .DASHBOARD_INFO_INSURANCE_AMOUNT),
                style: .bodyOffBlack
            )
        )
        bag += moreInfoStackView.addArranged(totalInsuranceCheckmark)
        
        let travelValidCheckmark = CheckmarkLabel(
            styledText: StyledText(
                text: String(key: .DASHBOARD_INFO_TRAVEL),
                style: .bodyOffBlack
            )
        )
        bag += moreInfoStackView.addArranged(travelValidCheckmark)
        
        return (moreInfoStackView, bag)
    }
}

