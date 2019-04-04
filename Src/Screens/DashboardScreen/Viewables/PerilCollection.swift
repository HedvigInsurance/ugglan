//
//  InsuranceDetails.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-04.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct PerilCollection {
    let perils: [String]
    let client: ApolloClient
    
    init(
        perils: [String],
        client: ApolloClient = ApolloContainer.shared.client
        ) {
        self.client = client
        self.perils = perils
    }
}

extension PerilCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionKit = CollectionKit<EmptySection, Peril>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )
        
        collectionKit.view.backgroundColor = .clear
        
        let cells = ReadWriteSignal<[Peril]>([])
        
        bag += cells.atOnce().onValue { perilViewableArray in
            collectionKit.set(Table(rows: perilViewableArray), animation: .none, rowIdentifier: { $0.peril })
            
            collectionKit.view.snp.remakeConstraints{ make in
                make.width.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.width)
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }
        
        bag += client.watch(
            query: DashboardQuery()
        ).compactMap {
            $0.data?.insurance.perilCategories?.compactMap { $0 }
        }.onValue { perilSignalArray in
            let perilViewableArray = perilSignalArray.map { peril in
                Peril(peril: peril.title ?? "")
            }
            
            cells.value = perilViewableArray
        }
        
        return (collectionKit.view, bag)
    }
}
