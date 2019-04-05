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
    let isOpenInitially: Bool
    
    init(
        content: Content,
        expandedContent: ExpandableContent,
        isOpen: Bool = false
    ) {
        self.content = content
        self.expandedContent = expandedContent
        self.isOpenInitially = isOpen
    }
}

extension ExpandableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let isOpenSignal = ReadWriteSignal<Bool?>(isOpenInitially)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.clipsToBounds = true
        
        let expandableStackView = UIStackView()
        expandableStackView.axis = .vertical
        
        bag += expandableStackView.addArranged(content)
        
        let divider = UIView()
        divider.backgroundColor = .lightGray
        expandableStackView.addArrangedSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.centerX.equalToSuperview()
        }
        
        bag += expandableStackView.addArranged(expandedContent) { expandedView in
            expandedView.isHidden = isOpenInitiallys
            
            bag += isOpenSignal.animated(style: AnimationStyle.easeOut(duration: 0.25)) { isOpen in
                let open = isOpen ?? true
                expandedView.isHidden = !open
                expandedView.layoutIfNeeded()
            }
        }
        
        containerView.addSubview(expandableStackView)
        
        expandableStackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer()
        bag += containerView.install(tapGesture)
        
        bag += tapGesture.signal(forState: .ended).onValue { _ in
            let currentSignal = isOpenSignal.value ?? false
            isOpenSignal.value = !currentSignal
        }
            
            /*.onValue { _ in
            // TODO: Show details of the insurance
            print("Open up")
        }*/
        
        return (containerView, bag)
    }
}
