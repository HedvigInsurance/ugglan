//
//  ShareButton.swift
//  Forever
//
//  Created by sam on 23.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct ShareButton {
    let loadableButton = LoadableButton(button: Button(
        title: L10n.ReferralsEmpty.shareCodeButton,
        type: .standard(
            backgroundColor: .brand(.primaryButtonBackgroundColor),
            textColor: .brand(.primaryButtonTextColor)
        )
    ))
}

extension ShareButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<UIView>) {
        let bag = DisposeBag()
        let containerView = UIView()

        let separator = UIView()
        separator.backgroundColor = UIColor.brand(.primaryBorderColor)
        containerView.addSubview(separator)

        separator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.hairlineWidth)
        }

        bag += containerView.didMoveToWindowSignal.onValue { _ in
            if let tabBarController = containerView.viewController?.navigationController?.tabBarController {
                tabBarController.tabBar.shadowImage = UIColor.clear.asImage()
            }
        }

        bag += containerView.didMoveFromWindowSignal.onValue { _ in
            if let tabBarController = containerView.viewController?.navigationController?.tabBarController {
                tabBarController.tabBar.shadowImage = UIColor.brand(.primaryBorderColor).asImage()
            }
        }

        containerView.backgroundColor = DefaultStyling.tabBarBackgroundColor

        let colorView = ContextGradient.makeColorView(into: bag, for: .tabBar)
        containerView.insertSubview(colorView, at: 0)

        colorView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        bag += stackView.traitCollectionSignal.atOnce().onValue { trait in
            let style = DynamicFormStyle.brandInset.style(from: trait)
            let insets = style.insets
            stackView.layoutMargins = UIEdgeInsets(top: 15, left: insets.left, bottom: 15, right: insets.right)
        }

        bag += stackView.addArranged(loadableButton)

        return (containerView, loadableButton.onTapSignal.hold(bag).map { containerView })
    }
}
