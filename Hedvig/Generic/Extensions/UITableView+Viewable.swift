//
//  UITableView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-24.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

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
        }

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }
}
