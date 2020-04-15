//
//  ViewPointer.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-10.
//

import Foundation
import UIKit

class ViewPointer {
    var current: UIView?
    var handler: (_ view: UIView) -> Void

    init() {
        handler = { _ in }
        handler = { [weak self] view in
            self?.current = view
        }
    }
}
