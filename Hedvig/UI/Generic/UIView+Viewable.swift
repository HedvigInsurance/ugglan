//
//  UIView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

private let defaultOnCreateClosure: (_ view: UIView) -> Void = { _ in }

extension UIView {
    func add(_ viewable: Viewable, onCreate: (_ view: UIView) -> Void = defaultOnCreateClosure) -> Disposable {
        let wasAddedSignal = Signal<Void>()
        let (view, disposable) = viewable.materialize()
        addSubview(view)
        view.snp.makeConstraints { make in
            viewable.makeConstraints(make: make)
        }
        viewable.animateIn(view: view)
        onCreate(view)
        return disposable
    }
}
