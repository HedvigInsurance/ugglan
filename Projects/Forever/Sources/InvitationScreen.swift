//
//  InvitationScreen.swift
//  Forever
//
//  Created by sam on 1.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

public struct InvitationScreen {
    public init() {}
}

extension InvitationScreen: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

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
                ),
            ],
            showLogo: false
        )

        return (viewController, Future { completion in
            bag += viewController.install(imageTextAction).onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
