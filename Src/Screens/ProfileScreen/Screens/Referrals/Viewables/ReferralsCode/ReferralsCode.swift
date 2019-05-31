//
//  ReferralsCode.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Foundation
import Flow
import UIKit
import Form

struct ReferralsCode {}

extension ReferralsCode: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.offLightGray.cgColor
        view.layer.borderWidth = 1
        
        bag += view.didLayoutSignal.onValue { _ in
            view.layer.cornerRadius = view.frame.height / 2
        }
        
        let code = "HDVG87"
        
        bag += view.copySignal.onValue { _ in
            UIPasteboard.general.value = code
        }
        
        let codeContainer = UIStackView()
        codeContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 5)
        codeContainer.isLayoutMarginsRelativeArrangement = true
        
        let codeTextStyle = TextStyle(font: HedvigFonts.circularStdBold!, color: UIColor.purple).centerAligned.lineHeight(2.4).resized(to: 16).restyled { (style: inout TextStyle) in
            style.highlightedColor = .darkPurple
        }
        
        let codeLabel = MultilineLabel(value: code, style: codeTextStyle)
        bag += codeContainer.addArranged(codeLabel)
        view.addSubview(codeContainer)
        
        codeContainer.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }
        
        return (view, bag)
    }
}
