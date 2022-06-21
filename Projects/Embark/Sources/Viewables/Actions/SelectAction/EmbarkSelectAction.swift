import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

typealias EmbarkSelectActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction

struct EmbarkSelectAction {
    let state: EmbarkState
    let data: EmbarkSelectActionData
    @ReadWriteState private var isSelectOptionLoading = false

    func handleClick(option: EmbarkSelectActionData.SelectActionDatum.Option) -> Future<GraphQL.EmbarkLinkFragment>? {
        if isSelectOptionLoading {
            return nil
        }

        $isSelectOptionLoading.value = true

        let optionFuture: Future<(GraphQL.EmbarkLinkFragment, ActionResponseData)> = {
            let result = ActionResponseData(
                keys: option.keys,
                values: option.values,
                textValue: option.link.label
            )
            let defaultLink = option.link.fragments
                .embarkLinkFragment

            if let apiFragment = option.api?.fragments.apiFragment {
                return state.handleApi(apiFragment: apiFragment)
                    .map { link in
                        (link ?? defaultLink, result)
                    }
            }

            return Future((defaultLink, result))
        }()

        return optionFuture.map { link, result in
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

            return link
        }
    }
}

extension EmbarkSelectAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let bag = DisposeBag()

        return (
            view,
            Signal { callback in
                let options = self.data.selectActionData.options

                if options.count == 1, let option = options.first {
                    let button = LoadableButton(
                        button: Button(
                            title: option.link.label,
                            type: .standard(
                                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                                textColor: .brand(.secondaryButtonTextColor)
                            )
                        )
                    )

                    bag += button.onTapSignal.onValue({ _ in
                        if option.api != nil {
                            button.isLoadingSignal.value = true
                        }

                        handleClick(option: option)?
                            .onValue({ link in
                                callback(link)
                            })
                    })

                    bag += view.addArranged(button)
                } else {
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
                                .onValue { _ in
                                    handleClick(option: option)?
                                        .onValue({ link in
                                            callback(link)
                                        })
                                }
                        }
                        if optionsSlice.count < 2, options.count > 1 {
                            stack.addArrangedSubview(UIView())
                        }
                    }
                }

                return bag
            }
        )
    }
}
