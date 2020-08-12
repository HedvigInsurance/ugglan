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
        let containerView = UIVisualEffectView()
        containerView.preservesSuperviewLayoutMargins = true
        if #available(iOS 13.0, *) {
            containerView.effect = UIBlurEffect(style: .systemChromeMaterial)
        } else {
            containerView.effect = UIBlurEffect(style: .prominent)
        }
        
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(inset: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        containerView.contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        bag += stackView.addArranged(loadableButton)

        return (containerView, loadableButton.onTapSignal.hold(bag).map { containerView })
    }
}
