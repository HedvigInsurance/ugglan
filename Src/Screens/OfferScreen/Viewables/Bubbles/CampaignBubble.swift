//
//  CampaignBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-19.
//

import Foundation
import Flow
import UIKit
import Form

struct CampaignBubble {
    let campaignTypeSignal: ReadSignal<CampaignType?>
    
    enum CampaignType {
        case freeMonths(number: Int), invited
    }
}

extension CampaignBubble: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIView()
        containerView.backgroundColor = .pink
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 5
        containerView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        bag += containerView.didLayoutSignal.onValue { _ in
            containerView.layer.cornerRadius = view.frame.width / 2
        }
        
        let titleLabel = UILabel(value: "", style: TextStyle.body.centerAligned.colored(.white))
        view.addArrangedSubview(titleLabel)
        
        let subtitlelabel = UILabel(value: "", style: TextStyle.bodyBold.centerAligned.colored(.white))
        subtitlelabel.numberOfLines = 0
        
        bag += subtitlelabel.didLayoutSignal.onValue { _ in
            subtitlelabel.preferredMaxLayoutWidth = subtitlelabel.frame.size.width
        }
                
        view.addArrangedSubview(subtitlelabel)
        
        containerView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
        containerView.alpha = 0
        
        bag += campaignTypeSignal.animated(style: SpringAnimationStyle.mediumBounce()) { value in
            if let value = value {
                containerView.alpha = 1
                containerView.transform = CGAffineTransform.identity
                
                switch value {
                case let .freeMonths(number):
                    titleLabel.text = String(key: .OFFER_SCREEN_FREE_MONTHS_BUBBLE_TITLE)
                    titleLabel.animationSafeIsHidden = false
                    subtitlelabel.text = String(key: .OFFER_SCREEN_FREE_MONTHS_BUBBLE(freeMonth: number))
                case .invited:
                    titleLabel.text = ""
                    titleLabel.animationSafeIsHidden = true
                    subtitlelabel.text = String(key: .OFFER_SCREEN_INVITED_BUBBLE)
                }
            } else {
                titleLabel.animationSafeIsHidden = true
                titleLabel.text = ""
                subtitlelabel.text = ""
                
                containerView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001).concatenating(CGAffineTransform(translationX: 0, y: -30))
                containerView.alpha = 0
            }
        }

        return (containerView, bag)
    }
}
