//
//  CheckmarkLabel.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-10.
//

import Flow
import Form
import Foundation
import UIKit

struct CheckmarkLabel {
    let styledTextSignal: ReadWriteSignal<StyledText>
    
    init(styledText: StyledText) {
        self.styledTextSignal = ReadWriteSignal(styledText)
    }
}

extension CheckmarkLabel: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        
        view.spacing = 10
        
        let icon = Icon(
            icon: Asset.greenCircularCheckmark,
            iconWidth: 15
        )
        view.addArrangedSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(icon.iconWidth)
        }
        
        let label = MultilineLabel(styledText: styledTextSignal.value)
        bag += styledTextSignal.atOnce().bindTo(label.styledTextSignal)
        
        bag += view.addArranged(label) { labelView in
            labelView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
            }
        }
        
        return (view, bag)
    }
}
