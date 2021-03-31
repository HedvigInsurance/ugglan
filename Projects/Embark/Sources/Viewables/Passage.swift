import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct Passage {
    let state: EmbarkState
}

typealias EmbarkPassage = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage

extension Passage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()

        let embarkMessages = EmbarkMessages(
            state: state
        )
        bag += view.addArranged(embarkMessages)

        let action = Action(
            state: state
        )

        bag += state.currentPassageSignal.onValue { passage in
            print("API", passage?.api ?? "none")
        }

        bag += state.apiResponseSignal.onValue { link in
            guard let link = link else {
                return
            }
            self.state.goTo(
                passageName: link.name,
                pushHistoryEntry: false
            )
        }

        return (view, Signal { callback in
            bag += view.addArranged(action).onValue(callback)
            return bag
        })
    }
}
