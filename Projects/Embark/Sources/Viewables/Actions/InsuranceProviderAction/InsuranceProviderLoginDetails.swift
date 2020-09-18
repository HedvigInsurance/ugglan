import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation

struct InsuranceProviderLoginDetails {
    @Inject var client: ApolloClient
    let provider: GraphQL.InsuranceProviderFragment
}

extension InsuranceProviderLoginDetails: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Login to"
        viewController.preferredContentSize = CGSize(width: 300, height: 150)

        let bag = DisposeBag()

        let form = FormView()

        bag += form.addArranged(EmbarkInput(placeholder: "Personal number", masking: Masking(type: .personalNumber))).nil()

        bag += form.addArranged(Button(
            title: "Next",
            type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor))
        ))

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
