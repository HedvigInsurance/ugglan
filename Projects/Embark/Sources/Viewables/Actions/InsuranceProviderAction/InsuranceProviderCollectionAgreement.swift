import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct InsuranceProviderCollectionAgreement {
    let provider: GraphQL.InsuranceProviderFragment
}

extension InsuranceProviderCollectionAgreement: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = ""

        let bag = DisposeBag()

        let form = FormView()

        let titleLabel = MultilineLabel(
            value: L10n.Embark.ExternalInsuranceAction.Agreement.title(provider.name),
            style: TextStyle.brand(.title2(color: .primary)).centerAligned
        )
        bag += form.addArranged(titleLabel)

        form.appendSpacing(.inbetween)

        let bodyLabel = MultilineLabel(
            value: L10n.Embark.ExternalInsuranceAction.Agreement.body,
            style: TextStyle.brand(.body(color: .primary)).centerAligned
        )
        bag += form.addArranged(bodyLabel)

        form.appendSpacing(.inbetween)

        let continueButton = Button(
            title: L10n.Embark.ExternalInsuranceAction.Agreement.agreeButton,
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )

        bag += continueButton.onTapSignal.onValue { _ in
            viewController.present(InsuranceProviderLoginDetails(provider: self.provider))
        }

        bag += form.addArranged(continueButton)

        form.appendSpacing(.inbetween)

        let skipButton = Button(
            title: L10n.Embark.ExternalInsuranceAction.Agreement.skipButton,
            type: .standardSmall(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )

        bag += form.addArranged(skipButton)

        form.appendSpacing(.inbetween)

        let footnoteLabel = MarkdownText(
            value: L10n.Embark.ExternalInsuranceAction.Agreement.footnote(provider.name),
            style: TextStyle.brand(.footnote(color: .tertiary)).centerAligned
        )
        bag += form.addArranged(footnoteLabel)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
