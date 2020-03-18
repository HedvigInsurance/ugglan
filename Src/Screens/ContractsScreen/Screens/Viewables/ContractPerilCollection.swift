//
//  ContractPerilCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Foundation
import UIKit
import Flow
import Form

struct ContractPerilCollection {}

extension ContractPerilCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let layout = UICollectionViewFlowLayout()
        let collectionKit = CollectionKit<EmptySection, ContractPerilRow>(layout: layout)
        collectionKit.view.backgroundColor = .transparent
        
        collectionKit.table = Table(rows: Array(repeating: .init(), count: 12))
        
        let bag = DisposeBag()
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            return CGSize(width: collectionKit.view.frame.size.width / 2 - 5, height: 50)
        }
        
        bag += collectionKit.view.didLayoutSignal.onValue { _ in
            collectionKit.view.snp.makeConstraints { make in
                make.height.equalTo(collectionKit.view.contentSize.height)
            }
        }
        
        return (collectionKit.view, bag)
    }
}
