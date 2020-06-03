//
//  UIViewController+Viewable.swift
//  hCore
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow

extension UIViewController {
    public func install<View: Viewable, Matter: UIView, SignalKind, SignalValue>(
        _ viewable: View,
        onCreate: (_ view: View.Matter) -> Void = defaultOnCreateClosure
    ) -> CoreSignal<SignalKind, SignalValue> where
        View.Matter == Matter,
        View.Result == CoreSignal<SignalKind, SignalValue>,
        View.Events == ViewableEvents {
            let wasAddedCallbacker = Callbacker<Void>()
            
            let (matter, result) = viewable.materialize(events: ViewableEvents(wasAddedCallbacker: wasAddedCallbacker))
                        
            view = matter
            
            onCreate(matter)
            
            wasAddedCallbacker.callAll()
            
            return result
    }
}
