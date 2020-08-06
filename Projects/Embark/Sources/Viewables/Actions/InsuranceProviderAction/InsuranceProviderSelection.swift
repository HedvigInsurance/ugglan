//
//  InsuranceProviderSelection.swift
//  Embark
//
//  Created by sam on 5.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import Form
import hCore
import hCoreUI
import Presentation
import Apollo

struct InsuranceProviderSelection {
    @Inject var client: ApolloClient
}

extension InsuranceProviderFragment: Reusable {
    public static func makeAndConfigure() -> (make: UIView, configure: (InsuranceProviderFragment) -> Disposable) {
        let label = UILabel(value: "", style: .brand(.body(color: .primary)))
        return (label, { `self` in
            label.value = self.name
            return NilDisposer()
        })
    }
}

extension InsuranceProviderSelection: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Välj försäkringsbolag"
        viewController.preferredContentSize = CGSize(width: 300, height: 250)
        let bag = DisposeBag()
        
        let tableKit = TableKit<EmptySection, InsuranceProviderFragment>()
        
        bag += tableKit.delegate.didSelectRow.onValue { row in
            viewController.present(InsuranceProviderCollectionAgreement(provider: row))
        }
        
        bag += client.fetch(query: InsuranceProvidersQuery(locale: .svSe)).valueSignal.compactMap { $0.data?.insuranceProviders }.onValue { providers in
            tableKit.table = Table(rows: providers.map { $0.fragments.insuranceProviderFragment })
        }
        
        bag += viewController.install(tableKit)
        
        return (viewController, bag)
    }
}

