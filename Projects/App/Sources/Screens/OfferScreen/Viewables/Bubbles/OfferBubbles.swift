//
//  OfferBubbles.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Flow
import Foundation
import UIKit
import Core

struct OfferBubbles {
    let containerScrollView: UIScrollView
    let insuranceSignal = ReadWriteSignal<OfferQuery.Data.Insurance?>(nil)
}

extension OfferBubbles: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 10,
            bottom: 0,
            right: 0
        )
        containerView.isLayoutMarginsRelativeArrangement = true

        let view = UIView()
        containerView.addArrangedSubview(view)

        let width: CGFloat = 300

        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            containerView.transform = CGAffineTransform(
                translationX: 0,
                y: contentOffset.y / 5
            )
        }

        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.height.equalTo(width)
                make.width.equalTo(width)
            }
        }

        func entryAnimation(delay: TimeInterval, bubbleView: UIView) {
            let innerBag = DisposeBag()

            bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
            bubbleView.alpha = 0

            innerBag += Signal(after: 0.65 + delay)
                .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                    bubbleView.alpha = 1
                    bubbleView.transform = CGAffineTransform.identity
                    innerBag.dispose()
                }
        }

        bag += insuranceSignal.compactMap { $0 }.take(first: 1).onValueDisposePrevious { insurance in
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
                insuredAtOtherCompany: insurance.previousInsurer != nil
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
