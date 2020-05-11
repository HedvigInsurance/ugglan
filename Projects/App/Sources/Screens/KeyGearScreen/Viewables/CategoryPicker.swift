//
//  CategoryPicker.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-13.
//

import Flow
import Form
import Foundation
import UIKit
import Core

struct CategoryPicker {
    let onSelectCategorySignal: Signal<KeyGearItemCategory>
}

extension CategoryPicker: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<KeyGearItemCategory>) {
        let bag = DisposeBag()
        let layout = UICollectionViewTagLayout()
        let collectionKit = CollectionKit<EmptySection, KeyGearCategoryButton>(layout: layout)
        collectionKit.view.backgroundColor = .transparent

        bag += collectionKit.delegate.sizeForItemAt.set { index -> CGSize in
            let row = collectionKit.table[index]
            return row.calculateSize()
        }

        bag += collectionKit.view.didLayoutSignal.onValue {
            collectionKit.view.snp.makeConstraints { make in
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }

        bag += onSelectCategorySignal.onValue { selectedCategory in
            guard let category = collectionKit.table.first(where: { selectedCategory == $0.category }) else {
                return
            }

            category.selectedSignal.value = true
        }

        let onPickItem = Callbacker<KeyGearItemCategory>()

        bag += collectionKit.onValueDisposePrevious { table -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += table.signal().onValue { item in
                innerBag += item.selectedSignal.onValueDisposePrevious { selected in
                    if selected {
                        onPickItem.callAll(with: item.category)

                        return table.signal()
                            .filter { $0 != item }
                            .onValue { $0.selectedSignal.value = false }
                    }

                    return NilDisposer()
                }
            }

            return innerBag
        }

        collectionKit.table = Table(rows: KeyGearItemCategory.allCases.map { category in
            KeyGearCategoryButton(category: category)
        })

        let contentContainer = UIStackView()
        contentContainer.layoutMargins = UIEdgeInsets(inset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true

        contentContainer.addArrangedSubview(collectionKit.view)

        return (contentContainer, onPickItem.providedSignal.hold(bag))
    }
}
