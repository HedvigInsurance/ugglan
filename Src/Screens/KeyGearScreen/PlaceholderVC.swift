//
//  PlaceholderVC.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-18.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

struct PlaceholderVC {
    
}

extension PlaceholderVC: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        let form = FormView()
        bag += viewController.install(form)
        let section = form.appendSection(header: "", footer: "", style: .sectionPlain)
        bag += section.append(KeyGearAddReceiptRow()).onValue({ _ in
            
        })
        
        return (viewController, bag)
        
    }
}
