import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

typealias EmbarkDropDownActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum.Component.AsEmbarkDropdownAction.DropDownActionDatum

typealias EmbarkSwitchActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkMultiAction.MultiActionDatum.Component.AsEmbarkSwitchAction.SwitchActionDatum

typealias EmbarkNumberActionFragment = GraphQL.EmbarkNumberActionFragment

internal enum MultiActionComponent {
    case number(EmbarkNumberActionFragment)
    case dropDown(EmbarkDropDownActionData)
    case `switch`(EmbarkSwitchActionData)
    case empty
}

struct MultiActionTable {
    let state: EmbarkState
    var components: [MultiActionComponent]
}

extension MultiActionTable: Presentable {
    func materialize() -> (UIViewController, Future<[String: Any]>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        var dictionary = [String: Any]()

        let section = form.appendSection()

        bag += viewController.install(form)

        func addNumberAction(_ data: EmbarkNumberActionFragment) {
            let numberAction = MultiActionNumberRow(data: data)

            bag += section.append(numberAction)
        }

        components.forEach { component in
            switch component {
            case let .number(data):
                addNumberAction(data)
            case let .dropDown(data):
                break
            case let .switch(data):
                break
            case .empty:
                break
            }
        }

        return (viewController, Future { callback in
            func submit() {
                callback(.success([:]))
            }

            return bag
        })
    }
}
