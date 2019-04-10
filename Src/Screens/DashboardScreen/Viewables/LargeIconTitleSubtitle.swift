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
    let isOpenSignal: ReadWriteSignal<Bool>
    
    let titleSignal: ReadWriteSignal<String> = ReadWriteSignal("")
    let subtitleSignal: ReadWriteSignal<String> = ReadWriteSignal("")
    let imageSignal: ReadWriteSignal<ImageAsset?> = ReadWriteSignal(nil)
    
    let iconWidth: CGFloat = 35
    
    init(
        isOpenInitially: Bool = false
        ) {
        isOpenSignal = ReadWriteSignal<Bool>(isOpenInitially)
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
        let icon = Icon(icon: Asset.homePlain, iconWidth: iconWidth)
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(icon)
        
        bag += imageSignal.atOnce()
            .filter { $0 != nil }
            .map { $0! }.bindTo(icon, \.icon)
        
        // Title+subtitle
        let titlesView = UIStackView()
        titlesView.axis = .vertical
        titlesView.spacing = 2
        titlesView.backgroundColor = .blue
        titlesView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let titleLabel = MultilineLabel(styledText: StyledText(text: "", style: .boldSmallTitle))
        bag += titlesView.addArranged(titleLabel)
        
        bag += titleSignal.atOnce()
            .map { StyledText(text: $0, style: .boldSmallTitle) }
            .bindTo(titleLabel.styledTextSignal)
        
        let subtitleLabel = MultilineLabel(styledText: StyledText(text: "", style: .rowSubtitle))
        bag += titlesView.addArranged(subtitleLabel)
        
        bag += subtitleSignal.atOnce()
            .map { StyledText(text: $0, style: .rowSubtitle) }
            .bindTo(subtitleLabel.styledTextSignal)
        
        containerStackView.addArrangedSubview(titlesView)
        
        
        let chevronDown = Icon(icon: Asset.chevronRight, iconWidth: 25)
        chevronDown.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(chevronDown)
        
        func setChevronRotation(isOpen: Bool, animate: Bool) {
            let rotationAngle = isOpen ? ((3 * CGFloat.pi / 2) * 1.0001) : (CGFloat.pi / 2)
            
            func setRotation() {
                chevronDown.transform = CGAffineTransform.init(rotationAngle: rotationAngle)
            }
            
            if animate {
                bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    setRotation()
                }
            } else {
                setRotation()
            }
        }
        
        bag += isOpenSignal.onValue { isOpen in
            setChevronRotation(isOpen: isOpen, animate: true)
        }
        
        bag += events.wasAdded.withLatestFrom(isOpenSignal.atOnce().plain()).onValue { _, isOpen in
            setChevronRotation(isOpen: isOpen, animate: false)
        }
        
        return (containerStackView, bag)
    }
}
