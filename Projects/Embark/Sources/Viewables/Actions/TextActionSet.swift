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
                autocapitalisationType: masking?.autocapitalizationType ?? .none,
                masking: masking,
                shouldAutoFocus: index == 0,
                fieldStyle: .embarkInputSmall
            )
            
            let endIndex = (data.textActionSetData?.textActions.endIndex ?? 1)
            let isLastAction: Bool = index == endIndex - 1
            
            let label = UILabel(value: textAction.data?.title ?? "", style: .brand(.body(color: .primary)))
            
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .equalSpacing
            
            stack.addArrangedSubview(label)
            
            boxStack.addArrangedSubview(stack)
            
            if !isLastAction && endIndex > 0 {
                let divider = Divider(backgroundColor: .brand(.primaryBorderColor))
                bag += boxStack.addArranged(divider)
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
            boxStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            view.addArrangedSubview(containerView)
            
            let button = Button(
                title: data.textActionSetData?.link.label ?? "",
                type: .standard(backgroundColor: .black, textColor: .white),
                isEnabled: false
            )

            bag += view.addArranged(button)
            
            func isValid(signal: ReadWriteSignal<String>, action: TextAction) -> Signal<Bool> {
                signal.map { text in
                    return text.count > 0
                }.plain()
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
                
                bag += combineLatest(textActions.map { signal, _, action in isValid(signal: signal, action: action) })
                    .map {
                    !$0.contains(false)
                }.bindTo(button.isEnabled)
            }
            
            bag += containerView.applyShadow({ (_) -> UIView.ShadowProperties in
                .embark
            })
        
            bag += view.chainAllControlResponders()

            bag += button.onTapSignal.onValue { _ in
                complete()
            }

            return bag
        })
    }
}
