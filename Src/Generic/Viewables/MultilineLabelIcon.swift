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

struct MultilineLabelIcon {
    let styledTextSignal: ReadWriteSignal<StyledText>
    let iconAsset: ImageAsset
    let iconWidth: CGFloat
    
    init(styledText: StyledText, icon: ImageAsset, iconWidth: CGFloat) {
        self.styledTextSignal = ReadWriteSignal(styledText)
        self.iconAsset = icon
        self.iconWidth = iconWidth
    }
}

extension MultilineLabelIcon: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        
        view.spacing = 10
        
        let icon = Icon(
            icon: iconAsset,
            iconWidth: iconWidth
        )
        view.addArrangedSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(iconWidth)
            make.height.equalTo(iconWidth + 4)
        }
        
        let label = MultilineLabel(styledText: styledTextSignal.value)
        bag += styledTextSignal.atOnce().bindTo(label.styledTextSignal)
        
        bag += view.addArranged(label) { labelView in
            bag += label.intrinsicContentSizeSignal.onValue { contentSize in
                labelView.snp.makeConstraints { make in
                    make.height.equalTo(contentSize.height)
                }
            }
        }
        
        return (view, bag)
    }
}
