//
//  UIScrollView+RefreshControl.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-13.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    /// set's property .refreshControl if available, otherwise adds as a subview
    func addRefreshControl(_ refreshControl: UIRefreshControl) {
        if #available(iOS 10.0, *) {
            self.refreshControl = refreshControl
        } else {
            addSubview(refreshControl)
        }
    }
}
