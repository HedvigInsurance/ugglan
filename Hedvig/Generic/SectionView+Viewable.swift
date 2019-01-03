//
//  SectionView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

extension SectionView {
    func append<V: Viewable>(
        _ viewable: V,
        onCreate: @escaping (_ matter: RowAndProvider<CoreSignal<Plain, ()>>) -> Void = { _ in }
    ) -> Disposable where V.Matter == RowView, V.Result == Disposable {
        let (matter, result, disposable) = materializeViewable(viewable: viewable)

        onCreate(append(matter))

        return Disposer {
            result.dispose()
            disposable.dispose()
        }
    }
}
