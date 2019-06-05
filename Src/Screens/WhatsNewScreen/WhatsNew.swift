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

struct WhatsNew {
    let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )
}

extension WhatsNew: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()

        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .overFullScreen,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )
        
        let dismissButton = DismissButton()
        
        let item = UIBarButtonItem(viewable: dismissButton)
        viewController.navigationItem.rightBarButtonItem = item
        
        viewController.displayableTitle = "Vad är nytt?"
        
        let view = UIView()
        view.backgroundColor = .offWhite
    
        let pager = Pager(superviewSize: viewController.view.bounds.size)
        
        bag += view.add(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(800)
            }
        }
        
        viewController.view = view
        
        return (viewController, Future { completion in
            bag += dismissButton.onTapSignal.onValue { _ in
                completion(.success)
            }
            
            return bag
        })
    }
}
