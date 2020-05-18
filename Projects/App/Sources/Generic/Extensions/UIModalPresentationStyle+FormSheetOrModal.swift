//
//  UIModalPresentationStyle+FormSheetOrModal.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-25.
//

import Foundation
import Presentation
import UIKit

extension UIModalPresentationStyle {
    static var formSheetOrOverFullscreen: UIModalPresentationStyle {
        return UIDevice.current.userInterfaceIdiom == .pad ? UIModalPresentationStyle.formSheet : UIModalPresentationStyle.overFullScreen
    }
}
