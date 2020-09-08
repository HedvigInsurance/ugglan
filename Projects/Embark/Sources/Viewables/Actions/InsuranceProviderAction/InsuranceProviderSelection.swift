//
//  InsuranceProviderSelection.swift
//  Embark
//
//  Created by sam on 5.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation

struct InsuranceProviderSelection {
    @Inject var client: ApolloClient
}

extension GraphQL.InsuranceProviderFragment: Reusable {
    public static func makeAndConfigure() -> (make: UIStackView, configure: (GraphQL.InsuranceProviderFragment) -> Disposable) {
        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.distribution = .fillProportionally

        return (containerView, { `self` in
            let bag = DisposeBag()

            let remoteVectorIcon = RemoteVectorIcon(
                self.logo.fragments.iconFragment,
                threaded: true
            )
            bag += containerView.addArranged(remoteVectorIcon) { view in
                view.snp.makeConstraints { make in
                    make.width.equalTo(35)
                }
            }

            let label = UILabel(value: "", style: .brand(.body(color: .primary)))
            containerView.addArrangedSubview(label)

            bag += {
                label.removeFromSuperview()
            }

            label.value = self.name
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

        bag += viewController.install(tableKit)

        return (viewController, Future { completion in
            bag += tableKit.delegate.didSelectRow.onValue { row in
                guard row.hasExternalCapabilities else {
                    completion(.success(row))
                    return
                }

                viewController.present(
                    InsuranceProviderCollectionAgreement(provider: row),
                    style: .modally()
                )
            }

            return bag
        })
    }
}
