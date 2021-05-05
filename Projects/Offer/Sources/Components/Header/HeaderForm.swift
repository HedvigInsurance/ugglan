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
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let backgroundView = UIView()
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = .defaultCornerRadius
        backgroundView.backgroundColor = .brand(.secondaryBackground())
        
        let form = FormView()
        form.dynamicStyle = DynamicFormStyle { _ in
            .init(insets: .zero)
        }
        
        backgroundView.addSubview(form)
        
        form.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bag += form.append(DiscountTag())
        
        let section = form.appendSection()
        section.dynamicStyle = .brandGroupedNoBackground
        
        section.appendSpacing(.custom(30))
        
        bag += section.append(PriceRow())
        
        bag += form.append(StartDateSection())
        
        bag += form.append(SignSection())
        
        bag += form.append(DiscountCodeSection())
        
        return (backgroundView, bag)
    }
}
