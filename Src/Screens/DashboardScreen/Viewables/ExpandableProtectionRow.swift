//
//  ExpandableProtectionRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-29.
//

import Flow
import Form
import Foundation
import UIKit

struct ExpandableProtectionRow<Content: Viewable, ExpandableContent: Viewable> where
    Content.Matter == UIView,
    Content.Events == ViewableEvents,
    Content.Result == Disposable,
    ExpandableContent.Matter == UIView,
    ExpandableContent.Events == ViewableEvents,
    ExpandableContent.Result == Disposable
    {
    
    let contentViewable: Content
    let expandableContentViewable: ExpandableContent
    
    init(
        content: Content,
        expandableContent: ExpandableContent
    ) {
        self.contentViewable = content
        self.expandableContentViewable = expandableContent
    }
}

extension ExpandableProtectionRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOpacity = 0.14
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        
        bag += containerView.add(contentViewable)
        
        let tapGesture = UITapGestureRecognizer()
        bag += containerView.install(tapGesture)
        
        bag += tapGesture.signal(forState: .ended).onValue({ _ in
            // TODO: Show details of the insurance
            print("Open up")
        })
        
        return (containerView, bag)
    }
}
