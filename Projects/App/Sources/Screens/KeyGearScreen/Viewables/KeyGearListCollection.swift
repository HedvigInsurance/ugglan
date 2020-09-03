//
//  KeyGearListCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hGraphQL
import UIKit

struct KeyGearListCollection {
    @Inject var client: ApolloClient

    enum Effect {
        case add, row(id: String)
    }
}

typealias KeyGearListCollectionRow = Either<KeyGearListItem, ReusableSignalViewable<KeyGearAddButton, Void>>

extension KeyGearListCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UICollectionView, Signal<Effect>) {
        let bag = DisposeBag()
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15)
        layout.headerReferenceSize = CGSize(width: 100, height: 350)

        let addButton = ReusableSignalViewable(viewable: KeyGearAddButton())

        let collectionKit = CollectionKit<EmptySection, KeyGearListCollectionRow>(
            table: Table(rows: []),
            layout: layout
        )
        collectionKit.view.backgroundColor = .primaryBackground

        let header = TabHeader(
            image: Asset.keyGearOverviewHeader.image,
            title: L10n.keyGearStartEmptyHeadline,
            description: L10n.keyGearStartEmptyBody
        )

        bag += collectionKit.registerViewForSupplementaryElement(
            kind: UICollectionView.elementKindSectionHeader
        ) { _ in
            header
        }

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: collectionKit.view.frame.width / 2 - 20, height: 120)
        }

        bag += client.watch(query: GraphQL.KeyGearItemsQuery()).map { $0.keyGearItems }.onValue { items in
            guard !items.isEmpty else {
                collectionKit.set(Table(rows: [.make(addButton)]))
                return
            }

            var rows: [KeyGearListCollectionRow] = items.compactMap { $0 }.map { item in
                let photo = item.photos.first
                return .make(KeyGearListItem(
                    id: item.id,
                    imageUrl: URL(string: photo?.file.preSignedUrl),
                    name: item.name,
                    wasAddedAutomatically: item.physicalReferenceHash != nil,
                    category: item.category
                ))
            }

            rows.insert(.make(addButton), at: 0)

            collectionKit.set(Table(rows: rows))
        }

        return (collectionKit.view, Signal { callback in
            bag += addButton.onValue { _ in
                callback(.add)
            }

            bag += collectionKit.onValue { table in
                bag += table.map { value -> Disposable in
                    switch value {
                    case let .left(row):
                        return row.onValue { _ in
                            callback(.row(id: row.id))
                        }
                    case .right:
                        return NilDisposer()
                    }
                }
            }

            return bag
        })
    }
}
