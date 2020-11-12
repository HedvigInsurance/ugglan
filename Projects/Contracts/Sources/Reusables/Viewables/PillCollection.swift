import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct PillCollection {
    typealias PillData = Either<Pill, EffectedPill>
    @ReadWriteState var pills: [PillData]
}

extension PillCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let layout = LeftAlignedCollectionViewFlowLayout()
        let collectionKit = CollectionKit<EmptySection, PillData>(layout: layout)
        collectionKit.view.backgroundColor = .clear

        bag += collectionKit.delegate.sizeForItemAt.set { index -> CGSize in
            let row = collectionKit.table[index]
            return row.left?.size ?? row.right?.size ?? .zero
        }

        bag += $pills.atOnce().map { Table(rows: $0) }.onValue { table in
            collectionKit.set(table)
        }

        collectionKit.view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        bag += collectionKit.view
            .signal(for: \.contentSize)
            .atOnce()
            .filter(predicate: { _ in collectionKit.view.superview != nil })
            .onValue { size in
                collectionKit.view.snp.remakeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }

        return (collectionKit.view, bag)
    }
}
