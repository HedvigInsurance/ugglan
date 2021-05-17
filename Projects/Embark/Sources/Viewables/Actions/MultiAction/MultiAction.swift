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
}

extension MultiAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let collectionKit = CollectionKit<EmptySection, MultiActionRow>(
            table: Table(rows: []),
            layout: layout,
            holdIn: bag
        )
        collectionKit.view.backgroundColor = .clear
        view.addArrangedSubview(collectionKit.view)

        collectionKit.view.snp.updateConstraints { make in
            make.height.equalTo(200)
        }

        bag += $rows.atOnce()
            .map { Table<EmptySection, MultiActionRow>(rows: $0) }
            .onValue { table in
                collectionKit.set(table)
            }

        bag += collectionKit.onValueDisposePrevious { table in
            let innerBag = DisposeBag()

            innerBag += table.signal().onValue { item in
                switch item {
                case .left:
                    break
                case let .right(row):
                    innerBag += row.didTapRow.onValue { _ in
                        innerBag += present().onValue { values in
                            print(values)
                        }
                    }
                }
            }

            return innerBag
        }

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

            return collectionKit.view.viewController!.present(multiActionForm, style: .detented(.medium))
        }

        bag += collectionKit.delegate.didSelectRow.onValue { row in
            print(row)
        }

        bag += collectionKit.delegate.didSelect.onValue { index in
            print(index)
        }

        $rows.value = [.right(.init(title: data.addLabel ?? "")), .left(.init(title: "Black", keyInformation: ["Blue"]))]

        return (view, Signal { callback in

            let button = Button(
                title: self.data.link.fragments.embarkLinkFragment.label,
                type: .standard(
                    backgroundColor: .brand(.secondaryButtonBackgroundColor),
                    textColor: .brand(.secondaryButtonTextColor)
                )
            )

            bag += view.addArranged(button)

            func submit() {
                callback(data.link.fragments.embarkLinkFragment)
            }

            bag += button.onTapSignal.onValue {
                submit()
            }

            return bag
        })
    }
}
