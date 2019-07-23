//
//  UIViewController+PresentOptionalMatter.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-16.
//

import Foundation
import Presentation
import Flow
import UIKit

extension UIViewController {
    func present<P: Presentable>(_ presentable: P) -> Future<Void> where P.Matter == UIViewController?, P.Result == Future<Void> {
        let (matter, result) = presentable.materialize()
        
        if let matter = matter {
            let anyPresentable = AnyPresentable(materialize: { () -> (UIViewController, Future<Void>) in
                return (matter, result)
            })
            return present(anyPresentable)
        }
        
        return result
    }
}
