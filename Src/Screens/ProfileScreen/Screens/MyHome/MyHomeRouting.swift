//
//  MyHomeRouting.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-18.
//

import Foundation
import UIKit

struct MyHomeRouting {
    static func openChat(viewController: UIViewController) {
        let overlay = DraggableOverlay(presentable: Chat())
        viewController.present(overlay)
    }
}
