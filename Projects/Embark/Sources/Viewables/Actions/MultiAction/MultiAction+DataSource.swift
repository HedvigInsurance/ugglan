import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct MultiActionDataSource {
	internal init(
		maxCount: Int,
		addLabelTitle: String
	) {
		self.maxCount = maxCount
		addObjectRow = MultiActionRow.make(.init(title: addLabelTitle))
	}

	let maxCount: Int
	let addObjectRow: MultiActionRow

	@ReadWriteState var rows: [MultiActionRow] = []

	func addValue(values: [String: MultiActionValue]) {
		let title = values.first(where: { (key, _) -> Bool in key == "type" })?.value.displayValue

		$rows.value.append(.make(.init(values: values, title: title ?? "")))

		resolveMaxCount()
	}

	func removeValue(row: MultiActionValueRow) {
		if let firstIndex = $rows.value.firstIndex(where: { (either) -> Bool in
			if case let .left(iteratedRow) = either {
				return iteratedRow.id == row.id
			} else {
				return false
			}
		}) {
			$rows.value.remove(at: firstIndex)
		}

		resolveMaxCount()
	}

	func resolveMaxCount() {
		if rows.count > maxCount {
			$rows.value.removeFirst(addObjectRow)
		} else if !rows.contains(addObjectRow) {
			$rows.value.insert(addObjectRow, at: 0)
		}
	}

	func lazyLoadDataSource(persistedRows: [MultiActionValueRow]) {
		$rows.value = [addObjectRow] + persistedRows.map { MultiActionRow.left($0) }
	}
}

extension Array where Element == MultiActionRow {
	fileprivate mutating func removeFirst(_ value: Element) {
		if let firstIndex = self.firstIndex(where: { (either) -> Bool in
			switch (either, value) {
			case (.right, .right): return true
			case (.left, .left): return true
			default: return false
			}
		}) {
			remove(at: firstIndex)
		}
	}
}
