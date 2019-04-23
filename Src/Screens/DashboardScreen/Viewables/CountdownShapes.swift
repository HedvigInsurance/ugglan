//
//  CountdownShapes.swift
//  UITests
//
//  Created by Axel Backlund on 2019-04-23.
//

import Flow
import Form
import Foundation
import UIKit

struct CountdownShapes {}

extension CountdownShapes: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let contentView = UIView()
        
        let view = UIStackView()
        view.alignment = .bottom
        view.distribution = .fill
        view.spacing = 24
        
        contentView.addSubview(view)
        
        let square = UIView()
        square.backgroundColor = .darkPurple
        square.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        view.addArrangedSubview(square)
        
        let circle = UIView()
        circle.backgroundColor = .pink
        circle.layer.cornerRadius = 32 / 2
        circle.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        view.addArrangedSubview(circle)
        
        let cogwheel = Icon(icon: Asset.cogwheel, iconWidth: 32)
        view.addArrangedSubview(cogwheel)
        
        let barStack = UIStackView()
        barStack.spacing = 8
        barStack.alignment = .bottom
        
        let firstBar = UIView()
        firstBar.backgroundColor = .turquoise
        firstBar.snp.makeConstraints { make in
            make.width.equalTo(9)
            make.height.equalTo(32)
        }
        barStack.addArrangedSubview(firstBar)
        
        let secondBar = UIView()
        secondBar.backgroundColor = .turquoise
        secondBar.snp.makeConstraints { make in
            make.width.equalTo(9)
            make.height.equalTo(12)
        }
        barStack.addArrangedSubview(secondBar)
        
        view.addArrangedSubview(barStack)
        
        view.snp.makeConstraints { (make) in
            make.height.centerX.centerY.equalToSuperview()
        }
        
        let animationDelay = 0.3
        
        
        let squareCallbacker = Callbacker<Void>()
        bag += squareCallbacker.addCallback { _ in
            bag += Signal(after: 0).animated(style: .heavyBounce(delay: 0)) { _ in
                    square.transform = CGAffineTransform(scaleX: 1, y: 0.5)
                }.animated(style: .heavyBounce(delay: 0.3)) { _ in
                    square.transform = CGAffineTransform.identity
                }.onValue {
                    squareCallbacker.callAll()
            }
        }
        
        _ = Signal(callbacker: squareCallbacker)
        
        squareCallbacker.callAll()

        /*bag += square.didLayoutSignal.delay(by: animationDelay).animated(style: .heavyBounce(delay: 0)) { _ in
                square.transform = CGAffineTransform(scaleX: 1, y: 0.5)
            }.animated(style: .heavyBounce(delay: 0.3)) { _ in
                square.transform = CGAffineTransform.identity
        }*/
        
        bag += square.didLayoutSignal.delay(by: animationDelay * 2).animated(style: .heavyBounce(delay: 0)) { _ in
                circle.transform = CGAffineTransform(translationX: 10, y: 0)
            }.animated(style: .heavyBounce(delay: 0.3)) { _ in
                circle.transform = CGAffineTransform.identity
        }.repeating(after: 0)
        
        bag += square.didLayoutSignal.delay(by: animationDelay * 3).animated(style: .heavyBounce(delay: 0)) { _ in
            cogwheel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        bag += square.didLayoutSignal.delay(by: animationDelay * 4).animated(style: .heavyBounce(delay: 0)) { _ in
            firstBar.snp.updateConstraints { make in
                make.height.equalTo(12)
            }
            secondBar.snp.updateConstraints { make in
                make.height.equalTo(32)
            }
            
            barStack.layoutIfNeeded()
            }.delay(by: 0.4).animated(style: .heavyBounce(delay: 0)) { _ in
                firstBar.snp.updateConstraints { make in
                    make.height.equalTo(32)
                }
                secondBar.snp.updateConstraints { make in
                    make.height.equalTo(12)
                }
                
                barStack.layoutIfNeeded()
        }
        
        return (contentView, bag)
    }
}
