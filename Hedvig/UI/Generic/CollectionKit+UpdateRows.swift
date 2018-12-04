//
//  CollectionKit+UpdateAt.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-04.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation

extension CollectionKit {
    private func getItemForIndex(index: Int) -> Row? {
        return table.enumerated().first(where: { (offset, _) -> Bool in
            offset == index
        })?.element
    }

    private func updateRowAtIndex(index: Int) {
        let row = getItemForIndex(index: index)

        if let row = row {
            let changeStep = ChangeStep<Row, TableIndex>.update(
                item: row,
                at: TableIndex(section: 0, row: index)
            )
            let tableChange = TableChange<Section, Row>.row(changeStep)
            apply(changes: [tableChange], animation: .none)
        }
    }

    func hasPreviousRow() -> Bool {
        return currentIndex() != 0
    }

    func hasNextRow() -> Bool {
        return currentIndex() + 1 < table.count
    }

    func updateCurrentRow() {
        updateRowAtIndex(index: currentIndex())
    }

    func updateRowBeforeCurrent() {
        let index = currentIndex() - 1
        updateRowAtIndex(index: index)
    }

    func updateRowAfterCurrent() {
        let index = currentIndex() + 1
        updateRowAtIndex(index: index)
    }
}
