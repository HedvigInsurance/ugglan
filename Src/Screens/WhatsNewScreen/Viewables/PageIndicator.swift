//
//  PageIndicator.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-06.
//

import Foundation
import Form
import Flow
import UIKit

struct PageIndicator {
    let numberOfPages: Int
}

extension PageIndicator: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        bag += view.didLayoutSignal.onValue {
            stackView.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.height.equalToSuperview()
            }
        }
        
        for _ in 0 ..< numberOfPages {
            let indicator = UIView()
            indicator.backgroundColor = .gray
            indicator.layer.cornerRadius = 2
            
            indicator.snp.makeConstraints { make in
                make.width.height.equalTo(4)
            }
            
            stackView.addArrangedSubview(indicator)
        }
        
        return (view, bag)
    }
}
