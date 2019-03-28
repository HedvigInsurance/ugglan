//
//  CharityInformation.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-28.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct CharityInformation {}

extension CharityInformation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        viewController.displayableTitle = "Välgörenhet"
        
        return (viewController, bag)
    }
}

