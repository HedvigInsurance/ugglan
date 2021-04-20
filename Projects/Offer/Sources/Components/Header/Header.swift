//
//  Header.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct Header {
    let scrollView: UIScrollView
}

extension Header: Presentable {
    func materialize() -> (UIStackView, Disposable) {
        let view = UIStackView()
        let bag = DisposeBag()
        
        bag += view.didLayoutSignal.onValue {
            let safeAreaInsetTop = view.viewController?.view.safeAreaInsets.top ?? 0
            view.edgeInsets = UIEdgeInsets(top: safeAreaInsetTop + 70, left: 15, bottom: 60, right: 15)
        }
        
        bag += view.add(GradientView(
            gradientOption: .init(
                preset: .insuranceOne,
                shouldShimmer: false,
                shouldAnimate: false
            ),
            shouldShowGradientSignal: .init(true)
        )) { headerBackgroundView in
            headerBackgroundView.layer.zPosition = -1
            headerBackgroundView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.edges.equalToSuperview()
            }
            
            bag += scrollView.signal(for: \.contentOffset).atOnce().onValue { contentOffset in
                let headerScaleFactor: CGFloat = -(contentOffset.y) / headerBackgroundView.bounds.height
                
                guard headerScaleFactor > 0 else {
                    headerBackgroundView.layer.transform = CATransform3DIdentity
                    return
                }
                                
                var headerTransform = CATransform3DIdentity
                
                let headerSizevariation = ((headerBackgroundView.bounds.height * (1.0 + headerScaleFactor)) - headerBackgroundView.bounds.height) / 2.0
                
                headerTransform = CATransform3DTranslate(headerTransform, 0, -headerSizevariation, 0)
                headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
                
                headerBackgroundView.layer.transform = headerTransform
            }
        }
        
        bag += view.addArrangedSubview(HeaderForm())
        
        return (view, bag)
    }
}
