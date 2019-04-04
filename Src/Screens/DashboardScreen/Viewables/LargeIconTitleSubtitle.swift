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
    
    enum Orientation {
        case down, right
    }
    
    let titleText: String
    let iconAsset: ImageAsset
    
    let iconWidth: CGFloat = 35
    let subtitleText = "försäkras för"
    let arrowOrientation: Orientation
    
    init(
        title: String,
        icon: ImageAsset,
        arrowOrientation: Orientation = .down
        ) {
        self.titleText = title
        self.iconAsset = icon
        self.arrowOrientation = arrowOrientation
    }
}

extension LargeIconTitleSubtitle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackViewEdgeInsets = UIEdgeInsets(
            top: 20,
            left: 16,
            bottom: 20,
            right: 19
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
        let icon = Icon(icon: iconAsset, iconWidth: iconWidth)
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(icon)
        
        // Title+subtitle
        let titlesView = UIStackView()
        titlesView.axis = .vertical
        titlesView.spacing = 2
        titlesView.backgroundColor = .blue
        titlesView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let titleLabel = MultilineLabel(styledText: StyledText(text: titleText, style: .boldSmallTitle))
        bag += titlesView.addArranged(titleLabel)
        
        let subtitleLabel = MultilineLabel(styledText: StyledText(text: subtitleText, style: .rowSubtitle))
        bag += titlesView.addArranged(subtitleLabel)
        
        containerStackView.addArrangedSubview(titlesView)
        
        // Chevron down
        let chevronDown = Icon(icon: Asset.chevronRight, iconWidth: 25)
        chevronDown.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
        chevronDown.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(chevronDown)
        
        return (containerStackView, bag)
    }
}
