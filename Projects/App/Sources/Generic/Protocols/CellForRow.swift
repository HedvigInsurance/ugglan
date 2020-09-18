import Flow
import Form
import Foundation
import UIKit

protocol CellForRow {
    associatedtype Row

    func registerCells(
        collectionView: UICollectionView
    )

    func cellForRow(
        collectionView: UICollectionView,
        row: Row,
        index: TableIndex
    ) -> UICollectionViewCell
}

extension UICollectionView {
    func dequeueCell<T>(cellType: T.Type, index: TableIndex) -> T {
        // swiftlint:disable force_cast
        dequeueReusableCell(
            withReuseIdentifier: String(describing: cellType),
            for: IndexPath(row: index.row, section: index.section)
        ) as! T
        // swiftlint:enable force_cast
    }

    func registerCell(cellClass: AnyClass) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
}

extension CollectionKit {
    convenience init<T: CellForRow>(
        table: Table = Table(),
        layout: UICollectionViewLayout,
        bag: DisposeBag,
        cellForRow: T
    ) where T.Row == Row {
        self.init(table: table, layout: layout, holdIn: bag) { (collectionView, row: Row, index) -> UICollectionViewCell in
            cellForRow.cellForRow(
                collectionView: collectionView,
                row: row,
                index: index
            )
        }

        cellForRow.registerCells(
            collectionView: view
        )
    }
}
