//
//  CommonClaimCard.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct CommonClaimCard {
    let data: CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient

    enum State {
        case normal, expanded
    }

    let backgroundStateSignal = ReadWriteSignal<State>(.normal)
    let cornerRadiusSignal = ReadWriteSignal<CGFloat>(8)
    let iconTopPaddingStateSignal = ReadWriteSignal<State>(.normal)
    let titleLabelStateSignal = ReadWriteSignal<State>(.normal)
    let controlIsEnabledSignal = ReadWriteSignal<Bool>(true)
    let shadowOpacitySignal = ReadWriteSignal<Float>(0.05)
    let showTitleCloseButton = ReadWriteSignal<Bool>(false)
    let showClaimButtonSignal = ReadWriteSignal<Bool>(false)
    let scrollPositionSignal = ReadWriteSignal<CGPoint>(CGPoint(x: 0, y: 0))

    let claimButtonTapSignal: Signal<Void>
    let closeSignal: Signal<Void>
    private let closeCallbacker: Callbacker<Void>
    private let claimButtonTapCallbacker: Callbacker<Void>

    func iconTopPadding(state: State) -> CGFloat {
        return state == .normal ? 15 : 65 + safeAreaTop
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

        let buttonPadding: CGFloat = includeButton ? 70 : 0

        return state == .normal ? 0 : (size.height + iconTopPadding(state: state) + 60 + buttonPadding)
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

    var safeAreaTop: CGFloat {
        let keyWindow = UIApplication.shared.keyWindow
        return keyWindow?.safeAreaInsets.top ?? 0
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
        claimButtonTapCallbacker = Callbacker()
        claimButtonTapSignal = claimButtonTapCallbacker.signal()
    }
}

