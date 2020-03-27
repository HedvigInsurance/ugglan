//
//  UITableView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-24.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UITableView {
    func addTableHeaderView<V: Viewable, VMatter: UIView>(
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
            
        bag += matter.allDescendantsSignal.animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
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
}
