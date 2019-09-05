//
//  Presentable+WithCloseButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-05.
//

import Foundation
import Presentation
import Flow
import UIKit

extension Presentable where Matter: UIViewController, Result == Disposable {
    var withCloseButton: AnyPresentable<Self.Matter, Future<Void>> {
        AnyPresentable { () -> (Self.Matter, Future<Void>) in
            let (viewController, disposable) = self.materialize()
            
            return (viewController, Future { completion in
                let bag = DisposeBag()
                
                let closeButtonItem = UIBarButtonItem(title: "Stäng", style: .navigationBarButton)
                viewController.navigationItem.leftBarButtonItem = closeButtonItem
                
                bag += closeButtonItem.onValue { _ in
                    completion(.success)
                }
                
                bag += disposable
                
                return DelayedDisposer(bag, delay: 2)
            })
        }
    }
}
