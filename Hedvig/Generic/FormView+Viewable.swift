//
//  FormView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

extension FormView {
    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter, _ containerView: UIView) -> Void = { _, _ in }
    ) -> Disposable where
        V.Matter == UIView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let containerView = UIView()
        append(containerView)

        let disposable = containerView.add(viewable) { view in
            onCreate(view, containerView)
        }

        return disposable
    }

    func prepend<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ view: V.Matter, _ containerView: UIView) -> Void = { _, _ in }
    ) -> Disposable where
        V.Matter == UIView,
        V.Result == Disposable,
        V.Events == ViewableEvents {
        let containerView = UIView()
        prepend(containerView)

        let disposable = containerView.add(viewable) { view in
            onCreate(view, containerView)
        }

        return disposable
    }
}
