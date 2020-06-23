//
//  InfoAndTerms.swift
//  Forever
//
//  Created by sam on 23.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import UIKit
import Presentation
import hCore
import hCoreUI
import SafariServices

public struct InfoAndTerms {
    public init() {}
}

extension InfoAndTerms: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let closeBarButton = UIBarButtonItem(title: L10n.NavBar.close)
        viewController.navigationItem.rightBarButtonItem = closeBarButton

        let imageTextAction = ImageTextAction<Void>(
            image: .init(image: Asset.infoAndTermsIllustration.image),
            title: L10n.ReferralsInfoSheet.headline,
            body: L10n.ReferralsInfoSheet.body,
            actions: [
                (
                  (),
                  Button(
                      title: L10n.ReferralsInfoSheet.fullTermsAndConditions,
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
                viewController.present(SFSafariViewController(url: URL(string: L10n.referralsTermsWebsiteUrl)!), animated: true, completion: nil)
            }

            bag += closeBarButton.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
