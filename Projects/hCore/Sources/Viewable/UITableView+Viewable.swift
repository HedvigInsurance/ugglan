//
//  UITableView+Viewable.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit
import SnapKit

extension UIView {
    var anyDescendantDidLayoutSignal: Signal<Void> {
        if subviews.isEmpty {
            return didLayoutSignal
        }

        let callbacker = Callbacker<Void>()
        let bag = DisposeBag()

        bag += subviews.map { subview in
            subview.anyDescendantDidLayoutSignal.onValue { _ in
                callbacker.callAll()
            }
        }

        bag += didLayoutSignal.onValue { _ in
            callbacker.callAll()
        }

        return callbacker.providedSignal.hold(bag)
    }
}

extension UITableView {
    public func addTableHeaderView<V: Viewable, VMatter: UIView>(
        _ viewable: V
    ) -> Disposable where
        V.Events == ViewableEvents,
        V.Matter == VMatter,
        V.Result == Disposable {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        tableHeaderView = matter

        matter.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        let bag = DisposeBag()

        bag += matter.anyDescendantDidLayoutSignal.animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
            self.tableHeaderView = matter
            matter.layoutIfNeeded()
            self.layoutIfNeeded()
        })

        return Disposer {
            bag.dispose()
            result.dispose()
            disposable.dispose()
        }
    }

    public func addTableFooterView<V: Viewable, VMatter: UIView>(
        _ viewable: V
    ) -> Disposable where
        V.Events == ViewableEvents,
        V.Matter == VMatter,
        V.Result == Disposable {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        tableFooterView = matter

        matter.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        let bag = DisposeBag()

        bag += contentSizeSignal.onValue { size in
            matter.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(size.height - matter.frame.height)
            }
        }

        bag += matter.anyDescendantDidLayoutSignal.animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
            self.tableFooterView = matter
            matter.layoutIfNeeded()
            self.layoutIfNeeded()
           })

        return Disposer {
            bag.dispose()
            result.dispose()
            disposable.dispose()
        }
    }
}

