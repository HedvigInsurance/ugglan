import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

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
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let maxCellWidth = UIScreen.main.bounds.width / 2 - 28

        let collectionKit = CollectionKit<EmptySection, MultiActionRow>(
            table: Table(rows: []),
            layout: layout,
            holdIn: bag
        )

        collectionKit.view.backgroundColor = .clear
        view.addArrangedSubview(collectionKit.view)

        let delegate = collectionKit.delegate
        bag.hold(delegate)

        bag += $rows.atOnce()
            .map { Table<EmptySection, MultiActionRow>(rows: $0) }
            .onValue { table in
                collectionKit.set(table)
            }

        bag += collectionKit.onValueDisposePrevious { table in
            let innerBag = DisposeBag()

            innerBag += table.signal().onValue { item in
                switch item {
                case let .left(row):
                    innerBag += row.didTapRow.onValue { _ in
                        if let firstIndex = $rows.value.firstIndex(where: { (either) -> Bool in
                            if case let .left(iteratedRow) = either {
                                return iteratedRow.id == row.id
                            } else {
                                return false
                            }
                        }) {
                            $rows.value.remove(at: firstIndex)
                        }
                    }
                case let .right(row):
                    innerBag += row.didTapRow.onValue { _ in
                        innerBag += present().onValue { values in
                            $rows.value.append(.make(.init(values: values)))
                        }
                    }
                }
            }

            return innerBag
        }

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            let height = 0.55 * maxCellWidth

            return CGSize(width: maxCellWidth, height: height)
        }

        func present() -> FiniteSignal<[String: String]> {
            let components = data.components.map { (component) -> MultiActionComponent in
                if let dropDownAction = component.asEmbarkDropdownAction?.dropDownActionData {
                    return .dropDown(dropDownAction)
                } else if let switchAction = component.asEmbarkSwitchAction?.switchActionData {
                    return .switch(switchAction)
                } else if let numberAction = component.asEmbarkMultiActionNumberAction?.data {
                    return .number(numberAction)
                }

                return .empty
            }

            let multiActionForm = MultiActionTable(state: state, components: components, title: data.addLabel)

            return collectionKit.view.viewController!.present(multiActionForm, style: .detented(.medium, .large), options: [.defaults])
        }

        $rows.value = [.right(.init(title: data.addLabel ?? ""))]

        return (view, Signal { callback in

            bag += collectionKit.view.didLayoutSignal.onValue {
                collectionKit.view.snp.makeConstraints { make in
                    make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
                }
            }

            bag += collectionKit.view.signal(for: \.contentSize).onValue { size in
                collectionKit.view.snp.remakeConstraints { make in
                    let maxHeight = maxCellWidth * 0.55 * 2 + 8
                    if maxHeight < size.height {
                        make.height.equalTo(maxHeight)
                    } else {
                        make.height.equalTo(size.height)
                    }
                }
            }

            let button = Button(
                title: self.data.link.fragments.embarkLinkFragment.label,
                type: .standard(
                    backgroundColor: .brand(.secondaryButtonBackgroundColor),
                    textColor: .brand(.secondaryButtonTextColor)
                )
            )

            bag += view.addArranged(button)

            func submit() {
                guard let key = data.key else { return }

                let values = rows.compactMap { $0.left?.values }
                self.state.store.addMultiActionItems(actionKey: key, componentValues: values) {
                    self.state.store.createRevision()
                }
                callback(data.link.fragments.embarkLinkFragment)
            }

            bag += button.onTapSignal.onValue {
                submit()
            }

            return bag
        })
    }
}

typealias MultiActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum

typealias MultiActionRow = Either<MultiActionValueRow, MultiActionAddObjectRow>

private extension Sequence where Element == MultiActionStoreable {
    var title: String? {
        first { (element) -> Bool in
            element.componentKey == "type"
        }?.value
    }
}
