//
//  ReferralsCodeContainer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Foundation
import Flow
import UIKit
import Form

struct ReferralsCodeContainer {}

extension TextStyle {
    func lineHeight(_ lineHeight: CGFloat) -> TextStyle {
        return restyled { (style: inout TextStyle) in
            style.lineHeight = lineHeight
        }
    }
}

extension ReferralsCodeContainer: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        
        let titleLabel = MultilineLabel(value: "Din kod", style: TextStyle.centeredBodyOffBlack)
        bag += stackView.addArranged(titleLabel)
        
        let referralsCode = ReferralsCode()
        bag += stackView.addArranged(referralsCode)
        
        return (stackView, bag)
        
    }
}
