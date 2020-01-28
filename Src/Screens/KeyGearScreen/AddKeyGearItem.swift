//
//  AddKeyGearItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import UIKit
import Apollo
import Presentation
import Form

struct AddKeyGearItem {}

extension AddKeyGearItem: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        viewController.title = "Lägg till pryl"
        
        let form = FormView()
        bag += viewController.install(form)
        
        return (viewController, Future { completion in
            
            let button = Button(title: "Lägg till", type: .standard(backgroundColor: .primaryTintColor, textColor: .primaryText))
            
            bag += button.onTapSignal.onValue({ _ in
                completion(.success)
            })
            
            bag += form.prepend(button)
            
            return DelayedDisposer(bag, delay: 2)
        })
    }
}
