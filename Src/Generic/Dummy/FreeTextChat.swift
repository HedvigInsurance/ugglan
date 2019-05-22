//
//  FreeTextChat.swift
//  project
//
//  Created by Gustaf Gunér on 2019-05-22.
//

import Flow
import Form
import Presentation
import UIKit

struct FreeTextChat {}

extension FreeTextChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 100)
        
        let view = UIView()
        view.backgroundColor = .purple
        
        viewController.view = view
        
        return (viewController, Future { _ in
            bag
        })
    }
}
