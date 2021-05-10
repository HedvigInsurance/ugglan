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

enum MultiActionComponent {
    case number(EmbarkNumberActionData)
    case dropDown(EmbarkDropDownActionData)
    case `switch`(EmbarkSwitchActionData)
}

struct MultiActionTable {
    let state: EmbarkState
    var components: [MultiActionComponent]
}

extension MultiActionTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UIViewController, Future<[String: Any]>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        bag += viewController.install(form)

        components.forEach { component in
            switch component {
            case let .number(data):
                let numberAction = EmbarkNumberAction(state: self.state, data: data)
                let row = RowView()
                bag += row.append(numberAction).onValue { _ in
                }

            case let .dropDown(data):
                break
            case let .switch(data):
                break
            }
        }

        return (viewController, Future { callback in
            callback(.success([:]))

            return bag
        })
    }
}
