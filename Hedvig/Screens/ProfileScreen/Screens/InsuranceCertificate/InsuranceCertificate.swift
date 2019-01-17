//
//  InsuranceCertificate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit

struct InsuranceCertificate {
    let certificateUrl: String
}

extension PresentationStyle {
    static let activityView = PresentationStyle(name: "activityView") { viewController, from, _ in
        let future = Future<Void> { completion in
            from.present(viewController, animated: true) {
                completion(.success)
            }

            return NilDisposer()
        }

        return (future, { Future() })
    }
}

extension InsuranceCertificate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String.translation(.MY_INSURANCE_CERTIFICATE_TITLE)

        let webView = UIWebView()
        bag += webView.didFinishLoadDelegate.set { _ in
            webView.scrollView.contentOffset = CGPoint(x: 0, y: -webView.layoutMargins.top)
        }

        let url = URL(string: certificateUrl)!
        webView.loadRequest(URLRequest(url: url))

        viewController.view = webView

        bag += viewController.navigationItem.addItem(
            UIBarButtonItem(system: .action),
            position: .right
        ).onValueDisposePrevious { _ -> Disposable? in
            let shareSheet = AnyPresentable<UIActivityViewController, Disposable> {
                let activitiyViewController = UIActivityViewController(
                    activityItems: [self.certificateUrl],
                    applicationActivities: nil
                )
                return (activitiyViewController, NilDisposer())
            }

            let sharePresentation = Presentation(
                shareSheet,
                style: .activityView,
                options: .defaults
            )

            return viewController.present(sharePresentation).disposable
        }

        return (viewController, bag)
    }
}
