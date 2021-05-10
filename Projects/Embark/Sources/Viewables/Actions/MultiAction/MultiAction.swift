import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

typealias MultiActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum

struct MultiAction {
    let state: EmbarkState
    let data: MultiActionData
}

extension MultiAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        let bag = DisposeBag()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15,
                                           verticalInset: 10)

        let collectionKit = CollectionKit<EmptySection, MultiActionObjectRow>(
            table: Table(rows: [MultiActionObjectRow(title: "Add building")]),
            layout: layout
        )

        bag.hold(collectionKit)

        collectionKit.view.backgroundColor = .clear
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: 100, height: 50.0)
        }

        view.addSubview(collectionKit.view)
        collectionKit.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return (view, bag)
    }
}
