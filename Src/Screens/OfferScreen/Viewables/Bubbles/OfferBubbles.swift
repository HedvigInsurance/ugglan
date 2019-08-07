//
//  OfferBubbles.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Foundation
import Flow
import UIKit

struct OfferBubbles {
    
}

extension OfferBubbles: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        
        return (view, bag)
    }
}
