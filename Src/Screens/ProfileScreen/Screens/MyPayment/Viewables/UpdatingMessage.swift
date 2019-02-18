//
//  UpdatingMessage.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-18.
//

import Flow
import Form
import Foundation
import UIKit

struct UpdatingMessage {}

extension UpdatingMessage: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()

        let label = MultilineLabel(
            styledText: StyledText(text: String(.MY_PAYMENT_UPDATING_MESSAGE), style: .centeredBodyOffBlack)
        )
        bag += row.addArangedSubview(label)

        return (row, bag)
    }
}
