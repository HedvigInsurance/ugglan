import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct TextActionSet {
    let state: EmbarkState
    let data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextActionSet
}

private typealias TextAction = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextActionSet.TextActionSetDatum.TextAction

extension TextActionSet: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        let bag = DisposeBag()

        let textActions = data.textActionSetData?.textActions.enumerated().map { index, textAction -> (signal: ReadWriteSignal<String>, shouldReturn: Delegate<String, Bool>, action: TextAction) in
            var masking: Masking? {
                guard let mask = textAction.data?.mask, let maskType = MaskType(rawValue: mask) else {
                    return nil
                }

                return Masking(type: maskType)
            }

            let input = EmbarkInput(
                placeholder: textAction.data?.placeholder ?? "",
                keyboardType: masking?.keyboardType,
                textContentType: masking?.textContentType,
                masking: masking,
                shouldAutoFocus: index == 0,
                fieldStyle: .embarkInputSmall
            )
            return (signal: view.addArranged(input), shouldReturn: input.shouldReturn, action: textAction)
        }

        let button = Button(
            title: data.textActionSetData?.link.label ?? "",
            type: .standard(backgroundColor: .black, textColor: .white)
        )

        bag += view.addArranged(button)

        bag += view.chainAllControlResponders()

        return (view, Signal { callback in
            func complete() {
                textActions?.forEach { signal, _, textAction in
                    self.state.store.setValue(key: textAction.data?.key, value: signal.value)
                }

                if let passageName = self.state.passageNameSignal.value {
                    self.state.store.setValue(key: "\(passageName)Result", value: textActions?.map { $0.signal.value }.joined(separator: ",") ?? "")
                }

                if let link = self.data.textActionSetData?.link {
                    callback(link.fragments.embarkLinkFragment)
                }
            }

            if let textActions = textActions {
                bag += textActions.map { _, shouldReturn, _ in shouldReturn }.enumerated().map { offset, shouldReturn in
                    shouldReturn.set { _ -> Bool in
                        if offset == textActions.count - 1 {
                            complete()
                        }
                        return true
                    }
                }
            }

            bag += button.onTapSignal.onValue { _ in
                complete()
            }

            return bag
        })
    }
}
