//
//  KeyGearItem.swift
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

struct KeyGearItem {
    let name: String
    
    class KeyGearItemViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
               self.navigationController!.navigationBar.setBackgroundImage(nil, for: .compact)
               self.navigationController!.navigationBar.barTintColor = nil
               self.navigationController!.toolbar.barTintColor = nil
               self.navigationController!.toolbar.isTranslucent = true
        }
    }
}

extension KeyGearItem: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = KeyGearItemViewController()
        let bag = DisposeBag()
        
        viewController.title = name
        
        let form = FormView()
        bag += viewController.install(form)
        
        bag += form.prepend(KeyGearImageCarousel())
        
        return (viewController, bag)
    }
}
