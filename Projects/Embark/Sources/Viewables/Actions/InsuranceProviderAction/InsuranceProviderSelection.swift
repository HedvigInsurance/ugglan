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

extension InsuranceProviderSelection: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Välj försäkringsbolag"
        viewController.preferredContentSize = CGSize(width: 300, height: 250)
        let bag = DisposeBag()
        
        let form = FormView()
        
        let section = form.appendSection()
        bag += section.appendRow(title: "Bolag").onValue { _ in
            viewController.present(InsuranceProviderLoginDetails())
        }
        
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
