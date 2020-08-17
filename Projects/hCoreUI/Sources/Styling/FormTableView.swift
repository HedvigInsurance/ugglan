//
//  FormTableView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

final class FormTableView: UITableView, GradientScroller {
    let bag = DisposeBag()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        addGradient(into: bag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        // fix large titles being collapsed on load
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.navigationBar.sizeToFit()
        }
    }
}
