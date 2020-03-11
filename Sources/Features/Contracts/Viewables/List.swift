//
//  List.swift
//  FeatureContracts
//
//  Created by Sam Pettersson on 2020-03-11.
//

import Foundation
import ComponentKit
import UIKit
import Form
import Common
import Apollo
import Flow

struct List {
    @Inject var client: ApolloClient
}

extension List: Viewable {
    func materialize(events: ViewableEvents) -> (UICollectionView, Disposable) {
        let layout = UICollectionViewLayout()
        let collectionKit = CollectionKit<EmptySection, ContractRow>(layout: layout)
        collectionKit.view.backgroundColor = .hedvig(.primaryBackground)
        
        let bag = DisposeBag()
        
        return (collectionKit.view, bag)
    }
}
