import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

public struct PerilCollection {
    let perilFragmentsSignal: ReadSignal<[GraphQL.PerilFragment]>

    public init(perilFragmentsSignal: ReadSignal<[GraphQL.PerilFragment]>) {
        self.perilFragmentsSignal = perilFragmentsSignal
    }
}

extension PerilCollection: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let layout = UICollectionViewFlowLayout()
        let collectionKit = CollectionKit<EmptySection, PerilRow>(layout: layout)
        collectionKit.view.backgroundColor = .clear

        let bag = DisposeBag()

        bag += perilFragmentsSignal.atOnce().onValue { perilFragments in
            collectionKit.set(
                Table(rows: perilFragments.map { fragment -> PerilRow in
                    .init(fragment: fragment)
                })
            )
        }

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(
                width: collectionKit.view.frame.size.width / 2 - 5,
                height: 64
            )
        }
        
        bag += collectionKit.view.signal(for: \.bounds).onValue({ _ in
            collectionKit.view.reloadData()
        })

        bag += collectionKit.view.signal(for: \.contentSize).onValue { size in
            collectionKit.view.snp.updateConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        return (collectionKit.view, bag)
    }
}
