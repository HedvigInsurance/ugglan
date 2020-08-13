//
//  FormScrollView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow

public final class FormScrollView: UIScrollView, GradientScroller {
    let bag = DisposeBag()
    public var appliesGradient: Bool = true
    
    public override func didMoveToWindow() {
        if appliesGradient {
            addGradient(into: bag)
        }
    }
}
