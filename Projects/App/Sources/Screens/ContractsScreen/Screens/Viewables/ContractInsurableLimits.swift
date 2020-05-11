//
//  ContractInsurableLimits.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import Core

struct ContractInsurableLimits {
    let insurableLimitFragmentsSignal: ReadSignal<[InsurableLimitFragment]>
}

extension ContractInsurableLimits: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let layout = UICollectionViewFlowLayout()
        let collectionKit = CollectionKit<EmptySection, ContractInsurableLimitRow>(layout: layout)
        collectionKit.view.backgroundColor = .transparent

        let bag = DisposeBag()

        bag += insurableLimitFragmentsSignal.atOnce().onValue { InsurableLimitFragments in

            collectionKit.set(Table(rows: InsurableLimitFragments.map { fragment -> ContractInsurableLimitRow in
                .init(fragment: fragment)
                       }))
        }

        bag += collectionKit.delegate.sizeForItemAt.set { index -> CGSize in
            let width = collectionKit.view.frame.size.width / 2 - 5
            return CGSize(width: width, height: collectionKit.table[index].contentSize(CGSize(width: width, height: 0)).height)
        }

        bag += collectionKit.view.signal(for: \.contentSize).onValue { size in
            collectionKit.view.snp.updateConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        return (collectionKit.view, bag)
    }
}
