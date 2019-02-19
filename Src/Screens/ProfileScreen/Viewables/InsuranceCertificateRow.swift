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
    let certificateUrlSignal = ReadWriteSignal<String?>(nil)
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
    }
}

extension InsuranceCertificateRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: String(.PROFILE_MY_INSURANCE_CERTIFICATE_ROW_TITLE),
            subtitle: "",
            iconAsset: Asset.insuranceCertificate,
            options: []
        )

        bag += certificateUrlSignal.atOnce().map({ value -> String in
            value != nil ?
                String(.PROFILE_MY_INSURANCE_CERTIFICATE_ROW_SUBTITLE) :
                String(.PROFILE_MY_INSURANCE_CERTIFICATE_ROW_DISABLED_SUBTITLE)
        }).bindTo(row.subtitle)

        bag += certificateUrlSignal.atOnce().filter(predicate: { $0 == nil }).map({ _ -> [IconRow.Options] in
            [.disabled]
        }).bindTo(row.options)

        bag += certificateUrlSignal.atOnce().filter(predicate: { $0 != nil }).map({ _ -> [IconRow.Options] in
            [.withArrow]
        }).bindTo(row.options)

        bag += certificateUrlSignal.atOnce().filter(predicate: { $0 != nil }).onValueDisposePrevious { _ in
            let innerBag = bag.innerBag()

            innerBag += events.onSelect.onValue { _ in
                self.presentingViewController.present(
                    InsuranceCertificate(),
                    options: [.largeTitleDisplayMode(.never)]
                )
            }

            return innerBag
        }

        return (row, bag)
    }
}

extension InsuranceCertificateRow: Previewable {
    func preview() -> (InsuranceCertificate, PresentationOptions) {
        return (InsuranceCertificate(), [.largeTitleDisplayMode(.never)])
    }
}
