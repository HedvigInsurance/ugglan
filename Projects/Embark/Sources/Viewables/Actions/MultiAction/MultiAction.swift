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

typealias MultiActionRow = Either<MultiActionValueRow, MultiActionAddObjectRow>

struct GenericMultiActionType {
    var storePrefix: String
    var values: [String]
}

struct MultiAction {
    let state: EmbarkState
    let data: MultiActionData
    @ReadWriteState var rows: [MultiActionRow] = []
    let callbacker = Callbacker<Void>()
}

extension MultiAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15,
                                           verticalInset: 10)

        let collectionKit = CollectionKit<EmptySection, MultiActionRow>(
            layout: layout
        )

        bag += $rows.atOnce()
            .map { Table<EmptySection, MultiActionRow>(rows: $0) }
            .onValue { table in
                collectionKit.table = table
            }

        $rows.value = [.right(.init(title: data.addLabel ?? ""))]

//        func table(newRows: [MultiActionValueRow]) -> Table<EmptySection, MultiActionRow> {
//            var rows = [Either<MultiActionValueRow, MultiActionAddObjectRow>]()
//            rows.append()
//
//            let leftRows = newRows.map { (row) ->  Either<MultiActionValueRow, MultiActionAddObjectRow> in
//                return .make(row)
//            }
//
//            rows += leftRows
//
//            return
//        }

        collectionKit.view.backgroundColor = .clear
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: 100, height: 50.0)
        }

        func present() -> Future<[String: Any]> {
            let components = data.components.map { (component) -> MultiActionComponent in
                if let dropDownAction = component.asEmbarkDropdownAction?.dropDownActionData {
                    return .dropDown(dropDownAction)
                } else if let switchAction = component.asEmbarkSwitchAction?.switchActionData {
                    return .switch(switchAction)
                } else if let numberAction = component.asEmbarkNumberAction?.numberActionData.fragments.embarkNumberActionFragment {
                    return .number(numberAction)
                }

                return .empty
            }

            let multiActionForm = MultiActionTable(state: state, components: components)

            return collectionKit.view.viewController!.present(multiActionForm)
        }

        bag += collectionKit.delegate.didSelect.onValue { index in
            print(index)
        }

        bag += collectionKit.onValueDisposePrevious { table -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += table.signal().onValue { item in
                switch item {
                case .left:
                    break
                case let .right(row):
                    innerBag += row.callbacker.onValue {
                        bag += present()
                    }
                }
            }

            return innerBag
        }

        bag += collectionKit.view.didLayoutSignal.onValue {
            collectionKit.view.snp.makeConstraints { make in
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }

        return (collectionKit.view, Signal { callback in

            bag += callbacker.onValue { () in
                callback(data.link.fragments.embarkLinkFragment)
            }

            return bag
        })
    }
}
