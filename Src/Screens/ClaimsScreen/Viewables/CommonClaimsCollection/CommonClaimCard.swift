//
//  CommonClaimCard.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct CommonClaimCard {
    let data: CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex
    let presentingViewController: UIViewController

    enum State {
        case normal, expanded
    }

    let backgroundStateSignal = ReadWriteSignal<State>(.normal)
    let cornerRadiusSignal = ReadWriteSignal<CGFloat>(8)
    let iconTopPaddingStateSignal = ReadWriteSignal<State>(.normal)
    let layoutTitleAlphaSignal = ReadWriteSignal<CGFloat>(0)
    let titleLabelStateSignal = ReadWriteSignal<State>(.normal)
    let controlIsEnabledSignal = ReadWriteSignal<Bool>(true)
    let shadowOpacitySignal = ReadWriteSignal<Float>(0.05)
    let showCloseButton = ReadWriteSignal<Bool>(false)
    let showClaimButtonSignal = ReadWriteSignal<Bool>(false)
    let scrollPositionSignal = ReadWriteSignal<CGPoint>(CGPoint(x: 0, y: 0))

    let closeSignal: Signal<Void>
    private let closeCallbacker: Callbacker<Void>

    func iconTopPadding(state: State) -> CGFloat {
        return state == .normal ? 15 : 100
    }

    func height(state: State) -> CGFloat {
        let attributedString = NSAttributedString(styledText: StyledText(
            text: layoutTitle,
            style: .standaloneLargeTitle
        ))

        let size = attributedString.boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 40, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let buttonPadding: CGFloat = includeButton ? 60 : 0

        return state == .normal ? 0 : (size.height + iconTopPadding(state: state) + 90 + buttonPadding)
    }

    var isFirstInRow: Bool {
        let dividedIndex = Double(index.row) / 2
        return rint(dividedIndex) == dividedIndex
    }

    var layoutTitle: String {
        if let title = data.layout.asTitleAndBulletPoints?.title {
            return title
        }

        if let title = data.layout.asEmergency?.title {
            return title
        }

        return ""
    }

    var includeButton: Bool {
        return data.layout.asTitleAndBulletPoints != nil
    }

    init(
        data: CommonClaimsQuery.Data.CommonClaim,
        index: TableIndex,
        presentingViewController: UIViewController
    ) {
        self.index = index
        self.data = data
        self.presentingViewController = presentingViewController
        closeCallbacker = Callbacker()
        closeSignal = closeCallbacker.signal()
    }
}

