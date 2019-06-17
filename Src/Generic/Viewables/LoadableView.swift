//
//  LoadableView.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-17.
//

import Foundation
import Flow
import UIKit

struct LoadableView<V: Viewable> where V.Matter: UIView, V.Result == Disposable {
    let view: V
    let isLoadingSignal: ReadWriteSignal<Bool>
    
    init(view: V, initialLoadingState: Bool = false) {
        self.view = view
        self.isLoadingSignal = ReadWriteSignal(initialLoadingState)
    }
}

extension LoadableView: Viewable {
    func materialize(events: V.Events) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let (matter, result) = view.materialize(events: events)
        
        let containerView = UIStackView()
        containerView.addArrangedSubview(matter)
        
        let loadingIndicator = UIActivityIndicatorView(style: .white)
        loadingIndicator.alpha = 0
        loadingIndicator.color = .purple
        
        containerView.addArrangedSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.center.equalToSuperview()
        }
        
        bag += isLoadingSignal.atOnce().animated(style: SpringAnimationStyle.lightBounce()) { isLoading in
            if isLoading {
                matter.isHidden = true
                matter.alpha = 0
                loadingIndicator.isHidden = false
                loadingIndicator.startAnimating()
                loadingIndicator.alpha = 1
            } else {
                matter.isHidden = false
                matter.alpha = 1
                loadingIndicator.isHidden = true
                loadingIndicator.stopAnimating()
                loadingIndicator.alpha = 0
            }
            
            containerView.layoutIfNeeded()
        }
        
        return (containerView, Disposer {
            result.dispose()
            bag.dispose()
        })
    }
}
