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
    let certificateUrl: ReadWriteSignal<String?>
}

extension InsuranceCertificate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(.MY_INSURANCE_CERTIFICATE_TITLE)

        let pdfViewer = PDFViewer()
        bag += viewController.install(pdfViewer)

        bag += certificateUrl.atOnce().map { value -> URL? in
            guard let value = value, let url = URL(string: value) else { return nil }
            return url
        }.bindTo(pdfViewer.url)

        bag += viewController.navigationItem.addItem(
            UIBarButtonItem(system: .action),
            position: .right
        ).withLatestFrom(pdfViewer.data).onValueDisposePrevious { _, value -> Disposable? in
            guard let value = value else { return NilDisposer() }

            let activityView = ActivityView(
                activityItems: [value],
                applicationActivities: nil
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
