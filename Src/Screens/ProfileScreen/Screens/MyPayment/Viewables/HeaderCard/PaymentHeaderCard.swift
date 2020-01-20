//
//  PaymentHeaderCard.swift
//  production
//
//  Created by Sam Pettersson on 2020-01-17.
//

import Foundation
import Flow
import Apollo
import UIKit
import Form

struct PaymentHeaderCard {
    @Inject var client: ApolloClient
}

extension PaymentHeaderCard: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let view = UIStackView()
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        let bag = DisposeBag()
        
        let topView = UIView()
        topView.backgroundColor = .grass500
        
        bag += topView.didLayoutSignal.onValue { _ in
            topView.applyRadiusMaskFor(topLeft: 10, bottomLeft: 0, bottomRight: 0, topRight: 10)
        }
        
        let topViewStack = UIStackView()
        topViewStack.layoutMargins = UIEdgeInsets(inset: 20)
        topViewStack.isLayoutMarginsRelativeArrangement = true
        topView.addSubview(topViewStack)
        
        topViewStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        topViewStack.addArrangedSubview(UILabel(value: "Nästa betalning", style: TextStyle.blockRowTitle.colored(.white)))
        
        view.addArrangedSubview(topView)
        
        let bottomView = UIView()
        bag += bottomView.applyShadow { trait in
            UIView.ShadowProperties(
                opacity: 0.05,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: UIColor.primaryShadowColor,
                path: nil
            )
        }
        bottomView.backgroundColor = .secondaryBackground
        
        bag += bottomView.didLayoutSignal.onValue { _ in
            bottomView.applyRadiusMaskFor(topLeft: 0, bottomLeft: 10, bottomRight: 10, topRight: 0)
        }
        
        let bottomViewStack = UIStackView()
        bottomViewStack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        bottomViewStack.isLayoutMarginsRelativeArrangement = true
        bottomView.addSubview(bottomViewStack)
        
        bottomViewStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        bottomViewStack.addArrangedSubview(UILabel(value: "Datum", style: .body))
        bag += bottomViewStack.addArranged(PaymentHeaderNextCharge())
        
        view.addArrangedSubview(bottomView)
        
        return (view, bag)
    }
}
