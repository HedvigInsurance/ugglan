//
//  FormTableView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow

final class FormTableView: UITableView, GradientScroller {
    let bag = DisposeBag()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        addGradient(into: bag)
        
        // fix large titles being collapsed on load
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.navigationBar.sizeToFit()
        }
    }
}
