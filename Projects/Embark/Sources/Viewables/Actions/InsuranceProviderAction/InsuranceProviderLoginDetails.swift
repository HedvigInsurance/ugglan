import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct InsuranceProviderLoginDetails {
    @Inject var client: ApolloClient
    let provider: GraphQL.InsuranceProviderFragment
}

extension InsuranceProviderLoginDetails: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = ""
        viewController.view.backgroundColor = .brand(.secondaryBackground())

        let containerView = UIStackView()

        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 16, verticalInset: 20)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 16

        viewController.view.addSubview(containerView)

        containerView.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(viewController.view.safeAreaInsets.bottom)
        }

        let bag = DisposeBag()

        let titleLabel = MultilineLabel(
            value: L10n.Embark.ExternalInsuranceAction.Login.title(provider.name),
            style: TextStyle.brand(.title3(color: .primary)).leftAligned
        )

        bag += containerView.addArranged(titleLabel)

        containerView.appendSpacing(.custom(8))

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .equalSpacing

        let inputTitle = UILabel(
            value: L10n.Embark.ExternalInsuranceAction.Login.personalNumberPlaceholder,
            style: .brand(.body(color: .primary))
        )

        let masking = Masking(type: .personalNumber)
        let inputField = EmbarkInput(
            placeholder: "YYYYMMDD-XXXX",
            autocapitalisationType: masking.autocapitalizationType,
            masking: masking,
            fieldStyle: .embarkInputSmall
        )

        horizontalStack.addArrangedSubview(inputTitle)
        bag += horizontalStack.addArranged(inputField)

        containerView.addArrangedSubview(horizontalStack)

        bag += containerView.addArranged(Divider(backgroundColor: .brand(.primaryBorderColor)))

        let continueButton = Button(
            title: L10n.Embark.ExternalInsuranceAction.Login.continueButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        bag += containerView.addArranged(continueButton)

        bag += containerView.didLayoutSignal.onValue { _ in
            viewController.preferredContentSize = containerView.systemLayoutSizeFitting(.zero)
        }

        return (viewController, bag)
    }
}
