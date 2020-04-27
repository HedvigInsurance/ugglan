//
//  UIApplication+AppDelegate.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-11.
//

import Foundation
import UIKit

extension UIApplication {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
