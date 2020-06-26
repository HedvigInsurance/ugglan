//
//  ShareButton.swift
//  Forever
//
//  Created by sam on 23.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import UIKit
import hCore
import hCoreUI

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
    func materialize(events: ViewableEvents) -> (UIView, Signal<UIView>) {
        let bag = DisposeBag()
        let containerView = UIVisualEffectView()
        containerView.preservesSuperviewLayoutMargins = true
        containerView.effect = UIBlurEffect(style: .prominent)
        
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
