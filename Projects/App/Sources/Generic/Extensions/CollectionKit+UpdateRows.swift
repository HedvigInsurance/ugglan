import Form
import Foundation

extension CollectionKit {
    private func getItemForIndex(index: Int) -> Row? {
        table.enumerated().first(where: { (offset, _) -> Bool in offset == index })?.element
    }

    private func updateRowAtIndex(index: Int) {
        let row = getItemForIndex(index: index)

        if let row = row {
            let changeStep = ChangeStep<Row, TableIndex>
                .update(item: row, at: TableIndex(section: 0, row: index))
            let tableChange = TableChange<Section, Row>.row(changeStep)
            apply(changes: [tableChange], animation: .none)
        }
    }

    func hasPreviousRow() -> Bool { currentIndex != 0 }

    func hasNextRow() -> Bool { currentIndex + 1 < table.count }

    func updateCurrentRow() { updateRowAtIndex(index: currentIndex) }
}