extension CommonClaimCard: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()

        let bag = DisposeBag()

        func backgroundColorFromData() -> UIColor {
            let lightenedAmount: CGFloat = 0.3

            if let color = data.layout.asTitleAndBulletPoints?.color {
                return UIColor.from(apollo: color).lighter(amount: lightenedAmount)
            }

            if let color = data.layout.asEmergency?.color {
                return UIColor.from(apollo: color).lighter(amount: lightenedAmount)
            }

            return UIColor.purple
        }

        let contentView = UIControl()
        bag += controlIsEnabledSignal.atOnce().bindTo(contentView, \.isEnabled)
        bag += backgroundStateSignal.atOnce().map {
            $0 == .normal ? UIColor.white : backgroundColorFromData()
        }.bindTo(contentView, \.backgroundColor)
        bag += cornerRadiusSignal.atOnce().bindTo(contentView, \.layer.cornerRadius)

        bag += shadowOpacitySignal.atOnce().bindTo(contentView, \.layer.shadowOpacity)

        contentView.layer.shadowOffset = CGSize(width: 0, height: 16)
        contentView.layer.shadowRadius = 30
        contentView.layer.shadowColor = UIColor.black.cgColor

        view.addArrangedSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let expandedHeaderView = UIView()
        bag += backgroundStateSignal.atOnce().map {
            $0 == .normal ? UIColor.white : backgroundColorFromData()
        }.bindTo(expandedHeaderView, \.backgroundColor)
        expandedHeaderView.alpha = 0
        expandedHeaderView.layer.zPosition = 1

        contentView.addSubview(expandedHeaderView)

        expandedHeaderView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
        }

        let titleLabel = UILabel(value: data.title, style: .rowTitle)
        titleLabel.layer.zPosition = 2
        contentView.addSubview(titleLabel)

        bag += scrollPositionSignal.onValue { point in
            titleLabel.transform = CGAffineTransform(translationX: 0, y: point.y)
            expandedHeaderView.transform = CGAffineTransform(translationX: 0, y: point.y)

            if point.y != 0 {
                expandedHeaderView.alpha = 1
                expandedHeaderView.snp.updateConstraints { make in
                    if point.y < 0 {
                        make.height.equalTo(90 + -point.y)
                    } else {
                        make.height.equalTo(90)
                    }
                }
            }
        }

        bag += titleLabelStateSignal.atOnce().onValue { newState in
            if newState == .normal {
                titleLabel.snp.remakeConstraints { make in
                    make.bottom.equalToSuperview().inset(15)
                    make.width.equalToSuperview().inset(15)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(titleLabel.intrinsicContentSize.height)
                }
            } else {
                titleLabel.snp.remakeConstraints { make in
                    make.top.equalToSuperview().inset(55)
                    make.width.equalTo(titleLabel.intrinsicContentSize.width)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(titleLabel.intrinsicContentSize.height)
                }
            }
        }

        let layoutTitleLabel = MultilineLabel(styledText: StyledText(
            text: layoutTitle,
            style: .standaloneLargeTitle
        ))
        bag += contentView.add(layoutTitleLabel) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(0)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().inset(15)
            }

            bag += iconTopPaddingStateSignal.atOnce().onValue { state in
                let extraPadding: CGFloat = 50

                if state == .normal {
                    view.snp.updateConstraints { make in
                        make.top.equalTo(self.iconTopPadding(state: state) + extraPadding)
                    }
                } else {
                    view.snp.updateConstraints { make in
                        make.top.equalTo(self.iconTopPadding(state: state) + extraPadding)
                    }
                }
            }

            bag += layoutTitleAlphaSignal.atOnce().bindTo(view, \.alpha)
        }

        let remoteVectorIcon = RemoteVectorIcon()

        let pdfUrl = URL(
            string: "https://graphql.dev.hedvigit.com\(data.icon.pdfUrl)"
        )
        remoteVectorIcon.pdfUrl.value = pdfUrl

        bag += contentView.add(remoteVectorIcon) { imageView in
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview().inset(15)
                make.width.equalTo(30)
                make.height.equalTo(30)
            }

            bag += iconTopPaddingStateSignal.atOnce().onValue { state in
                if state == .normal {
                    imageView.snp.updateConstraints { make in
                        make.top.equalToSuperview().inset(self.iconTopPadding(state: state))
                    }
                } else {
                    imageView.snp.updateConstraints { make in
                        make.top.equalToSuperview().inset(self.iconTopPadding(state: state))
                    }
                }
            }
        }

        let touchDownDateSignal = ReadWriteSignal<Date>(Date())

        bag += contentView
            .signal(for: .touchDown)
            .map { Date() }
            .bindTo(touchDownDateSignal)

        bag += contentView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += contentView.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }

        bag += merge(
            contentView.signal(for: UIControl.Event.touchUpInside),
            contentView.signal(for: UIControl.Event.touchUpOutside),
            contentView.signal(for: UIControl.Event.touchCancel)
        ).withLatestFrom(touchDownDateSignal.atOnce().plain())
            .delay(by: { _, date in date.timeIntervalSinceNow < -0.2 ? 0 : 0.2 })
            .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                contentView.transform = CGAffineTransform.identity
            }

        let closeButton = CloseButton()

        bag += view.add(closeButton) { closeButtonView in
            bag += showCloseButton.atOnce().map { !$0 }.bindTo(closeButtonView, \.isHidden)
            bag += showCloseButton.atOnce().map { $0 ? 1 : 0 }.bindTo(closeButtonView, \.alpha)

            closeButtonView.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.top.equalTo(50)
                make.width.equalTo(30)
                make.height.equalTo(30)
            }

            bag += closeButtonView.signal(for: .touchUpInside).onValue {
                self.closeCallbacker.callAll()
            }

            bag += scrollPositionSignal.onValue { point in
                closeButtonView.transform = CGAffineTransform(translationX: 0, y: point.y)
            }
        }

        if includeButton {
            let claimButton = Button(
                title: data.layout.asTitleAndBulletPoints?.buttonTitle ?? "",
                type: .standard(backgroundColor: .purple, textColor: .white)
            )

            bag += view.add(claimButton) { claimButtonView in
                bag += showClaimButtonSignal.atOnce().map { !$0 }.bindTo(claimButtonView, \.isHidden)
                bag += showClaimButtonSignal.atOnce().map { $0 ? 1 : 0 }.bindTo(claimButtonView, \.alpha)

                claimButtonView.snp.makeConstraints { make in
                    make.bottom.equalTo(-15)
                    make.centerX.equalToSuperview()
                }
            }
        }

        bag += contentView.signal(for: .touchUpInside).onValue { _ in
            if let _ = self.data.layout.asTitleAndBulletPoints {
                self.presentingViewController.present(
                    CommonClaimTitleAndBulletPoints(
                        commonClaimCard: CommonClaimCard(data: self.data, index: self.index, presentingViewController: self.presentingViewController),
                        originView: view
                    ),
                    style: .modally(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        capturesStatusBarAppearance: true
                    ),
                    options: [],
                    configure: { vc, bag in
                        let newCommonClaimCard = CommonClaimCard(data: self.data, index: self.index, presentingViewController: self.presentingViewController)
                        let delegate = CardControllerTransitioningDelegate(
                            originView: contentView,
                            commonClaimCard: newCommonClaimCard
                        )
                        bag.hold(delegate)
                        vc.transitioningDelegate = delegate
                    }
                )
            }

            if let _ = self.data.layout.asEmergency {
                self.presentingViewController.present(
                    CommonClaimEmergency(
                        commonClaimCard: CommonClaimCard(data: self.data, index: self.index, presentingViewController: self.presentingViewController)
                    ),
                    style: .modally(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        capturesStatusBarAppearance: true
                    ),
                    options: [],
                    configure: { vc, bag in
                        let newCommonClaimCard = CommonClaimCard(data: self.data, index: self.index, presentingViewController: self.presentingViewController)
                        let delegate = CardControllerTransitioningDelegate(
                            originView: contentView,
                            commonClaimCard: newCommonClaimCard
                        )
                        bag.hold(delegate)
                        vc.transitioningDelegate = delegate
                    }
                )
            }
        }

        return (view, bag)
    }
}

extension CommonClaimCard: Reusable {
    public static func makeAndConfigure() -> (
        make: UIView,
        configure: (CommonClaimCard) -> Disposable
    ) {
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true

        return (containerView, { commonClaimCard in
            let bag = DisposeBag()

            containerView.layoutMargins = UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0
            )

            bag += containerView.addArranged(commonClaimCard)

            return bag
        })
    }
}
