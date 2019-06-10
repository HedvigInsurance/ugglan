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
    let dataSignal: ReadWriteSignal<WhatsNewQuery.Data?> = ReadWriteSignal(nil)
    let pageIndexSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
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
        
        bag += dataSignal.atOnce().compactMap { $0?.news }.onValue { news in
            for i in 0...4 {
                let indicator = UIView()
                indicator.backgroundColor = i == 0 ? .purple : .gray
                indicator.transform = i == 0 ? CGAffineTransform(scaleX: 1.5, y: 1.5) : CGAffineTransform.identity
                indicator.layer.cornerRadius = 2
                
                indicator.snp.makeConstraints { make in
                    make.width.height.equalTo(4)
                }
                
                stackView.addArrangedSubview(indicator)
            }
        }
        
        bag += pageIndexSignal
            .animated(style: SpringAnimationStyle.heavyBounce())
            { pageIndex in
                
            for (index, indicator) in stackView.subviews.enumerated() {
                let indicatorIsActive = index == pageIndex
                
                indicator.backgroundColor = indicatorIsActive ? .purple : .gray
                indicator.transform = indicatorIsActive ? CGAffineTransform(scaleX: 1.5, y: 1.5) : CGAffineTransform.identity
            }
        }
        
        return (view, bag)
    }
}
