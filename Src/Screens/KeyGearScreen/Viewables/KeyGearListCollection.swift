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
import Apollo

struct KeyGearListCollection {
    @Inject var client: ApolloClient
    
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
        layout.sectionInset = UIEdgeInsets(horizontalInset: 0, verticalInset: 0)
        
        
        let addButton = ReusableSignalViewable(viewable: KeyGearAddButton())
        
        let collectionKit = CollectionKit<EmptySection, KeyGearListCollectionRow>(
            table: Table(rows: []),
            layout: layout
        )
        collectionKit.view.backgroundColor = .transparent
        
        bag += collectionKit.view.didLayoutSignal.onValue { _ in
            collectionKit.view.snp.makeConstraints { make in
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            return CGSize(width: collectionKit.view.frame.width / 2 - 5, height: 120)
        }
        
        bag += client.watch(query: KeyGearItemsQuery()).map { $0.data?.keyGearItemsSimple }.onValue { items in
            guard let items = items, !items.isEmpty else {
                collectionKit.table = Table(rows: [.make(addButton)])
                return
            }
            
            var rows: [KeyGearListCollectionRow] = items.compactMap { $0 }.map { item in
                .make(KeyGearListItem(id: item.id, imageUrl: nil, wasAddedAutomatically: true))
            }
            
            rows.insert(.make(addButton), at: 0)
            
            collectionKit.table = Table(rows: rows)
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
