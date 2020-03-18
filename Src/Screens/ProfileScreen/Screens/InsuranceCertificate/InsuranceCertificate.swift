//
//  InsuranceCertificate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit

struct InsuranceCertificate {
    @Inject var client: ApolloClient
    let url: URL
}

extension InsuranceCertificate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .MY_INSURANCE_CERTIFICATE_TITLE)

        let pdfViewer = PDFViewer()
        bag += viewController.install(pdfViewer)

        pdfViewer.url.value = url

        let activityButton = UIBarButtonItem(system: .action)

        bag += viewController.navigationItem.addItem(
            activityButton,
            position: .right
        ).withLatestFrom(pdfViewer.data).onValueDisposePrevious { _, value -> Disposable? in
            guard let value = value else { return NilDisposer() }

            let activityView = ActivityView(
                activityItems: [value],
                applicationActivities: nil,
                sourceView: activityButton.view,
                sourceRect: activityButton.bounds
            )

            let activityViewPresentation = Presentation(
                activityView,
                style: .activityView,
                options: .defaults
            )

            return viewController.present(activityViewPresentation).disposable
        }

        return (viewController, bag)
    }
}
