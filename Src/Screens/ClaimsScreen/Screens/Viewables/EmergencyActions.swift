//
//  EmergencyActions.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Foundation
import Flow
import UIKit

struct EmergencyActions {}

extension EmergencyActions: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        return (view, NilDisposer())
    }
}
