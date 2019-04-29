//
//  DismissCardInteractionController.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-17.
//

import Flow
import Foundation
import UIKit

class DismissCardInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false

    override init() {
        super.init()
        print("hello")
    }
}
