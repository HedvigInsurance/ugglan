//
//  UIBarButtonItem+Viewable.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Flow
import Foundation
import UIKit
import hCore

extension UIBarButtonItem {
    convenience init<V: Viewable, View: UIView>(viewable: V, onCreate: @escaping (_ view: View) -> Void = { _ in }) where
        V.Matter == View,
        V.Events == ViewableEvents,
        V.Result == Disposable {
        let wasAddedCallbacker = Callbacker<Void>()
        let events = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)

        let bag = DisposeBag()

        let (matter, result) = viewable.materialize(events: events)

        onCreate(matter)

        bag += result

        self.init(customView: matter)

        bag += deallocSignal.onValue {
            bag.dispose()
        }
    }
}
