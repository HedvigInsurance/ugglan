//
//  UIViewController+PresentOptionalMatter.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-16.
//

import Foundation
import Presentation
import UIKit

extension UIViewController {
    func present<P: Presentable>(_ presentable: P) -> P.Result where P.Matter == UIViewController? {
        let (matter, result) = presentable.materialize()
        
        if let matter = matter {
            present(matter)
        }
        
        return result
    }
}