extension CommonClaimCard: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()

        let bag = DisposeBag()

        func backgroundColorFromData() -> UIColor {
            return UIColor.primaryBackground
        }

        let contentView = UIControl()
        bag += controlIsEnabledSignal.atOnce().bindTo(contentView, \.isEnabled)
        bag += backgroundStateSignal.atOnce().map {
            $0 == .normal ? UIColor.secondaryBackground : backgroundColorFromData()
        }.bindTo(contentView, \.backgroundColor)
        bag += cornerRadiusSignal.atOnce().bindTo(contentView, \.layer.cornerRadius)

        bag += shadowOpacitySignal.atOnce().bindTo(contentView, \.layer.shadowOpacity)

        bag += contentView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: self.shadowOpacitySignal.value,
                offset: CGSize(width: 0, height: 16),
                radius: 30,
                color: .primaryShadowColor,
                path: nil
            )
        }

        view.addArrangedSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        let expandedHeaderView = UIView()
        bag += backgroundStateSignal.atOnce().map {
            $0 == .normal ? UIColor.white : backgroundColorFromData()
        }.bindTo(expandedHeaderView, \.backgroundColor)
        expandedHeaderView.alpha = 0

        view.addSubview(expandedHeaderView)

        expandedHeaderView.snp.makeConstraints { make in
            make.height.equalTo(safeAreaTop)
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalToSuperview()
        }

        let titleLabel = UILabel(value: data.title, style: .rowTitle)
        titleLabel.numberOfLines = 0
        titleLabel.layer.zPosition = 2

        bag += titleLabel.didLayoutSignal.onValue { _ in
            titleLabel.preferredMaxLayoutWidth = titleLabel.frame.width
        }

        view.addSubview(titleLabel)

        bag += scrollPositionSignal.onValue { point in
            titleLabel.transform = CGAffineTransform(translationX: 0, y: point.y)
            expandedHeaderView.transform = CGAffineTransform(translationX: 0, y: point.y)

            if point.y != 0 {
                expandedHeaderView.alpha = 1
            }
        }

        bag += titleLabelStateSignal.atOnce().onValueDisposePrevious { newState in
            let labelSizeBag = bag.innerBag()

            if newState == .normal {
                titleLabel.snp.remakeConstraints { make in
                    make.bottom.equalToSuperview().inset(15)
                    make.width.equalToSuperview().inset(15)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(titleLabel.intrinsicContentSize.height)
                }

                labelSizeBag += titleLabel.didLayoutSignal.onValue { _ in
                    titleLabel.snp.updateConstraints { make in
                        make.height.equalTo(titleLabel.intrinsicContentSize.height)
                    }
                }
            } else {
                let attributedString = NSAttributedString(styledText: StyledText(
                    text: titleLabel.text ?? "",
                    style: titleLabel.style
                ))

                let size = attributedString.boundingRect(
                    with: CGSize(width: UIScreen.main.bounds.width, height: 1000),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )

                titleLabel.snp.remakeConstraints { make in
                    make.top.equalToSuperview().inset(20 + self.safeAreaTop)
                    make.width.equalTo(size.width + 2)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(size.height)
                }
            }

            return labelSizeBag
        }

        let layoutTitleLabel = MultilineLabel(styledText: StyledText(
            text: layoutTitle,
            style: .standaloneLargeTitle
        ))
        bag += contentView.add(layoutTitleLabel) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(0)
                make.leading.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(15)
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

            bag += showTitleCloseButton.atOnce().map { !$0 }.bindTo(view, \.isHidden)
            bag += showTitleCloseButton.atOnce().map { $0 ? 1 : 0 }.bindTo(view, \.alpha)
        }

        let remoteVectorIcon = RemoteVectorIcon()
        remoteVectorIcon.iconSignal.value = data.icon.fragments.iconFragment

        bag += contentView.add(remoteVectorIcon) { imageView in
            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
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

        bag += contentView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += contentView.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }

        bag += contentView.delayedTouchCancel().animated(style: SpringAnimationStyle.lightBounce()) { _ in
            view.transform = CGAffineTransform.identity
            contentView.transform = CGAffineTransform.identity
        }

        let closeButton = CloseButton()

        bag += view.add(closeButton) { closeButtonView in
            bag += showTitleCloseButton.atOnce().map { !$0 }.bindTo(closeButtonView, \.isHidden)
            bag += showTitleCloseButton.atOnce().map { $0 ? 1 : 0 }.bindTo(closeButtonView, \.alpha)

            closeButtonView.snp.makeConstraints { make in
                make.left.equalTo(view.safeAreaLayoutGuide).inset(10)
                make.top.equalTo(15 + self.safeAreaTop)
            }

            bag += closeButtonView.signal(for: .touchUpInside).onValue {
                self.closeCallbacker.callAll()
            }

            bag += closeButtonView.didLayoutSignal.onValue { _ in
                view.bringSubviewToFront(closeButtonView)
            }

            bag += scrollPositionSignal.onValue { point in
                closeButtonView.transform = CGAffineTransform(translationX: 0, y: point.y)
            }
                        
            bag += scrollPositionSignal.atOnce().onValue { point in
                let offset = point.y / 100
                let newAlphaValue = 1.0 - offset
                
                if newAlphaValue >= 0 && newAlphaValue <= 1 {
                    closeButtonView.alpha = newAlphaValue
                    titleLabel.alpha = newAlphaValue
                }
            }
            
        }

        if includeButton {
            let claimButton = Button(
                title: data.layout.asTitleAndBulletPoints?.buttonTitle ?? "",
                type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
            )

            bag += claimButton.onTapSignal.onValue {
                self.claimButtonTapCallbacker.callAll()
            }

            bag += view.add(claimButton) { claimButtonView in
                claimButtonView.alpha = 0

                let isEligibleDataSignal = client.watch(query: EligibleToCreateClaimQuery()).compactMap { $0.data?.isEligibleToCreateClaim }

                bag += isEligibleDataSignal.bindTo(claimButtonView, \.isUserInteractionEnabled)

                bag += showClaimButtonSignal.atOnce().map { !$0 }.bindTo(claimButtonView, \.isHidden)
                bag += combineLatest(showClaimButtonSignal.atOnce().plain(), isEligibleDataSignal)
                    .map { showButton, isEligibleToCreateClaim in
                        if showButton {
                            return isEligibleToCreateClaim ? 1 : 0.5
                        }

                        return 0
                    }
                    .onValue { alpha in
                        claimButtonView.alpha = alpha
                    }

                bag += showClaimButtonSignal.onValue { _ in
                    contentView.sendSubviewToBack(claimButtonView)
                }

                claimButtonView.snp.makeConstraints { make in
                    make.bottom.equalTo(-28)
                    make.centerX.equalToSuperview()
                    make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
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

        view.bringSubviewToFront(expandedHeaderView)

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
