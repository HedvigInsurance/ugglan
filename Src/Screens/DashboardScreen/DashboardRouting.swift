//
//  DashboardRouting.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-15.
//

import Foundation
import UIKit

struct DashboardRouting {
    static func openChat(viewController: UIViewController, chatActionUrl: String) {
        viewController.present(Chat())
    }
}

