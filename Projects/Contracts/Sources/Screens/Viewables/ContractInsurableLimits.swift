import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

public struct ContractInsurableLimits {
    let insurableLimitFragmentsSignal: ReadSignal<[GraphQL.InsurableLimitFragment]>

    public init(insurableLimitFragmentsSignal: ReadSignal<[GraphQL.InsurableLimitFragment]>) {
        self.insurableLimitFragmentsSignal = insurableLimitFragmentsSignal
    }
}

extension ContractInsurableLimits: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let layout = UICollectionViewFlowLayout()
        let collectionKit = CollectionKit<EmptySection, ContractInsurableLimitRow>(layout: layout)
        collectionKit.view.backgroundColor = .clear

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

        bag += collectionKit.view.signal(for: \.bounds).onValue { _ in
            collectionKit.view.reloadData()
        }

        bag += collectionKit.view.signal(for: \.contentSize).onValue { size in
            collectionKit.view.snp.updateConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        return (collectionKit.view, bag)
    }
}
