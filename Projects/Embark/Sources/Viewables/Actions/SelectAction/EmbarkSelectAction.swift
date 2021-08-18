import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

typealias EmbarkSelectActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction

struct EmbarkSelectAction {
    let state: EmbarkState
    let data: EmbarkSelectActionData
    @ReadWriteState private var isSelectOptionLoading = false
}

extension EmbarkSelectAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let bag = DisposeBag()

        return (
            view,
            Signal { callback in let options = self.data.selectActionData.options
                let numberOfStacks =
                    options.count % 2 == 0
                    ? options.count / 2 : Int(floor(Double(options.count) / 2) + 1)

                for iteration in 1...numberOfStacks {
                    let stack = UIStackView()
                    stack.spacing = 10
                    stack.distribution = .fillEqually
                    view.addArrangedSubview(stack)

                    let optionsSlice = Array(
                        options[2 * iteration - 2..<min(2 * iteration, options.count)]
                    )
                    bag += optionsSlice.map { option in
                        let selectActionOption = EmbarkSelectActionOption(
                            state: state,
                            data: option
                        )

                        return stack.addArranged(selectActionOption)
                            .filter(predicate: { _ in !isSelectOptionLoading })
                            .atValue { _ in $isSelectOptionLoading.value = true }
                            .mapLatestToFuture {
                                result -> Future<
                                    (GraphQL.EmbarkLinkFragment, ActionResponseData)
                                > in
                                let defaultLink = option.link.fragments
                                    .embarkLinkFragment

                                if let apiFragment = option.api?.fragments.apiFragment {
                                    selectActionOption.$isLoading.value = true
                                    return state.handleApi(apiFragment: apiFragment)
                                        .map { link in
                                            (link ?? defaultLink, result)
                                        }
                                }

                                return Future((defaultLink, result))
                            }
                            .onValue { link, result in
                                result.keys.enumerated()
                                    .forEach { offset, key in
                                        let value = result.values[offset]
                                        self.state.store.setValue(
                                            key: key,
                                            value: value
                                        )
                                    }

                                if let passageName = self.state.passageNameSignal.value {
                                    self.state.store.setValue(
                                        key: "\(passageName)Result",
                                        value: result.textValue
                                    )
                                }

                                callback(link)
                            }
                    }
                    if optionsSlice.count < 2, options.count > 1 {
                        stack.addArrangedSubview(UIView())
                    }
                }

                return bag
            }
        )
    }
}
