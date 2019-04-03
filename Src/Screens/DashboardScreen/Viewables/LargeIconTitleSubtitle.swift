//
//  LargeIconTitleSubtitle.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-03.
//

import Flow
import Form
import Foundation
import UIKit

struct LargeIconTitleSubtitle {
    let titleText: String
    let iconAsset: ImageAsset
    
    let iconWidth: CGFloat = 75
    let subtitleText = "försäkras för"
    
    init(
        title: String,
        icon: ImageAsset
        ) {
        self.titleText = title
        self.iconAsset = icon
    }
}

extension LargeIconTitleSubtitle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackViewEdgeInsets = UIEdgeInsets(
            top: 12,
            left: 15,
            bottom: 12,
            right: 25
        )
        
        let containerStackView = UIStackView(
            views: [],
            axis: .horizontal,
            spacing: 20,
            edgeInsets: stackViewEdgeInsets
        )
        
        containerStackView.alignment = .center
        containerStackView.isLayoutMarginsRelativeArrangement = true
        
        // Large icon
        let icon = Icon(frame: .zero, icon: iconAsset, iconWidth: iconWidth)
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(icon)
        
        // Title+subtitle
        let titlesView = UIStackView()
        titlesView.axis = .vertical
        titlesView.backgroundColor = .blue
        titlesView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let titleLabel = MultilineLabel(styledText: StyledText(text: titleText, style: .rowTitle))
        bag += titlesView.addArranged(titleLabel)
        
        let subtitleLabel = MultilineLabel(styledText: StyledText(text: subtitleText, style: .rowSubtitle))
        bag += titlesView.addArranged(subtitleLabel)
        
        containerStackView.addArrangedSubview(titlesView)
        
        // Chevron down
        let chevronDown = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 30)
        chevronDown.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
        chevronDown.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(chevronDown)
        
        bag += containerStackView.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.width.height.centerX.centerY.equalToSuperview()
        })
        
        return (containerStackView, bag)
    }
}
