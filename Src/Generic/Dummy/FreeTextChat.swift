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
        
        return (viewController, Future { _ in
            bag
        })
    }
}
