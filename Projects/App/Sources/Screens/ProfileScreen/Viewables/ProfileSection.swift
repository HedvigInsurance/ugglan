import Flow
import Form
import Foundation
import UIKit
import hAnalytics
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

        bag += section.append(myInfoRow)

        bag += dataSignal.atOnce().compactMap { $0?.member }
            .filter { $0.firstName != nil && $0.lastName != nil }
            .map { (firstName: $0.firstName!, lastName: $0.lastName!) }.bindTo(myInfoRow.nameSignal)

        if hAnalyticsExperiment.showCharity {
            let myCharityRow = MyCharityRow(presentingViewController: presentingViewController)
            bag += section.append(myCharityRow)
        }

        if hAnalyticsExperiment.paymentScreen {
            let myPaymentRow = MyPaymentRow(presentingViewController: presentingViewController)
            bag += section.append(myPaymentRow)

            bag += dataSignal.atOnce().map { $0?.insuranceCost?.fragments.costFragment.monthlyNet.amount }
                .toInt().bindTo(myPaymentRow.monthlyCostSignal)
        }

        return (section, bag)
    }
}
