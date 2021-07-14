import Flow
import Foundation
import Presentation
import UIKit
import Hero
import hCore
import hCoreUI
import hGraphQL

typealias EmbarkAddressAutocompleteData = EmbarkPassage.Action.AsEmbarkAddressAutocompleteAction

struct EmbarkAddressAutocompleteAction {
    let state: EmbarkState
    let data: EmbarkAddressAutocompleteData

    var prefillValue: String {
        guard let value = state.store.getPrefillValue(key: data.addressAutocompleteActionData.key) else { return "" }

        return value
    }
}

extension EmbarkAddressAutocompleteAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        //let animator = ViewableAnimator(state: .notLoading, handler: self, views: AnimatorViews())
        //animator.register(key: \.view, value: view)

        let bag = DisposeBag()

        let box = UIControl()
        //box.backgroundColor = .brand(.secondaryBackground())
        box.backgroundColor = .brand(.primaryButtonBackgroundColor)
        box.layer.cornerRadius = 8
        bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }
        //animator.register(key: \.box, value: box)

        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        boxStack.isLayoutMarginsRelativeArrangement = true
        //animator.register(key: \.boxStack, value: boxStack)

        box.addSubview(boxStack)
        boxStack.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
        view.addArrangedSubview(box)

        let input = EmbarkInput(
            placeholder: data.addressAutocompleteActionData.placeholder,
            autocapitalisationType: .none,
            masking: Masking(type: .none),
            shouldAutoSize: true
        )
        let textSignal = boxStack.addArranged(input)
        boxStack.isUserInteractionEnabled = false
        //{ inputView in
            //animator.register(key: \.input, value: inputView)
        //}
        textSignal.value = prefillValue

        let button = Button(
            title: data.addressAutocompleteActionData.link.fragments.embarkLinkFragment.label,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )
        bag += view.addArranged(button)
            //{ buttonView in animator.register(key: \.button, value: buttonView) }

        bag += textSignal.atOnce().map { text in !text.isEmpty }
            .bindTo(button.isEnabled)

        return (
            view,
            Signal { callback in
                func complete(_ value: String) {
                    if let passageName = self.state.passageNameSignal.value {
                        self.state.store.setValue(key: "\(passageName)Result", value: value)
                    }

                    //let unmaskedValue = self.masking?.unmaskedValue(text: value) ?? value
                    self.state.store.setValue(
                        key: self.data.addressAutocompleteActionData.key,
                        value: value
                    )

                    self.state.store.createRevision()

                    if let apiFragment = self.data.addressAutocompleteActionData.api?.fragments.apiFragment {
                        bag += self.state.handleApi(apiFragment: apiFragment)
                            .onValue { link in guard let link = link else { return }
                                callback(link)
                            }
                    } else {
                        callback(self.data.addressAutocompleteActionData.link.fragments.embarkLinkFragment)
                    }
                }
                
                bag += box.signal(for: .touchUpInside).onValue { _ in
                    box.viewController?.present(
                        EmbarkAddressAutocomplete(state: self.state, data: self.data),
                        style: .address(view: box))
                    
                    // Set first responder to avoid keyboard dismissal
                    input.setIsFirstResponderSignal.value = true
                }
                
                // Also hack for not hiding keyboard during transition
                bag += NotificationCenter.default
                    .signal(forName: UIResponder.keyboardWillHideNotification)
                    .onValue { _ in
                        input.setIsFirstResponderSignal.value = true
                    }
                
                bag += input.shouldReturn.set { _ -> Bool in let innerBag = DisposeBag()
                    innerBag += textSignal.atOnce().take(first: 1)
                        .onValue { value in complete(value)
                            innerBag.dispose()
                        }
                    return true
                }

                bag += button.onTapSignal.withLatestFrom(textSignal.atOnce().plain())
                    .onFirstValue { _, value in complete(value) }

                return bag
            }
        )
    }
}
