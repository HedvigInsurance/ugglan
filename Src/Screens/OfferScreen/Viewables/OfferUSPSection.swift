//
//  OfferUSPSection.swift
//  test
//
//  Created by sam on 23.3.20.
//

import Foundation
import Form
import Presentation
import UIKit
import Flow

struct OfferUSPSection {
    
}

extension OfferUSPSection: Viewable {
    func materialize(events: ViewableEvents) -> (SectionView, Disposable) {
        let sectionView = SectionView()
        sectionView.dynamicStyle = .sectionPlain
        let bag = DisposeBag()
        
        return (sectionView, bag)
    }
}
