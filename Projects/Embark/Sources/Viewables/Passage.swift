import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct Passage { let state: EmbarkState }

typealias EmbarkPassage = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage

extension Passage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GiraffeGraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()

        let embarkMessages = EmbarkMessages(state: state)
        bag += view.addArranged(embarkMessages)

        let action = Action(state: state)

        bag += state.currentPassageSignal.onValue { passage in print("API", passage?.api ?? "none") }

        return (
            view,
            Signal { callback in bag += view.addArranged(action).onValue(callback)
                return bag
            }
        )
    }
}
