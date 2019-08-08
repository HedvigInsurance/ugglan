//
//  OfferBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Foundation
import Flow
import UIKit

struct OfferBubble {
    let content: UIView
    let widthSignal: ReadWriteSignal<CGFloat>
    let heightSignal: ReadWriteSignal<CGFloat>
    let backgroundColorSignal: ReadWriteSignal<UIColor>
    
    init(content: UIView, width: CGFloat, height: CGFloat, backgroundColor: UIColor) {
        self.content = content
        self.widthSignal = ReadWriteSignal(width)
        self.heightSignal = ReadWriteSignal(height)
        self.backgroundColorSignal = ReadWriteSignal(backgroundColor)
    }
}

extension OfferBubble: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.layer.shadowOpacity = 0.2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        bag += backgroundColorSignal.atOnce().bindTo(view, \.backgroundColor)
        
        bag += combineLatest(widthSignal.atOnce(), heightSignal.atOnce()).onValue { width, height in
            view.layer.cornerRadius = width / 2
            
            view.snp.remakeConstraints({ make in
                make.width.equalTo(width)
                make.height.equalTo(height)
            })
        }
        
        view.addSubview(content)
        
        content.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        return (view, bag)
    }
}
