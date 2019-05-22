//
//  OnboardingChat.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Flow
import Form
import Presentation
import UIKit

struct OnboardingChat {
    enum Intent: String {
        case onboard, login
    }

    let intent: Intent

    init(intent: Intent) {
        self.intent = intent
    }
}

extension OnboardingChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        return (viewController, Future { _ in
            bag
        })
    }
}
