//
//  ExpandableRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-29.
//

import Flow
import Form
import Foundation
import UIKit

struct ExpandableRow<Content: Viewable, ExpandableContent: Viewable> where
    Content.Matter == UIView,
    Content.Events == ViewableEvents,
    Content.Result == Disposable,
    ExpandableContent.Matter == UIView,
    ExpandableContent.Events == ViewableEvents,
    ExpandableContent.Result == Disposable
    {
    
    let content: Content
    let expandedContent: ExpandableContent
    let isOpenSignal: ReadWriteSignal<Bool>
    let transparent: Bool
    
    init(
        content: Content,
        expandedContent: ExpandableContent,
        isOpen: Bool = false,
        transparent: Bool = false
    ) {
        self.content = content
        self.expandedContent = expandedContent
        self.isOpenSignal = ReadWriteSignal<Bool>(isOpen)
        self.transparent = transparent
    }
}

extension ExpandableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerView = UIView()
        if !transparent {
            containerView.backgroundColor = .white
            containerView.layer.cornerRadius = 15
            containerView.layer.shadowOpacity = 0.15
            containerView.layer.shadowOffset = CGSize(width: 0, height: 6)
            containerView.layer.shadowRadius = 8
            containerView.layer.shadowColor = UIColor.darkGray.cgColor
        } else {
            containerView.backgroundColor = .transparent
        }
        
        //containerView.clipsToBounds = true
        //containerView.layer.masksToBounds = true
        
        let clippingView = UIView()
        clippingView.clipsToBounds = true
        
        let expandableStackView = UIStackView()
        expandableStackView.axis = .vertical
        
        bag += expandableStackView.addArranged(content)
        
        let divider = Divider(backgroundColor: .offWhite)
        bag += expandableStackView.addArranged(divider) { dividerView in
            dividerView.alpha = isOpenSignal.value ? 1 : 0
            
            bag += isOpenSignal.onValue({ isOpen in
                let delay: Double = isOpen ? 0 : 0.15
                let opacity: CGFloat = isOpen ? 1 : 0
                
                bag += Signal(after: delay).animated(style: AnimationStyle.easeOut(duration: 0.1), animations: { _ in
                    dividerView.alpha = opacity
                })
            })
        }
        
        // TODO: Rewrite the above to a nice Signal thing like below. Currently doesn't work.
        
        /*bag += isOpenSignal
            .atOnce()
            .map { $0 ? 0 : 1 }
            .flatMapLatest { Signal(after: $0) }
            .flatMapLatest { isOpenSignal.atOnce().plain() }
            .map { $0 ? 1 : 0 }
            .bindTo(divider, \.alpha)*/
        
        bag += expandableStackView.addArranged(expandedContent) { expandedView in
            expandedView.isHidden = !isOpenSignal.value
            expandedView.alpha = isOpenSignal.value ? 1 : 0
            
            bag += isOpenSignal.onValue { isOpen in
                
                let alpha: CGFloat = isOpen ? 1 : 0
                let delay = isOpen ? 0.05 : 0
                
                bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    expandedView.isHidden = !isOpen
                }
                
                bag += Signal(after: delay).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                    expandedView.alpha = alpha
                }
            }
        }
        
        clippingView.addSubview(expandableStackView)
        containerView.addSubview(clippingView)
        
        expandableStackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        clippingView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer()
        bag += containerView.install(tapGesture)
        
        bag += tapGesture
            .signal(forState: .ended)
            .withLatestFrom(isOpenSignal.atOnce().plain())
            .map { $0.1 }
            .map { !$0 }
            .bindTo(isOpenSignal)
        
        return (containerView, bag)
    }
}
