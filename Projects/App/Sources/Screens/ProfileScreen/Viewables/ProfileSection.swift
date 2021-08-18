import Flow
import Form
import Foundation
import UIKit
import hCore
import hGraphQL

struct ProfileSection {
    let dataSignal: ReadWriteSignal<GraphQL.ProfileQuery.Data?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
}

extension ProfileSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(header: nil, footer: nil)
        section.dynamicStyle = .brandGrouped(separatorType: .largeIcons)
        section.isHidden = true

        bag += dataSignal.map { $0 == nil }.bindTo(section, \.isHidden)

        let myInfoRow = MyInfoRow(presentingViewController: presentingViewController)

        bag += section.append(myInfoRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: myInfoRow
            )
        }

        bag += dataSignal.atOnce().compactMap { $0?.member }
            .filter { $0.firstName != nil && $0.lastName != nil }
            .map { (firstName: $0.firstName!, lastName: $0.lastName!) }.bindTo(myInfoRow.nameSignal)

        let myCharityRow = MyCharityRow(presentingViewController: presentingViewController)
        bag += section.append(myCharityRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: myCharityRow
            )
        }

        bag += dataSignal.atOnce().map { $0?.cashback?.name }.bindTo(myCharityRow.charityNameSignal)

        let myPaymentRow = MyPaymentRow(presentingViewController: presentingViewController)
        bag += section.append(myPaymentRow)

        bag += dataSignal.atOnce().map { $0?.insuranceCost?.fragments.costFragment.monthlyNet.amount }
            .toInt().bindTo(myPaymentRow.monthlyCostSignal)

        return (section, bag)
    }
}
