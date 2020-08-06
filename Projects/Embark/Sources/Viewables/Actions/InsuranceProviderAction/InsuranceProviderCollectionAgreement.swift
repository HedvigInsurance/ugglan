//
//  InsuranceProviderCollectionAgreement.swift
//  Embark
//
//  Created by Sam Pettersson on 2020-08-06.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import Form
import hCore
import hCoreUI
import Presentation
import Apollo

struct InsuranceProviderCollectionAgreement {
    let provider: InsuranceProviderFragment
}

extension InsuranceProviderCollectionAgreement: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = ""
        viewController.preferredContentSize = CGSize(width: 300, height: 150)

        let bag = DisposeBag()
        
        let form = FormView()
        
        bag += form.addArranged(MultilineLabel(value: "Vill du hämta information om din nuvarande hemförsäkring hos \(provider.name)?", style: .brand(.title2(color: .primary))))
        
        bag += form.addArranged(MultilineLabel(value: "Så kan du jämföra pris och skydd med Hedvig", style: .brand(.body(color: .primary))))
        
        let continueButton = Button(
            title: "Ja tack!",
            type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor)
        ))
        
        bag += continueButton.onTapSignal.onValue({ _ in
            viewController.present(InsuranceProviderLoginDetails(provider: self.provider))
        })
        
        bag += form.addArranged(continueButton)
        
        bag += form.addArranged(Button(
            title: "Skippa det",
            type: .standardSmall(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor)
        )))
        
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
