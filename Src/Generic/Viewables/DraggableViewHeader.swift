//
//  DraggableViewHeader.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-28.
//

import Foundation
import Flow
import UIKit

struct DraggableViewHeader {
    let title: String
}

extension DraggableViewHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        view.backgroundColor = .offWhite
        
        let bag = DisposeBag()
        
        let title = UILabel()
        title.style = .sectionHeader
        bag += title.setDynamicText(DynamicString("Välgörenhet"))
        
        let titleContainer = UIView()
        titleContainer.addSubview(title)
        
        bag += title.didLayoutSignal.onValue { _ in
            title.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        }
        
        view.addSubview(titleContainer)
        
        titleContainer.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview()
        }
        
        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalTo(60)
        }
        
        return (view, bag)
    }
}
