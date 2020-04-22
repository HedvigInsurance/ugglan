//
//  OfferSignButton.swift
//  test
//
//  Created by sam on 23.3.20.
//

import Flow
import Foundation
import UIKit

struct OfferSignButton {
    private let callbacker = Callbacker<Void>()

    var onTapSignal: Signal<Void> {
        return callbacker.providedSignal
    }
}

extension OfferSignButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 5

        let contentContainer = UIStackView()
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        let button = Button(
            title: String(key: .OFFER_SIGN_BUTTON),
            type: .standardIcon(
                backgroundColor: .black,
                textColor: .white,
                icon: .left(image: Asset.bankIdLogo.image, width: 20)
            )
        )

        bag += contentContainer.addArranged(button)

        bag += button.onTapSignal.onValue { _ in
            self.callbacker.callAll()
        }

        return (view, bag)
    }
}
