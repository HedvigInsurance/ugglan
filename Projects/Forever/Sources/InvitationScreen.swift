//
//  InvitationScreen.swift
//  Forever
//
//  Created by sam on 1.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Presentation
import Flow
import hCoreUI
import hCore

public struct InvitationScreen {
    public init() {}
}

extension InvitationScreen: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let closeButton = UIBarButtonItem(title: "Close")
        viewController.navigationItem.rightBarButtonItem = closeButton
        
        let imageTextAction = ImageTextAction<Void>(
            image: .init(image: Asset.invitationIllustration.image),
            title: L10n.ReferralsIntroScreen.title,
            body: L10n.ReferralsIntroScreen.body,
            actions: [
                (
                    (),
                    Button(
                        title: L10n.ReferralsIntroScreen.button,
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                )
            ],
            showLogo: false
        )
                
        bag += viewController.install(imageTextAction).nil()
        
        return (viewController, bag)
    }
}
