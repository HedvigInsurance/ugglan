//
//  ProfileRows.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct ProfileSection {
    let dataSignal: ReadWriteSignal<ProfileQuery.Data?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
}

extension ProfileSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(header: nil, footer: nil, style: .sectionPlainLargeIcons)
        section.isHidden = true

        bag += dataSignal.map { $0 == nil }.bindTo(section, \.isHidden)

        let myInfoRow = MyInfoRow(
            presentingViewController: presentingViewController
        )

        bag += section.append(myInfoRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: myInfoRow
            )
        }

        bag += dataSignal.atOnce()
            .compactMap { $0?.member }
            .filter { $0.firstName != nil && $0.lastName != nil }
            .map { (firstName: $0.firstName!, lastName: $0.lastName!) }
            .bindTo(myInfoRow.nameSignal)

        let homeRow = HomeRow(
            presentingViewController: presentingViewController
        )
        bag += section.append(homeRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: homeRow
            )
        }

        bag += dataSignal.atOnce()
            .compactMap { $0?.insurance.address }
            .bindTo(homeRow.address)

        let myCharityRow = MyCharityRow(
            presentingViewController: presentingViewController
        )
        bag += section.append(myCharityRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: myCharityRow
            )
        }

        bag += dataSignal
            .atOnce()
            .map { $0?.cashback?.name }
            .bindTo(myCharityRow.charityNameSignal)

        let insuranceCertificateRow = InsuranceCertificateRow(
            presentingViewController: presentingViewController
        )

        bag += section.append(insuranceCertificateRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: insuranceCertificateRow
            )
        }

        bag += dataSignal
            .atOnce()
            .map { $0?.insurance.certificateUrl }
            .bindTo(insuranceCertificateRow.certificateUrlSignal)

        let myPaymentRow = MyPaymentRow(
            presentingViewController: presentingViewController
        )
        bag += section.append(myPaymentRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: myPaymentRow
            )
        }

        bag += dataSignal
            .atOnce()
            .map { $0?.paymentWithDiscount?.netPremium.amount }
            .debug()
            .toInt()
            .bindTo(myPaymentRow.monthlyCostSignal)

        let myCoinsuredRow = MyCoinsuredRow(
            presentingViewController: presentingViewController
        )
        bag += section.append(myCoinsuredRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: myCoinsuredRow
            )
        }

        bag += dataSignal
            .atOnce()
            .map { $0?.insurance.personsInHousehold }
            .bindTo(myCoinsuredRow.amountOfCoinsuredSignal)

        return (section, bag)
    }
}
