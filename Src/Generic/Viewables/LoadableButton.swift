//
//  LoadableButton.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-28.
//

import Foundation
import UIKit
import Flow

struct LoadableButton {
    let button: Button
    let isLoadingSignal: ReadWriteSignal<Bool>
    let onTapSignal: Signal<Void>
    private let onTapCallbacker = Callbacker<Void>()
    
    init(button: Button, initialLoadingState: Bool = false) {
        onTapSignal = onTapCallbacker.signal()
        self.button = button
        isLoadingSignal = ReadWriteSignal<Bool>(initialLoadingState)
    }
}

extension LoadableButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
        let bag = DisposeBag()
        let (buttonView, disposable) = button.materialize(events: events)
        
        bag += button.onTapSignal.withLatestFrom(isLoadingSignal.plain()).filter{ $1 == false }.onValue { (_, _) in
            self.onTapCallbacker.callAll()
        }
        
        let spinner = UIActivityIndicatorView()
        buttonView.addSubview(spinner)
        
        spinner.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.7)
            make.center.equalToSuperview()
        }
        
        bag += buttonView.didLayoutSignal.onValue { _ in
            buttonView.titleLabel?.frame.size.width = buttonView.titleLabel?.intrinsicContentSize.width ?? 0
        }
        
        func setLoadingState(isLoading: Bool, animate: Bool) {
            buttonView.snp.updateConstraints { make in
                if (isLoading) {
                    make.width.equalTo(self.button.type.height())
                } else {
                    make.width.equalTo(buttonView.intrinsicContentSize.width + self.button.type.extraWidthOffset())
                    print("1. updated margins")
                }
            }
            
            func setLabelAlpha() {
                if isLoading {
                    buttonView.titleLabel?.alpha = 0
                } else {
                    buttonView.titleLabel?.alpha = 1
                }
            }
            
            func setSpinnerAlpha() {
                if isLoading {
                    spinner.alpha = 1
                } else {
                    spinner.alpha = 0
                }
            }
            
            if animate {
                let labelDelay = isLoading ? 0 : 0.25
                let layoutDelay = isLoading ? 0.25 : 0
                
                bag += Signal(after: labelDelay).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                    setLabelAlpha()
                }
                
                bag += Signal(after: layoutDelay).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                    setSpinnerAlpha()
                }
                
                print("2. layouted views")
                //buttonView.titleLabel?.setNeedsUpdateConstraints()
                //buttonView.titleLabel?.layoutIfNeeded()
                //buttonView.setNeedsUpdateConstraints()
                //buttonView.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.25, delay: layoutDelay, usingSpringWithDamping: 30, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                    buttonView.titleLabel?.setNeedsUpdateConstraints()
                    buttonView.titleLabel?.layoutIfNeeded()
                    buttonView.setNeedsUpdateConstraints()
                    buttonView.layoutIfNeeded()
                    
                }, completion: nil)
            } else {
                setLabelAlpha()
                setSpinnerAlpha()
                
                buttonView.titleLabel?.setNeedsUpdateConstraints()
                buttonView.titleLabel?.layoutIfNeeded()
                buttonView.setNeedsUpdateConstraints()
                buttonView.layoutIfNeeded()
            }
            
            if isLoading {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
        
        bag += isLoadingSignal.onValue { isLoading in
            setLoadingState(isLoading: isLoading, animate: true)
        }
        
        bag += events.wasAdded.withLatestFrom(isLoadingSignal.atOnce().plain()).onValue { _, isLoading in
            setLoadingState(isLoading: isLoading, animate: false)
        }
        
        return (buttonView, Disposer {
            disposable.dispose()
            bag.dispose()
        })
    }
}
