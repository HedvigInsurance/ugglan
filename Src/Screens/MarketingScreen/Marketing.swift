//  Marketing.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-25.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct Marketing {
    @Inject var client: ApolloClient
}

extension Marketing {
    func prefetch() {
        client.fetch(query: MarketingQuery(languageCode: Localization.Locale.currentLocale.code)).onValue { _ in }
    }
}

extension Marketing: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = LightContentViewController()

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.backgroundColor = UIColor.black
        viewController.view = containerView

        ApplicationState.preserveState(.marketing)
        
        let imageView = UIImageView()

        containerView.addSubview(imageView)
                   
       imageView.snp.makeConstraints { make in
           make.top.bottom.leading.trailing.equalToSuperview()
       }

        let wordmarkImageView = UIImageView()
        wordmarkImageView.contentMode = .scaleAspectFill
        wordmarkImageView.image = Asset.wordmarkWhite.image
        containerView.addSubview(wordmarkImageView)
        
        wordmarkImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        bag += client.fetch(query: MarketingQuery(languageCode: Localization.Locale.currentLocale.code), cachePolicy: .returnCacheDataElseFetch)
            .valueSignal
            .compactMap { $0.data?.appMarketingImages.first }
            .compactMap { $0 }
            .onValue { marketingImage in
                guard let url = URL(string: marketingImage.image?.url ?? "") else {
                    return
                }
                
            imageView.contentMode = .scaleAspectFill
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(blurHash: marketingImage.blurhash ?? "", size: .init(width: 32, height: 32)),
                options: [
                    .transition(.fade(0.25))
                ]
            )
        }
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 15
        contentStackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        containerView.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints { make in
            make.bottom.trailing.leading.equalToSuperview()
        }
        
        let onboardButton = Button(title: String(key: .MARKETING_GET_HEDVIG), type: .standard(backgroundColor: .white, textColor: .black))
        
        bag += onboardButton.onTapSignal.onValue { _ in
            viewController.present(Onboarding(), style: .default, options: [.defaults, .prefersNavigationBarHidden(false)])
        }
        
        bag += contentStackView.addArranged(onboardButton)
        
        let loginButton = Button(title: String(key: .MARKETING_LOGIN), type: .standardOutline(borderColor: .white, textColor: .white))
        
        bag += loginButton.onTapSignal.onValue { _ in
            viewController.present(BankIDLogin(), style: .modally())
        }
        
        bag += contentStackView.addArranged(loginButton)
        
        bag += contentStackView.addArranged(MultilineLabel(value: String(key: .MARKETING_LEGAL), style: TextStyle.bodyXSmallXSmallCenter.colored(.white)).wrappedIn(UIStackView())) { stackView in
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
        }
        
        return (viewController, bag)
    }
}
