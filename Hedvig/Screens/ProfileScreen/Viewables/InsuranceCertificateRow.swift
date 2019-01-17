//
//  InsuranceCertificateRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct InsuranceCertificateRow {
    let certificateUrl: ReadWriteSignal<String?>
    let presentingViewController: UIViewController

    init(
        certificateUrl: String?,
        presentingViewController: UIViewController
    ) {
        self.certificateUrl = ReadWriteSignal(certificateUrl)
        self.presentingViewController = presentingViewController
    }
}

extension InsuranceCertificateRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String.translation(.PROFILE_MY_INSURANCE_CERTIFICATE_ROW_TITLE),
            subtitle: "",
            iconAsset: Asset.insuranceCertificate,
            options: []
        )

        bag += certificateUrl.atOnce().filter(predicate: { $0 == nil }).map({ _ -> [IconRow.Options] in
            [.disabled]
        }).bindTo(row.options)

        bag += certificateUrl.atOnce().map({ value -> String in
            value != nil ?
                String.translation(.PROFILE_MY_INSURANCE_CERTIFICATE_ROW_SUBTITLE) :
                String.translation(.PROFILE_MY_INSURANCE_CERTIFICATE_ROW_DISABLED_SUBTITLE)
        }).bindTo(row.subtitle)

        bag += certificateUrl.atOnce().filter(predicate: { $0 != nil }).map({ _ -> [IconRow.Options] in
            [.withArrow]
        }).bindTo(row.options)

        bag += certificateUrl.atOnce().filter(predicate: { $0 != nil }).onValueDisposePrevious { value in
            let innerBag = bag.innerBag()

            innerBag += events.onSelect.onValue { _ in
                self.presentingViewController.present(
                    InsuranceCertificate(certificateUrl: value!),
                    options: [.largeTitleDisplayMode(.never)]
                )
            }

            return innerBag
        }

        return (row, bag)
    }
}
