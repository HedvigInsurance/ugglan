//
//  CommonClaimCard.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Foundation
import Flow
import Form
import UIKit
import Presentation

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
    
    let closeSignal: Signal<Void>
    private let closeCallbacker: Callbacker<Void>
    
    func iconTopPadding(state: State) -> CGFloat {
        return state == .normal ? 15 : 100
    }
    
    func height(state: State) -> CGFloat {
        let attributedString = NSAttributedString(styledText: StyledText(
            text: data.layout.asTitleAndBulletPoints?.title ?? "",
            style: .standaloneLargeTitle
        ))
        
        let size = attributedString.boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 20, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return state == .normal ? 0 : (size.height + iconTopPadding(state: state) + 90)
    }
    
    var isFirstInRow: Bool {
        let dividedIndex = Double(index.row) / 2
        return rint(dividedIndex) == dividedIndex
    }
    
    init(
        data: CommonClaimsQuery.Data.CommonClaim,
        index: TableIndex,
        presentingViewController: UIViewController
    ) {
        self.index = index
        self.data = data
        self.presentingViewController = presentingViewController
        self.closeCallbacker = Callbacker()
        self.closeSignal = closeCallbacker.signal()
    }
}

extension CommonClaimCard: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        
        let bag = DisposeBag()
        
        func backgroundColorFromData() -> UIColor {
            let lightenedAmount: CGFloat = 0.5
            
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
        
        let titleLabel = UILabel(value: data.title, style: .rowTitle)
        contentView.addSubview(titleLabel)
        
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
                text: data.layout.asTitleAndBulletPoints?.title ?? "",
                style: .standaloneLargeTitle
            )
        )
        bag += contentView.add(layoutTitleLabel) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(0)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().inset(15)
                make.height.equalTo(200)
            }
            
            bag += iconTopPaddingStateSignal.atOnce().onValue({ state in
                let extraPadding: CGFloat = 20
                
                if state == .normal {
                    view.snp.updateConstraints({ make in
                        make.top.equalTo(self.iconTopPadding(state: state) + extraPadding)
                    })
                } else {
                    view.snp.updateConstraints({ make in
                        make.top.equalTo(self.iconTopPadding(state: state) + extraPadding)
                    })
                }
            })
            
            bag += layoutTitleAlphaSignal.atOnce().bindTo(view, \.alpha)
        }
        
        
        let remoteVectorIcon = RemoteVectorIcon()
        
        let pdfUrl = URL(
            string: "https://graphql.dev.hedvigit.com\(data.icon.pdfUrl)"
        )
        remoteVectorIcon.pdfUrl.value = pdfUrl
        
        bag += contentView.add(remoteVectorIcon) { imageView in
            imageView.snp.makeConstraints({ make in
                make.top.equalToSuperview()
                make.left.equalToSuperview().inset(15)
                make.width.equalTo(30)
                make.height.equalTo(30)
            })
            
            bag += iconTopPaddingStateSignal.atOnce().onValue({ state in
                if state == .normal {
                    imageView.snp.updateConstraints({ make in
                        make.top.equalToSuperview().inset(self.iconTopPadding(state: state))
                    })
                } else {
                    imageView.snp.updateConstraints({ make in
                        make.top.equalToSuperview().inset(self.iconTopPadding(state: state))
                    })
                }
            })
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
            
            closeButtonView.snp.makeConstraints { make in
                make.left.equalTo(10)
                make.top.equalTo(50)
                make.width.equalTo(30)
                make.height.equalTo(30)
            }
            
            bag += closeButtonView.signal(for: .touchUpInside).onValue {
                self.closeCallbacker.callAll()
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
            
            if let layout = self.data.layout.asEmergency {
                self.presentingViewController.present(
                    CommonClaimEmergency(layout: layout),
                    style: .modally()
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
                left: commonClaimCard.isFirstInRow ? 15 : 5,
                bottom: 10,
                right: commonClaimCard.isFirstInRow ? 5 : 15
            )
            
           bag += containerView.addArangedSubview(commonClaimCard)
            
            return bag
        })
    }
}
