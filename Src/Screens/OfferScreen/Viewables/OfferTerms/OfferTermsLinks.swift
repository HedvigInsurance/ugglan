//
//  OfferTermsLinks.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct OfferTermsLinks {
    let client: ApolloClient
    
    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension OfferTermsLinks {
    struct Link: Viewable {
        let icon: ImageAsset
        let text: String
        let url: URL
        
        func materialize(events: ViewableEvents) -> (UIControl, Disposable) {
            let bag = DisposeBag()
            
            let control = UIControl()
            
            bag += control.signal(for: .touchUpInside).feedback(type: .impactLight)

            bag += control.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                control.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }

            bag += control.delayedTouchCancel().animated(style: SpringAnimationStyle.lightBounce()) { _ in
                control.transform = CGAffineTransform.identity
            }
            
            bag += control.signal(for: .touchUpInside).onValue { _ in
                control.viewController?.present(SafariView(url: self.url), options: [])
            }
            
            let stackView = UIStackView()
            stackView.spacing = 10
            stackView.axis = .vertical
            stackView.isUserInteractionEnabled = false
            
            control.addSubview(stackView)
            
            stackView.snp.makeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }
            
            let iconView = Icon(icon: icon, iconWidth: 40)
            stackView.addArrangedSubview(iconView)
            
            let label = MultilineLabel(value: text, style: TextStyle.rowSubtitle.centerAligned)
            bag += stackView.addArranged(label)
            
            return (control, bag)
        }
    }
}

extension OfferTermsLinks: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        
        bag += client.fetch(query: OfferQuery()).valueSignal.compactMap { $0.data?.insurance }.onValueDisposePrevious { insurance in
            let innerBag = DisposeBag()
            
            if let policyUrl = URL(string: insurance.policyUrl) {
                innerBag += stackView.addArranged(Link(
                    icon: Asset.offerTermsLink,
                    text: String(key: .OFFER_TERMS),
                    url: policyUrl
                ))
            }
            
            if let presaleUrl = URL(string: insurance.presaleInformationUrl) {
                innerBag += stackView.addArranged(Link(
                    icon: Asset.offerPresaleLink,
                    text: String(key: .OFFER_PRESALE_INFORMATION),
                    url: presaleUrl
                ))
            }
            
            if let privacyPolicyUrl =  URL(key: .PRIVACY_POLICY_URL) {
                innerBag += stackView.addArranged(Link(
                    icon: Asset.offerPolicyLink,
                    text: String(key: .OFFER_PRIVACY_POLICY),
                    url: privacyPolicyUrl
                ))
            }
            
            return innerBag
        }
        
        return (stackView, bag)
    }
}

