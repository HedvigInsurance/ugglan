import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct InsuranceProviderSelection {
    @Inject var client: ApolloClient
    let data: InsuranceWrapper
}

extension GraphQL.InsuranceProviderFragment: Reusable {
    public static func makeAndConfigure() -> (make: UIStackView, configure: (GraphQL.InsuranceProviderFragment) -> Disposable) {
        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.distribution = .fillProportionally

        return (containerView, { `self` in
            let bag = DisposeBag()

            let label = UILabel(value: "", style: .brand(.body(color: .primary)))
            containerView.addArrangedSubview(label)

            label.value = self.name

            let chevronImageView = UIImageView()
            chevronImageView.image = hCoreUIAssets.chevronRight.image
            chevronImageView.contentMode = .scaleAspectFit

            containerView.addArrangedSubview(chevronImageView)

            chevronImageView.snp.makeConstraints { make in
                make.width.equalTo(12)
            }

            bag += {
                label.removeFromSuperview()
                chevronImageView.removeFromSuperview()
            }

            return bag
        })
    }
}

extension InsuranceProviderSelection: Presentable {
    func materialize() -> (UIViewController, Future<GraphQL.InsuranceProviderFragment>) {
        let viewController = UIViewController()
        viewController.title = L10n.Embark.ExternalInsuranceAction.listTitle
        viewController.preferredContentSize = CGSize(width: 300, height: 250)
        let bag = DisposeBag()

        let tableKit = TableKit<EmptySection, GraphQL.InsuranceProviderFragment>()

        bag += client.fetch(query: GraphQL.InsuranceProvidersQuery(locale: .svSe)).valueSignal.compactMap { $0.insuranceProviders }.onValue { providers in
            tableKit.table = Table(rows: providers.map { $0.fragments.insuranceProviderFragment })
        }

        bag += viewController.install(tableKit, options: [])

        return (viewController, Future { completion in
            bag += tableKit.delegate.didSelectRow.onValue { row in
                guard row.hasExternalCapabilities, self.data.isExternal else {
                    completion(.success(row))
                    return
                }

                let collectionAgreement = InsuranceProviderCollectionAgreement(provider: row)

                viewController.present(
                    collectionAgreement.withCloseButton,
                    style: .detented(.preferredContentSize),
                    options: .defaults
                )
            }

            return bag
        })
    }
}
