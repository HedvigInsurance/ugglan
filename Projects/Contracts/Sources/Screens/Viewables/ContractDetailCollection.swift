import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

struct ContractDetailCollection {
	@ReadWriteState var rows: [ContractDetailPresentableRow]
	@ReadWriteState var currentIndex: IndexPath
}

extension ContractDetailCollection: Viewable {
	func materialize(events _: ViewableEvents) -> (UICollectionView, Disposable) {
		let layout = TopAlignedCollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		let collectionKit = CollectionKit<EmptySection, ContractDetailPresentableRow>(layout: layout)
		collectionKit.view.backgroundColor = .clear
		collectionKit.view.isPagingEnabled = true
		collectionKit.view.isScrollEnabled = false

		let bag = DisposeBag()

		var contentSizes: [IndexPath: CGSize] = [:]

		bag += $rows.atOnce().map { Table(rows: $0) }.onValue { table in collectionKit.set(table) }

		bag += $currentIndex.onValue { index in
			collectionKit.view.setContentOffset(
				offset: CGPoint(x: CGFloat(index.row) * collectionKit.view.frame.width, y: 0),
				timingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
				duration: 0.3
			)
		}

		bag += collectionKit.delegate.sizeForItemAt.set { index -> CGSize in
			let row = collectionKit.table[index]
			let size = row.calculateContentSize(
				collectionKit.view.frame.size,
				safeAreaInsets: collectionKit.view.safeAreaInsets
			)
			contentSizes[IndexPath(row: index.row, section: index.section)] = size

			return CGSize(width: collectionKit.view.frame.width, height: size.height)
		}

		collectionKit.view.snp.makeConstraints { make in make.height.equalTo(1) }

		bag += collectionKit.delegate.willDisplayCell.onValue { _, index in
			let height = contentSizes[IndexPath(row: index.row, section: index.section)]?.height ?? 0

			if collectionKit.view.frame.height < height {
				collectionKit.view.snp.updateConstraints { make in make.height.equalTo(height) }
			}
		}

		bag += collectionKit.delegate.didEndDisplayingCell.onValue { _ in
			let currentVisibleCell = collectionKit.view.visibleCells.first

			collectionKit.view.snp.updateConstraints { make in
				make.height.equalTo(currentVisibleCell?.frame.height ?? 1)
			}
		}

		return (collectionKit.view, bag)
	}
}
