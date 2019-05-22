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
        
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 100)
        
        let view = UIView()
        view.backgroundColor = .purple
        
        viewController.view = view
        
        return (viewController, Future { _ in
            bag
        })
    }
}
