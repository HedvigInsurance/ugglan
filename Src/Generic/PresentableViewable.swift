//
//  PresentableViewable.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-21.
//

import Flow
import Form
import Foundation
import UIKit
import Presentation

struct PresentableViewable<View: Viewable, SignalValue>: Presentable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    let viewable: View
    let customizeViewController: () -> UIViewController
    
    func materialize() -> (UIViewController, Signal<SignalValue>) {
        let viewController = customizeViewController()
        viewController.preferredContentSize = CGSize(width: 1, height: UIScreen.main.bounds.height - 100)
        let containerView = UIView()
        viewController.view = containerView
        
        return (viewController, containerView.add(viewable) { view in
            view.snp.remakeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }
        })
    }
}

