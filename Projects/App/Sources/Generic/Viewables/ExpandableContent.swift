//
//  ExpandableSection.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Flow
import Foundation
import UIKit

struct ExpandableContent<Content: Viewable> where Content.Matter: UIView, Content.Result == Disposable, Content.Events == ViewableEvents {
    let content: Content
    let isExpanded: ReadWriteSignal<Bool>

    init(content: Content, isExpanded: ReadWriteSignal<Bool>) {
        self.content = content
        self.isExpanded = isExpanded
    }
}

extension ExpandableContent: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let outerContainer = UIView()

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .primaryBackground

        let tapGestureRecognizer = UITapGestureRecognizer()
        outerContainer.addGestureRecognizer(tapGestureRecognizer)

        bag += tapGestureRecognizer.signal(forState: .recognized).map { true }.bindTo(isExpanded)

        outerContainer.addSubview(scrollView)

        let expandButton = Button(title: "", type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor))
        let buttonHalfHeight = expandButton.type.value.height / 2

        scrollView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(buttonHalfHeight)
        }

        scrollView.isScrollEnabled = false
        scrollView.layer.cornerRadius = 13

        let (contentView, contentDisposable) = content.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker()))
        scrollView.embedView(contentView, scrollAxis: .vertical)

        bag += contentDisposable

        bag += combineLatest(
            scrollView.contentSizeSignal.atOnce(),
            isExpanded.atOnce()
        ).animated(style: .mediumBounce()) { size, _ in
            outerContainer.snp.remakeConstraints { make in
                make.width.equalTo(size.width)
                let outerContainerHeight = buttonHalfHeight + size.height
                make.height.equalTo(self.isExpanded.value ? outerContainerHeight + (buttonHalfHeight * 2) : outerContainerHeight * 0.5)
            }
            outerContainer.layoutSuperviewsIfNeeded()
            outerContainer.subviews.forEach { subview in
                if subview is UIStackView {
                    subview.layoutIfNeeded()
                }
            }
            scrollView.subviews.forEach { subview in
                subview.layoutIfNeeded()
            }
        }

        bag += expandButton.onTapSignal.withLatestFrom(isExpanded.atOnce().plain()).map { !$1 }.bindTo(isExpanded)

        let shadowView = UIView()

        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.5, 1]
        gradient.cornerRadius = 13
        shadowView.layer.addSublayer(gradient)

        func setGradientColors() {
            gradient.colors = [
                UIColor.primaryBackground.withAlphaComponent(0).cgColor,
                UIColor.primaryBackground.withAlphaComponent(0.2).cgColor,
                UIColor.primaryBackground.cgColor,
            ]
        }

        bag += shadowView.traitCollectionSignal.atOnce().onValue { _ in
            setGradientColors()
        }

        bag += shadowView.didLayoutSignal.onValue { _ in
            gradient.frame = shadowView.bounds
        }

        outerContainer.addSubview(shadowView)

        shadowView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(buttonHalfHeight)
            make.height.equalToSuperview()
        }

        bag += outerContainer.add(expandButton.wrappedIn(UIStackView())) { buttonView in
            bag += isExpanded.atOnce().map { !$0 ? L10n.expandableContentExpand : L10n.expandableContentCollapse }.onValue { value in
                UIView.transition(with: buttonView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    expandButton.title.value = value
                    buttonView.layoutIfNeeded()
                }, completion: nil)
            }

            buttonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        }

        bag += isExpanded
            .atOnce()
            .animated(mapStyle: { $0 ? .easeOut(duration: 0.25) : .easeOut(duration: 0.25, delay: 0.30) }) { isExpanded in
                shadowView.alpha = isExpanded ? 0 : 1
            }

        return (outerContainer, bag)
    }
}
