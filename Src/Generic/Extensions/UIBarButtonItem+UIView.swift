//
//  UIBarButtonItem+UIView.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-13.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    var bounds: CGRect? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view.bounds
    }

    var view: UIView? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view
    }
}
