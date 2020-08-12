//
//  ContractPerilCollection.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-17.
//

import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit
import hGraphQL

public struct ContractPerilCollection {
    let presentDetailStyle: PresentationStyle
    let perilFragmentsSignal: ReadSignal<[GraphQL.PerilFragment]>
    
    public init(presentDetailStyle: PresentationStyle, perilFragmentsSignal: ReadSignal<[GraphQL.PerilFragment]>) {
        self.presentDetailStyle = presentDetailStyle
        self.perilFragmentsSignal = perilFragmentsSignal
    }
}

extension ContractPerilCollection: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let layout = UICollectionViewFlowLayout()
        let collectionKit = CollectionKit<EmptySection, ContractPerilRow>(layout: layout)
        collectionKit.view.backgroundColor = .clear

        let bag = DisposeBag()

        bag += perilFragmentsSignal.atOnce().onValue { perilFragments in
            collectionKit.set(
                Table(rows: perilFragments.map { fragment -> ContractPerilRow in
                    .init(presentDetailStyle: self.presentDetailStyle, fragment: fragment)
                })
            )
        }

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: collectionKit.view.frame.size.width / 2 - 5, height: 64)
        }

        bag += collectionKit.view.signal(for: \.contentSize).onValue { size in
            collectionKit.view.snp.updateConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        return (collectionKit.view, bag)
    }
}
