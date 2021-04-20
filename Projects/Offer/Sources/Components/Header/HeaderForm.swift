//
//  HeaderCard.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct HeaderForm {}

extension HeaderForm: Presentable {
    func materialize() -> (FormView, Disposable) {
        let bag = DisposeBag()
        
        let form = FormView()
        form.layer.cornerRadius = .defaultCornerRadius
        form.backgroundColor = .brand(.secondaryBackground())
        
        let section = form.appendSection()
        section.dynamicStyle = .brandGroupedNoBackground
        
        section.appendSpacing(.custom(30))
        
        bag += section.append(PriceRow())
        
        bag += form.append(StartDateSection())
        
        bag += form.append(SignSection())
        
        bag += form.append(DiscountCodeSection())
        
        return (form, bag)
    }
}
