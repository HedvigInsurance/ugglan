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
        view.spacing = 10
        let bag = DisposeBag()
        
        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.spacing = 20
        boxStack.edgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        
        let containerView = UIView()
        containerView.backgroundColor = .brand(.secondaryBackground())
        containerView.layer.cornerRadius = 8

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
            
            let isFirstName: Bool = textAction.data?.key == "firstName"
            
            func title(isFirstName: Bool) -> String {
                 isFirstName ? "First name" : "Second name"
            }
            
            let label = UILabel(value: title(isFirstName: isFirstName), style: .brand(.body(color: .primary)))
            
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .equalSpacing
            
            stack.addArrangedSubview(label)
            
            boxStack.addArrangedSubview(stack)
            
            if isFirstName {
                let view = UIView.init(height: 1)
                view.backgroundColor = .brand(.primaryBorderColor)
                boxStack.addArrangedSubview(view)
            }
            
            return (signal: stack.addArranged(input), shouldReturn: input.shouldReturn, action: textAction)
        }

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
            
            containerView.addSubview(boxStack)
            boxStack.snp.makeConstraints({ $0.edges.equalToSuperview() })
            
            view.addArrangedSubview(containerView)

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
            
            bag += containerView.applyShadow({ (traitCollection) -> UIView.ShadowProperties in
                UIView.ShadowProperties(
                    opacity: 1,
                    offset: .init(width: 0, height: 2),
                    radius: 2,
                    color: .brand(.secondaryShadowColor),
                    path: nil,
                    corners: (.allCorners, 8))
            })
            
            let button = Button(
                title: data.textActionSetData?.link.label ?? "",
                type: .standard(backgroundColor: .black, textColor: .white)
            )

            bag += view.addArranged(button)

            bag += view.chainAllControlResponders()

            bag += button.onTapSignal.onValue { _ in
                complete()
            }

            return bag
        })
    }
}
