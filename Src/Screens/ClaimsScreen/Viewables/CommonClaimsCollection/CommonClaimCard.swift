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

struct CommonClaimCard {
    let data: CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex
    let onTapSignal: Signal<Void>
    private let onTapCallbacker: Callbacker<Void>
    
    init(
        data: CommonClaimsQuery.Data.CommonClaim,
        index: TableIndex
    ) {
        self.index = index
        self.data = data
        self.onTapCallbacker = Callbacker<Void>()
        self.onTapSignal = self.onTapCallbacker.signal()
    }
}

extension CommonClaimCard: Reusable {
    public static func makeAndConfigure() -> (
        make: UIView,
        configure: (CommonClaimCard) -> Disposable
    ) {
            let containerView = UIStackView()
            containerView.isLayoutMarginsRelativeArrangement = true
            
            let view = UIStackView()
            containerView.addArrangedSubview(view)
            
            let contentView = UIControl()
            contentView.layer.cornerRadius = 8
            contentView.backgroundColor = .white
            
            contentView.layer.shadowOpacity = 0.05
            contentView.layer.shadowOffset = CGSize(width: 0, height: 16)
            contentView.layer.shadowRadius = 30
            contentView.layer.shadowColor = UIColor.black.cgColor
            
            view.addArrangedSubview(contentView)
            
            contentView.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
            
            let titleLabel = UILabel(value: "", style: .rowTitle)
            contentView.addSubview(titleLabel)
            
            titleLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(15)
                make.width.equalToSuperview().inset(15)
                make.centerX.equalToSuperview()
                make.height.equalTo(15)
            }
        
            let remoteVectorIcon = RemoteVectorIcon()
            
            return (containerView, { commonClaim in
                let bag = DisposeBag()
                
                let dividedIndex = Double(commonClaim.index.row) / 2
                let isFirstInRow = rint(dividedIndex) == dividedIndex
                
                containerView.layoutMargins = UIEdgeInsets(
                    top: 10,
                    left: isFirstInRow ? 15 : 5,
                    bottom: 10,
                    right: isFirstInRow ? 5 : 15
                )
                
                let pdfUrl = URL(
                    string: "https://graphql.dev.hedvigit.com\(commonClaim.data.icon.pdfUrl)"
                )
                remoteVectorIcon.pdfUrl.value = pdfUrl
                
                bag += contentView.add(remoteVectorIcon) { imageView in
                    imageView.snp.makeConstraints({ make in
                        make.top.equalToSuperview().inset(15)
                        make.left.equalToSuperview().inset(15)
                        make.width.equalTo(30)
                        make.height.equalTo(30)
                    })
                }
                
                titleLabel.text = commonClaim.data.title
                
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
                    commonClaim.onTapCallbacker.callAll()
                }
                
                return bag
            })
    }
}
