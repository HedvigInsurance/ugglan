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
import Common
import Space
import ComponentKit

struct InsuranceCertificate {
    @Inject var client: ApolloClient
    let type: CertificateType

    enum CertificateType {
        case current, renewal
    }

    init(type: CertificateType) {
        self.type = type
    }
}

extension InsuranceCertificate: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(key: .MY_INSURANCE_CERTIFICATE_TITLE)

        let pdfViewer = PDFViewer()
        bag += viewController.install(pdfViewer)

        bag += client.fetch(
            query: InsuranceCertificateQuery(),
            cachePolicy: .fetchIgnoringCacheData
        ).valueSignal.compactMap { result -> String? in
            switch self.type {
            case .current:
                return result.data?.insurance.certificateUrl
            case .renewal:
                return result.data?.insurance.renewal?.certificateUrl
            }
        }.map { certificateUrl -> URL? in
            guard let url = URL(string: certificateUrl) else { return nil }
            return url
        }.bindTo(pdfViewer.url)

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
