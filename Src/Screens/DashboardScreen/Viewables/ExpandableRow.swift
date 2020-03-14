//
//  ExpandableRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-29.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct ExpandableRow<Content: Viewable, ExpandableContent: Viewable> where
    Content.Matter == UIView,
    Content.Events == ViewableEvents,
    Content.Result == Disposable,
    ExpandableContent.Matter == UIView,
    ExpandableContent.Events == ViewableEvents,
    ExpandableContent.Result == Disposable {
    let content: Content
    let expandedContent: ExpandableContent
    let isOpenSignal: ReadWriteSignal<Bool>
    let transparent: Bool
    let showDivider: Bool

    init(
        content: Content,
        expandedContent: ExpandableContent,
        isOpen: Bool = false,
        transparent: Bool = false,
        showDivider: Bool = true
    ) {
        self.content = content
        self.expandedContent = expandedContent
        isOpenSignal = ReadWriteSignal<Bool>(isOpen)
        self.transparent = transparent
        self.showDivider = showDivider
    }
}

extension ExpandableRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        if !transparent {
            containerView.backgroundColor = .secondaryBackground
            containerView.layer.cornerRadius = 15
            bag += containerView.applyShadow { _ -> UIView.ShadowProperties in
                UIView.ShadowProperties(
                    opacity: 0.15,
                    offset: CGSize(width: 0, height: 6),
                    radius: 8,
                    color: UIColor.primaryShadowColor,
                    path: nil
                )
            }
        } else {
            containerView.backgroundColor = .transparent
        }

        let clippingView = UIView()
        clippingView.clipsToBounds = true

        let expandableStackView = UIStackView()
        expandableStackView.axis = .vertical

        let contentWrapperView = UIControl()

        bag += contentWrapperView.add(content) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.width.height.equalToSuperview()
            }
        }

        expandableStackView.addArrangedSubview(contentWrapperView)

        if showDivider {
            let divider = Divider(backgroundColor: .primaryBorder)
            bag += expandableStackView.addArranged(divider) { dividerView in
                dividerView.alpha = isOpenSignal.value ? 1 : 0

                bag += isOpenSignal
                    .atOnce()
                    .map { $0 ? 0 : 0.15 }
                    .flatMapLatest { Signal(after: $0) }
                    .flatMapLatest { self.isOpenSignal.atOnce().plain() }
                    .map { $0 ? 1 : 0 }
                    .animated(style: AnimationStyle.easeOut(duration: 0.2), animations: { opacity in
                        dividerView.alpha = opacity
                    })
            }
        }

        bag += expandableStackView.addArranged(expandedContent) { expandedView in
            expandedView.isHidden = !isOpenSignal.value
            expandedView.alpha = isOpenSignal.value ? 1 : 0

            bag += isOpenSignal
                .atOnce()
                .map { !$0 }
                .animated(style: SpringAnimationStyle.lightBounce()) { isHidden in
                    expandedView.isHidden = isHidden
                }

            bag += isOpenSignal
                .atOnce()
                .map { $0 ? 0.05 : 0 }
                .flatMapLatest { Signal(after: $0) }
                .flatMapLatest { self.isOpenSignal.atOnce().plain() }
                .map { $0 ? 1 : 0 }
                .animated(style: .easeOut(duration: 0.25), animations: { opacity in
                    expandedView.alpha = opacity
                })
        }

        clippingView.addSubview(expandableStackView)
        containerView.addSubview(clippingView)

        expandableStackView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }

        clippingView.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }

        bag += contentWrapperView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += contentWrapperView.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }

        bag += contentWrapperView.delayedTouchCancel(delay: 0.1).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            containerView.transform = CGAffineTransform.identity
        }

        bag += contentWrapperView
            .signal(for: .touchUpInside)
            .withLatestFrom(isOpenSignal.atOnce().plain())
            .map { $0.1 }
            .map { !$0 }
            .bindTo(isOpenSignal)

        return (containerView, bag)
    }
}
