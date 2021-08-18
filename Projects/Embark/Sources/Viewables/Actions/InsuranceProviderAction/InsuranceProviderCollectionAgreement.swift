import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct InsuranceProviderCollectionAgreement { let provider: GraphQL.InsuranceProviderFragment }

extension InsuranceProviderCollectionAgreement: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .brand(.secondaryBackground())
        viewController.title = ""

        let bag = DisposeBag()

        let containerView = UIStackView()

        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 16, verticalInset: 20)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 16

        viewController.view.addSubview(containerView)

        containerView.snp.makeConstraints { make in make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(viewController.view.safeAreaInsets.bottom)
        }

        let titleLabel = MultilineLabel(
            value: L10n.Embark.ExternalInsuranceAction.Agreement.title(provider.name),
            style: TextStyle.brand(.title3(color: .primary)).leftAligned
        )
        bag += containerView.addArranged(titleLabel)

        let bodyLabel = MultilineLabel(
            value: L10n.Embark.ExternalInsuranceAction.Agreement.body,
            style: TextStyle.brand(.body(color: .secondary)).leftAligned
        )
        bag += containerView.addArranged(bodyLabel)

        containerView.appendSpacing(.custom(8))

        let continueButton = Button(
            title: L10n.Embark.ExternalInsuranceAction.Agreement.agreeButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        bag += continueButton.onTapSignal.onValue { _ in
            viewController.present(InsuranceProviderLoginDetails(provider: self.provider))
        }

        bag += containerView.addArranged(continueButton)

        let skipButton = Button(
            title: L10n.Embark.ExternalInsuranceAction.Agreement.skipButton,
            type: .standardOutline(
                borderColor: .brand(.primaryBorderColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )

        bag += containerView.addArranged(skipButton)

        let footnoteLabel = MarkdownText(
            value: L10n.Embark.ExternalInsuranceAction.Agreement.footnote(provider.name),
            style: TextStyle.brand(.footnote(color: .tertiary)).centerAligned
        )
        bag += containerView.addArranged(footnoteLabel)

        bag += containerView.didLayoutSignal.onValue { _ in
            viewController.preferredContentSize = containerView.systemLayoutSizeFitting(.zero)
        }

        return (viewController, bag)
    }
}
