//
//  MyProtectionRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-29.
//

import Flow
import Form
import Foundation
import UIKit

struct ProtectionView {    
    let titleText: String
    let iconAsset: ImageAsset
    let color: HedvigColor
    let protections: [String]
    
    let iconWidth: CGFloat = 75
    let footerText = "Klicka på ikonerna för mer info"
    let subtitleText = "försäkras för"
    
    init(
        title: String,
        icon: ImageAsset,
        color: HedvigColor,
        protections: [String] = []
    ) {
        self.titleText = title
        self.iconAsset = icon
        self.color = color
        self.protections = protections
    }
}

extension ProtectionView: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
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
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOpacity = 0.14
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        
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
        
        containerView.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints({ make in
            make.width.height.centerX.centerY.equalToSuperview()
        })
        
        bag += containerStackView.didLayoutSignal.onValue({ _ in
            let size = containerStackView.systemLayoutSizeFitting(CGSize.zero)
            
            containerView.snp.remakeConstraints({ make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            })
        })
        
        let tapGesture = UITapGestureRecognizer()
        bag += containerView.install(tapGesture)
        
        bag += tapGesture.signal(forState: .ended).onValue({ _ in
            // TODO: Show details of the insurance
            print("Open up")
        })
        
        return (containerView, bag)
    }
}
