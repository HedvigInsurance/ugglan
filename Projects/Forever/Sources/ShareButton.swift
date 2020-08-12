//
//  ShareButton.swift
//  Forever
//
//  Created by sam on 23.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
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
        
        let tabBarBackgroundColor = UIColor(dynamic: { trait -> UIColor in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
            }
            
            return UIColor.white
        })
        containerView.backgroundColor = tabBarBackgroundColor
        
        let colorView = UIView()
        containerView.insertSubview(colorView, at: 0)
        
        colorView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        bag += ContextGradient.currentOption.atOnce().animated(style: .easeOut(duration: 1)) { option in
            colorView.backgroundColor = option.colors.first?.withAlphaComponent(0.15)
        }
        
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(inset: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        containerView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        bag += stackView.addArranged(loadableButton)

        return (containerView, loadableButton.onTapSignal.hold(bag).map { containerView })
    }
}
