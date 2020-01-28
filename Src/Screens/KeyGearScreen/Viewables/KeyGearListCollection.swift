//
//  KeyGearListCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import UIKit
import Flow
import Form

struct KeyGearListCollection {
    enum Effect {
        case add, row(id: String)
    }
}

typealias KeyGearListCollectionRow = Either<KeyGearListItem, ReusableSignalViewable<KeyGearAddButton, Void>>

extension KeyGearListCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UICollectionView, Signal<Effect>) {
        let bag = DisposeBag()
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        
        var rows: [KeyGearListCollectionRow] = Array.init(repeating: .make(KeyGearListItem(id: "todo", imageUrl: nil, wasAddedAutomatically: true)), count: 500)
        
        let addButton = ReusableSignalViewable(viewable: KeyGearAddButton())
        
        rows.insert(.make(addButton), at: 0)
        
        let collectionKit = CollectionKit<EmptySection, KeyGearListCollectionRow>(
            table: .init(rows: rows),
            layout: layout
        )
        collectionKit.view.backgroundColor = .transparent
        
        bag += collectionKit.view.didLayoutSignal.onValue { _ in
            collectionKit.view.snp.makeConstraints { make in
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            return CGSize(width: collectionKit.view.frame.width / 2 - 5 - 15, height: 120)
        }
                
        return (collectionKit.view, Signal { callback in
            bag += addButton.onValue { _ in
                callback(.add)
            }
            
            bag += collectionKit.table.signal().onValueDisposePrevious { value -> Disposable? in
                switch (value) {
                case let .left(row):
                    return row.onValue { _ in
                        callback(.row(id: row.id))
                    }
                case .right:
                    return NilDisposer()
                }
            }
            
            return bag
        })
    }
}
