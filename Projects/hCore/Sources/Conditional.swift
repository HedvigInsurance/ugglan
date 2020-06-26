//
//  Conditional.swift
//  hCore
//
//  Created by Sam Pettersson on 2020-06-22.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Presentation
import Flow

public protocol Conditional {
    func condition() -> Bool
}

extension UIViewController {
    enum ConditionalPresentation: Error {
        case conditionNotMet
    }
    
    public func presentConditionally<T: Conditional & Presentable, Value>(
        _ presentable: T,
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> T.Result
        where T.Result == Future<Value>, T.Matter == UIViewController
    {
        if presentable.condition() {
            return present(presentable, style: style, options: options)
        }
        
        return Future<Value> { completion in
            completion(.failure(ConditionalPresentation.conditionNotMet))
            return NilDisposer()
        }
    }
}
