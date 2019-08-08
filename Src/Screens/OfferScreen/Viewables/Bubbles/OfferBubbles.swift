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
    let insuranceSignal = ReadWriteSignal<OfferQuery.Data.Insurance?>(nil)
}

extension OfferBubbles: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 35,
            bottom: 0,
            right: 0
        )
        containerView.isLayoutMarginsRelativeArrangement = true
        
        let view = UIView()
        containerView.addArrangedSubview(view)
        
        let width: CGFloat = 300
        
        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.height.equalTo(width)
                make.width.equalTo(350)
                make.centerX.equalToSuperview()
            }
        }
        
        func entryAnimation(delay: TimeInterval, bubbleView: UIView) {
            let innerBag = DisposeBag()
            
            bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
            bubbleView.alpha = 0

            innerBag += Signal(after: 0.65 + delay)
                .animated(style: SpringAnimationStyle.heavyBounce()) { _ in
                bubbleView.alpha = 1
                bubbleView.transform = CGAffineTransform.identity
                innerBag.dispose()
            }
        }
        
        bag += insuranceSignal.compactMap { $0 }.onValueDisposePrevious { insurance in
            let innerBag = DisposeBag()
            
            innerBag += view.add(DeductibleBubble()) { bubbleView in
                entryAnimation(delay: 0.1, bubbleView: bubbleView)
                
                bubbleView.snp.makeConstraints { make in
                    make.top.equalTo(190)
                    make.left.equalTo(width * 0.23)
                }
            }
            
            innerBag += view.add(BindingPeriodBubble()) { bubbleView in
                entryAnimation(delay: 0.05, bubbleView: bubbleView)
                
                bubbleView.snp.makeConstraints { make in
                    make.top.equalTo(80)
                    make.left.equalTo(0)
                }
            }
            
            if insurance.type == .studentBrf || insurance.type == .brf {
                innerBag += view.add(OwnedAddonBubble()) { bubbleView in
                    entryAnimation(delay: 0.1, bubbleView: bubbleView)
                    
                    bubbleView.snp.makeConstraints { make in
                        make.top.equalTo(140)
                        make.left.equalTo(width * 0.49)
                    }
                }
            } else {
                innerBag += view.add(TravelProtectionBubble()) { bubbleView in
                    entryAnimation(delay: 0.1, bubbleView: bubbleView)
                    
                    bubbleView.snp.makeConstraints { make in
                        make.top.equalTo(140)
                        make.left.equalTo(width * 0.49)
                    }
                }
            }
            
            innerBag += view.add(StartDateBubble(
                insuredAtOtherCompany: insurance.insuredAtOtherCompany ?? false
            )) { bubbleView in
                entryAnimation(delay: 0, bubbleView: bubbleView)
                
                bubbleView.snp.makeConstraints { make in
                    make.top.equalTo(25)
                    make.left.equalTo(width * 0.50)
                }
            }
            
            innerBag += view.add(PersonsInHouseholdBubble(
                personsInHousehold: insurance.personsInHousehold ?? 1
            )) { bubbleView in
                entryAnimation(delay: 0, bubbleView: bubbleView)
                
                bubbleView.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.equalTo(width * 0.2)
                }
            }
            
            return innerBag
        }
        
        return (containerView, bag)
    }
}
