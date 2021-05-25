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
    @ReadWriteState var multiActionValues = [String: String]()
}

extension MultiActionTable: Presentable {
    func materialize() -> (UIViewController, Future<[String: String]>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection()
        section.dynamicStyle = .brandGroupedNoBackground

        bag += form.traitCollectionSignal.onValue { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                form.backgroundColor = .grayscale(.grayFive)
            default:
                form.backgroundColor = .brand(.primaryBackground())
            }
        }

        bag += viewController.install(form)
        viewController.title = title

        func addDividerIfNeeded(index: Int) {
            let endIndex = components.endIndex
            let isLastComponent: Bool = index == endIndex - 1

            if !isLastComponent {
                let color = form.traitCollection.userInterfaceStyle == .light ? UIColor.brand(.primaryBorderColor) : UIColor.white
                let divider = Divider(backgroundColor: color)
                bag += section.append(divider)
            }
        }

        func addValues(storeValues: [String: String]) {
            $multiActionValues.value = $multiActionValues.value.merging(storeValues, uniquingKeysWith: takeLeft)
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

        func didCompleteForm() -> Bool {
            $multiActionValues.value.count == components.count
        }

        let button = ButtonRowViewWrapper(
            title: "Save",
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            ),
            isEnabled: false
        )

        bag += $multiActionValues
            .map { _ in didCompleteForm() }
            .bindTo(button.isEnabledSignal)

        bag += section.append(Spacing(height: 16))

        section.backgroundColor = .clear

        bag += section.append(button) { rowView in
            rowView.row.backgroundColor = .clear
        }

        return (viewController, Future { callback in
            func submit() {
                callback(.success($multiActionValues.value))
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

internal typealias MultiActionStoreSignal = Signal<[String: String]>

internal enum MultiActionComponent {
    case number(EmbarkNumberActionFragment)
    case dropDown(EmbarkDropDownActionData)
    case `switch`(EmbarkSwitchActionData)
    case empty
}
