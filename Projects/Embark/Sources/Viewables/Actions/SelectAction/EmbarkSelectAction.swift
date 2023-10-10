import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

typealias EmbarkSelectActionData = GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction

struct EmbarkSelectAction {
    let state: EmbarkState
    let data: EmbarkSelectActionData
    @ReadWriteState private var isSelectOptionLoading = false

    func handleClick(
        option: EmbarkSelectActionData.SelectActionDatum.Option
    ) -> Future<GiraffeGraphQL.EmbarkLinkFragment>? {
        if isSelectOptionLoading {
            return nil
        }

        $isSelectOptionLoading.value = true

        let optionFuture: Future<(GiraffeGraphQL.EmbarkLinkFragment, ActionResponseData)> = {
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
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GiraffeGraphQL.EmbarkLinkFragment>) {
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
                                backgroundColor: .brand(.secondaryBackground(true)),
                                textColor: .brand(.primaryText())
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
                    bag += options.chunked(into: 2)
                        .map { chunk -> [Disposable] in
                            let stack = UIStackView()
                            stack.spacing = 10
                            stack.distribution = .fillEqually
                            view.addArrangedSubview(stack)

                            var chunkComposition: [Either<EmbarkSelectActionData.SelectActionDatum.Option, Void>] = []

                            chunkComposition.append(contentsOf: chunk.map { .left($0) })

                            if chunk.count < 2, options.count > 1 {
                                chunkComposition.append(.right(()))
                            }

                            return chunkComposition.map { composition in
                                if let option = composition.left {
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
                                } else {
                                    let spacer = UIView()

                                    stack.addArrangedSubview(spacer)

                                    return Disposer {
                                        spacer.removeFromSuperview()
                                    }
                                }
                            }
                        }
                        .flatMap { $0 }
                }

                return bag
            }
        )
    }
}
