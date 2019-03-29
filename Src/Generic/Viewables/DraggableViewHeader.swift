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
        
        let titleLabel = UILabel()
        titleLabel.style = .drabbableOverlayTitle
        titleLabel.textAlignment = .center
        bag += titleLabel.setDynamicText(DynamicString(title))
        
        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        
        bag += titleLabel.didLayoutSignal.onValue { _ in
            titleLabel.snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            }
        }
        
        view.addSubview(titleContainer)
        
        titleContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalTo(60)
        }
        
        return (view, bag)
    }
}
