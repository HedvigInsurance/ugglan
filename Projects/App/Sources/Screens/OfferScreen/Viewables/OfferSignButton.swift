//
//  OfferSignButton.swift
//  test
//
//  Created by sam on 23.3.20.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

struct OfferSignButton {
    private let callbacker = Callbacker<Void>()
    var onTapSignal: Signal<Void> {
        callbacker.providedSignal
    }

    let scrollView: UIScrollView
}

extension OfferSignButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .secondaryBackground

        let contentContainer = UIStackView()
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        bag += scrollView.didLayoutSignal.onValue { _ in
            contentContainer.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: scrollView.safeAreaInsets.bottom + 10, right: 16)
        }

        let button = Button(
            title: L10n.offerSignButton,
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
