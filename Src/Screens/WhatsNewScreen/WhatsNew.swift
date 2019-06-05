//
//  WhatsNew.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

struct WhatsNew {}

extension WhatsNew: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        
        if let navigationBar = viewController.navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.layoutIfNeeded()
            navigationBar.setValue(true, forKey: "hidesShadow")
        }
        
        
        
        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .overFullScreen,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )
        
        let dismissButton = DismissButton()
        
        let item = UIBarButtonItem(viewable: dismissButton)
        viewController.navigationItem.rightBarButtonItem = item
        
        viewController.displayableTitle = "Vad är nytt?"
        viewController.view.backgroundColor = .offWhite
        
        return (viewController, Future { completion in
            bag += dismissButton.onTapSignal.onValue { _ in
                completion(.success)
            }
            
            return bag
        })
    }
}
