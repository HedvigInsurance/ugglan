//
//  KeyGearPresenablePlaceholder.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-06.
//

import Foundation
import Form
import Flow
import Presentation
import UIKit

struct KeyGearPresenablePlaceholder {}


extension KeyGearPresenablePlaceholder: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.view.backgroundColor = .primaryBackground

        let keyView = KeyGearCategoryChooser()
        bag += viewController.view.add(keyView) { view in
            view.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.right.left.equalToSuperview()
            }
        }
        

        return (viewController, bag)
    }
}
