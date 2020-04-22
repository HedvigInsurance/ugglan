//
//  DummyPagerSlide.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Foundation
import Presentation
import UIKit

struct DummyPagerScreen {}

extension DummyPagerScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        return (viewController, bag)
    }
}
