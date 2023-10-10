import Flow
import Foundation
import Presentation
import UIKit
import hCore

public struct ExpandableContent {
    let contentView: UIView
    let isExpanded: ReadWriteSignal<Bool>
    let collapsedMaxHeight: CGFloat

    public init(
        contentView: UIView,
        isExpanded: ReadWriteSignal<Bool>,
        collapsedMaxHeight: CGFloat
    ) {
        self.contentView = contentView
        self.isExpanded = isExpanded
        self.collapsedMaxHeight = collapsedMaxHeight
    }
}

extension ExpandableContent: Presentable {
    public func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()
        let outerContainer = UIView()

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .brandNew(.primaryBackground())

        let buttonIsHiddenSignal = ReadWriteSignal(false)

        let tapGestureRecognizer = UITapGestureRecognizer()
        outerContainer.addGestureRecognizer(tapGestureRecognizer)

        bag +=
            tapGestureRecognizer
            .signal(forState: .recognized)
            .filter(predicate: { _ in !buttonIsHiddenSignal.value })
            .map { true }
            .bindTo(isExpanded)

        outerContainer.addSubview(scrollView)

        let expandButton = Button(
            title: "",
            type: .outlineIcon(
                borderColor: .brandNew(.secondaryBackground(true)),
                textColor: .brandNew(.secondaryBackground(true)),
                icon: .left(image: hCoreUIAssets.chevronDown.image, width: 10)
            )
        )
        let buttonHalfHeight = expandButton.type.value.height / 2

        scrollView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(buttonHalfHeight)
        }

        scrollView.isScrollEnabled = false
        scrollView.layer.cornerRadius = 13

        scrollView.embedView(contentView, scrollAxis: .vertical)

        let shadowView = UIView()

        func rerenderHeight(size: CGSize) {
            outerContainer.snp.remakeConstraints { make in
                make.width.equalTo(size.width)
                let outerContainerHeight = buttonHalfHeight + size.height

                if collapsedMaxHeight > (size.height + (size.height * 0.1)) {
                    shadowView.isHidden = true
                    buttonIsHiddenSignal.value = true
                    make.height.equalTo(size.height)
                } else {
                    shadowView.isHidden = false
                    buttonIsHiddenSignal.value = false

                    let totalHeight =
                        self.isExpanded.value
                        ? outerContainerHeight + (buttonHalfHeight * 2)
                        : outerContainerHeight * 0.5
                    make.height.equalTo(
                        totalHeight
                    )
                }
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

        bag += scrollView.contentSizeSignal.atOnce()
            .animated(style: .mediumBounce()) { contentSize in
                rerenderHeight(size: contentSize)
            }

        bag += isExpanded.animated(style: .mediumBounce()) { _ in
            rerenderHeight(size: scrollView.contentSize)
        }

        bag += expandButton.onTapSignal.withLatestFrom(isExpanded.atOnce().plain()).map { !$1 }
            .bindTo(isExpanded)

        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.5, 1]
        gradient.cornerRadius = 13
        shadowView.layer.addSublayer(gradient)

        func setGradientColors() {
            gradient.colors = [
                UIColor.brandNew(.primaryBackground()).withAlphaComponent(0).cgColor,
                UIColor.brandNew(.primaryBackground()).withAlphaComponent(0.2).cgColor,
                UIColor.brandNew(.primaryBackground()).cgColor,
            ]
        }

        bag += shadowView.traitCollectionSignal.atOnce()
            .onValue { _ in
                setGradientColors()
            }

        bag += shadowView.didLayoutSignal.onValue { _ in
            gradient.frame = shadowView.bounds
        }

        outerContainer.addSubview(shadowView)
        outerContainer.clipsToBounds = true

        shadowView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.bottom.equalTo(outerContainer.snp.bottom).inset(buttonHalfHeight)
            make.height.lessThanOrEqualTo(300)
        }

        let buttonContainer = UIStackView()
        outerContainer.addSubview(buttonContainer)
        buttonContainer.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
        }

        bag += buttonContainer.addArranged(expandButton) { buttonView in
            bag += buttonIsHiddenSignal.atOnce()
//                .onValue { isHidden in
//                    buttonView.isHidden = isHidden
//                }

            bag += isExpanded.atOnce()
                .onValue { value in
                    UIView.transition(
                        with: buttonView,
                        duration: 0.25,
                        options: .transitionCrossDissolve,
                        animations: {
                            expandButton.title.value =
                                value
                                ? L10n.expandableContentCollapse
                                : L10n.expandableContentExpand
                            expandButton.type.value = .outlineIcon(
                                borderColor: .brandNew(.secondaryBackground(true)),
                                textColor: .brandNew(.secondaryBackground(true)),
                                icon: .left(
                                    image: value
                                        ? hCoreUIAssets.chevronUp.image
                                        : hCoreUIAssets.chevronDown.image,
                                    width: 10
                                )
                            )
                            buttonView.layoutIfNeeded()
                            buttonContainer.layoutIfNeeded()
                        },
                        completion: nil
                    )
                }

            buttonView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        bag +=
            isExpanded
            .atOnce()
            .animated(mapStyle: { $0 ? .easeOut(duration: 0.25) : .easeOut(duration: 0) }) { isExpanded in
                shadowView.alpha = isExpanded ? 0 : 1
                shadowView.layoutIfNeeded()
            }

        return (outerContainer, bag)
    }
}
