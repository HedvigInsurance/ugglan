import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct MultiActionTable {
    let state: EmbarkState
    var components: [MultiActionComponent]
    let title: String?
    let storeSignal = MultiActionStoreSignal()
}

extension MultiActionTable: Presentable {
    func materialize() -> (UIViewController, Future<[String: Any]>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        var dictionary = [String: Any]()

        let section = form.appendSection()

        bag += viewController.install(form)
        viewController.title = title

        func addDividerIfNeeded(index: Int) {
            let endIndex = components.endIndex
            let isLastComponent: Bool = index == endIndex - 1

            if !isLastComponent {
                let divider = Divider(backgroundColor: .brand(.primaryBorderColor))
                bag += section.add(divider)
            }
        }

        func addValues(storeValues: [String: Any]) {
            dictionary = dictionary.merging(storeValues, uniquingKeysWith: takeLeft)
        }

        func addNumberAction(_ data: EmbarkNumberActionFragment, index: Int) {
            let numberAction = MultiActionNumberRow(data: data)

            bag += section.append(numberAction) { _ in
                addDividerIfNeeded(index: index)
            }.onValue {
                addValues(storeValues: $0)
            }
        }

        func addDropDownAction(_ data: EmbarkDropDownActionData, index: Int) {
            let dropDownAction = MultiActionDropDownRow(data: data)

            bag += section.append(dropDownAction) { _ in
                addDividerIfNeeded(index: index)
            }.onValue {
                addValues(storeValues: $0)
            }
        }

        func addSwitchAction(_ data: EmbarkSwitchActionData, index: Int) {
            let switchAction = MultiActionSwitchRow(data: data)

            bag += section.append(switchAction) { _ in
                addDividerIfNeeded(index: index)
            }.onValue {
                addValues(storeValues: $0)
            }
        }

        components.enumerated().forEach { index, component in
            switch component {
            case let .number(data):
                addNumberAction(data, index: index)
            case let .dropDown(data):
                addDropDownAction(data, index: index)
            case let .switch(data):
                addSwitchAction(data, index: index)
            case .empty:
                break
            }
        }

        let button = Button(
            title: "Save",
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        bag += section.append(button)

        return (viewController, Future { callback in
            func submit() {
                callback(.success(dictionary))
            }

            bag += button.onTapSignal.onValue { _ in
                submit()
            }

            return bag
        })
    }
}

typealias EmbarkDropDownActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum.Component.AsEmbarkDropdownAction.DropDownActionDatum

typealias EmbarkSwitchActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum.Component.AsEmbarkSwitchAction.SwitchActionDatum

typealias EmbarkNumberActionFragment = GraphQL.EmbarkNumberActionFragment

internal typealias MultiActionStoreSignal = Signal<[String: Any]>

internal enum MultiActionComponent {
    case number(EmbarkNumberActionFragment)
    case dropDown(EmbarkDropDownActionData)
    case `switch`(EmbarkSwitchActionData)
    case empty
}
