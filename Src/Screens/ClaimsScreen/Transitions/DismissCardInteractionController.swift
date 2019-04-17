//
//  DismissCardInteractionController.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-17.
//

import Foundation
import UIKit
import Flow

class DismissCardInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    
    override init() {
        super.init()
        print("hello")
    }
}
