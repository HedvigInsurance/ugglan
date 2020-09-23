import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct KeyGearImageCarousel {
    let imagesSignal: ReadSignal<[Either<URL, GraphQL.KeyGearItemCategory>]>
}

extension KeyGearImageCarousel: Viewable {
    func materialize(events _: ViewableEvents) -> (UICollectionView, Disposable) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionKit = CollectionKit<EmptySection, KeyGearImageCarouselItem>(table: Table(rows: []), layout: layout)
        collectionKit.view.isPagingEnabled = true
        collectionKit.view.backgroundColor = .brand(.secondaryBackground())
        let bag = DisposeBag()

        bag += imagesSignal.atOnce().onValue { images in
            collectionKit.table = Table(rows: images.map { KeyGearImageCarouselItem(resource: $0) })
        }

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: collectionKit.view.frame.width, height: 400)
        }

        collectionKit.view.snp.makeConstraints { make in
            make.height.equalTo(400)
        }

        let pagerDots = PagerDots()

        bag += collectionKit.view.add(pagerDots) { pagerDotsView in
            pagerDotsView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(20)
            }
        }

        return (collectionKit.view, bag)
    }
}
