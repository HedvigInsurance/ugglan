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
    
    let backgroundColorSignal = ReadWriteSignal<UIColor>(.white)
    let cornerRadiusSignal = ReadWriteSignal<CGFloat>(8)
    let iconTopPaddingSignal = ReadWriteSignal<CGFloat>(15)
    let titleAlphaSignal = ReadWriteSignal<CGFloat>(1)
    let layoutTitleAlphaSignal = ReadWriteSignal<CGFloat>(0)
    let controlIsEnabledSignal = ReadWriteSignal<Bool>(true)
    let shadowOpacitySignal = ReadWriteSignal<Float>(0.05)
    
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
    }
}

extension CommonClaimCard: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        
        let bag = DisposeBag()
        
        let contentView = UIControl()
        bag += controlIsEnabledSignal.atOnce().bindTo(contentView, \.isEnabled)
        bag += backgroundColorSignal.atOnce().bindTo(contentView, \.backgroundColor)
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
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(15)
            make.width.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(15)
        }
        bag += titleAlphaSignal.atOnce().bindTo(titleLabel, \.alpha)
        
        let layoutTitleLabel = MultilineLabel(styledText: StyledText(
                text: "Blir ditt bagage försenat när du reser ersätter Hedvig dig för att du ska kunna köpa saker du behöver. Hur mycket du får beror på hur lång tid ditt bagage är försenat",
                style: .standaloneLargeTitle
            )
        )
        bag += contentView.add(layoutTitleLabel) { view in
            view.snp.makeConstraints { make in
                make.top.equalTo(self.iconTopPaddingSignal.value + 20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().inset(15)
                make.height.equalTo(200)
            }
            
            bag += iconTopPaddingSignal.onValue({ newValue in
                view.snp.updateConstraints({ make in
                    make.top.equalToSuperview().inset(newValue + 20)
                })
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
                make.top.equalToSuperview().inset(self.iconTopPaddingSignal.value)
                make.left.equalToSuperview().inset(15)
                make.width.equalTo(30)
                make.height.equalTo(30)
            })
            
            bag += iconTopPaddingSignal.onValue({ newValue in
                imageView.snp.updateConstraints({ make in
                    make.top.equalToSuperview().inset(newValue)
                })
            })
        }
        
        let touchDownDateSignal = ReadWriteSignal<Date>(Date())
        
        bag += contentView
            .signal(for: .touchDown)
            .map { Date() }
            .bindTo(touchDownDateSignal)
        
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
        
        bag += contentView.signal(for: .touchUpInside).onValue { _ in
            if let _ = self.data.layout.asTitleAndBulletPoints {
                self.presentingViewController.present(
                    CommonClaimTitleAndBulletPoints(commonClaimCard: CommonClaimCard(data: self.data, index: self.index, presentingViewController: self.presentingViewController)),
                    style: .modally(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        capturesStatusBarAppearance: true
                    ),
                    options: [],
                    configure: { vc, bag in
                        let newCommonClaimCard = CommonClaimCard(data: self.data, index: self.index, presentingViewController: self.presentingViewController)
                        let delegate = CardControllerTransitioningDelegate(originView: contentView, commonClaimCard: newCommonClaimCard)
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
