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

        let dataSource = MultiActionDataSource(maxCount: Int(data.maxAmount) ?? 1, addLabelTitle: data.addLabel ?? "")

        let collectionKit = CollectionKit<EmptySection, MultiActionRow>(
            table: Table(rows: dataSource.rows),
            layout: layout
        )

        let delegate = collectionKit.delegate
        bag.hold(delegate)

        collectionKit.view.backgroundColor = .clear
        view.addArrangedSubview(collectionKit.view)

        bag += dataSource.$rows.atOnce()
            .map { Table<EmptySection, MultiActionRow>(rows: $0) }
            .onValue { table in
                collectionKit.set(table)
            }

        func present() -> FiniteSignal<[String: MultiActionValue]>? {
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

            guard let viewController = collectionKit.view.viewController else { return nil }

            return viewController.present(multiActionForm, style: .detented(.medium, .large), options: [.defaults, .autoPop])
        }

        bag += collectionKit.onValueDisposePrevious { table in
            let innerBag = DisposeBag()

            innerBag += table.signal().onValue { item in
                switch item {
                case let .left(row):
                    innerBag += row.didTapRow.onValue { _ in
                        dataSource.removeValue(row: row)
                    }
                case let .right(row):
                    innerBag += row.didTapRow.onValue { _ in
                        innerBag += present()?.onValue { values in
                            dataSource.addValue(values: values)
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

        bag += view.didMoveToWindowSignal.onValue {
            dataSource.lazyLoadDataSource(persistedRows: self.state.store.persistedMultiActionValueRows)
        }

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

                let rows = dataSource.rows
                    .compactMap { $0.left }

                self.state.store.persistedMultiActionValueRows = rows

                self.state.store.addMultiActionItems(actionKey: key, componentValues: rows.map { $0.values }) {
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

private var persistedRowsKey = 0

private extension EmbarkStore {
    var persistedMultiActionValueRows: [MultiActionValueRow] {
        get {
            objc_getAssociatedObject(self, &persistedRowsKey) as? [MultiActionValueRow] ?? []
        }
        set {
            objc_setAssociatedObject(self, &persistedRowsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
