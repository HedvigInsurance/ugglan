//
//  KeyValueRow.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-12.
//

import Flow
import Form
import Foundation

struct KeyValueRow {
    let keySignal = ReadWriteSignal<String>("")
    let valueSignal = ReadWriteSignal<String>("")
}

extension KeyValueRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView(title: "", style: .rowTitle)

        bag += keySignal.atOnce().onValue { value in
            row.title = value
        }

        let valueLabel = UILabel()
        row.append(valueLabel)

        bag += valueSignal.atOnce().bindTo(valueLabel, \.text)

        return (row, bag)
    }
}
