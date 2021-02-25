import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

typealias EmbarkTextActionData = EmbarkPassage.Action.AsEmbarkTextAction

struct EmbarkTextAction {
    let state: EmbarkState
    let data: EmbarkTextActionData

    var masking: Masking? {
        if let mask = data.textActionData.mask,
           let maskType = MaskType(rawValue: mask)
        {
            return Masking(type: maskType)
        }

        return nil
    }
}

extension EmbarkTextAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        let animator = ViewableAnimator(state: .notLoading, handler: self, views: AnimatorViews())
        animator.register(key: \.view, value: view)

        let bag = DisposeBag()

        let box = UIView()
        box.backgroundColor = .brand(.secondaryBackground())
        box.layer.cornerRadius = 8
        bag += box.applyShadow { _ -> UIView.ShadowProperties in
            .embark
        }
        animator.register(key: \.box, value: box)

        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        boxStack.isLayoutMarginsRelativeArrangement = true
        animator.register(key: \.boxStack, value: boxStack)

        box.addSubview(boxStack)
        boxStack.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
        view.addArrangedSubview(box)

        let input = EmbarkInput(
            placeholder: data.textActionData.placeholder,
            keyboardType: masking?.keyboardType,
            textContentType: masking?.textContentType,
            autocapitalisationType: masking?.autocapitalizationType ?? .none,
            masking: masking
        )
        let textSignal = boxStack.addArranged(input) { inputView in
            animator.register(key: \.input, value: inputView)
        }

        let button = Button(
            title: data.textActionData.link.fragments.embarkLinkFragment.label,
            type: .standard(backgroundColor: .black, textColor: .white)
        )
        bag += view.addArranged(button) { buttonView in
            animator.register(key: \.button, value: buttonView)
        }
        
        bag += textSignal
            .map { text in text.count > 0 }
            .bindTo(button.isEnabled)

        return (view, Signal { callback in
            func complete(_ value: String) {
                if let passageName = self.state.passageNameSignal.value {
                    self.state.store.setValue(
                        key: "\(passageName)Result",
                        value: value
                    )
                }

                let unmaskedValue = self.masking?.unmaskedValue(text: value) ?? value
                self.state.store.setValue(
                    key: self.data.textActionData.key,
                    value: unmaskedValue
                )

                if let derivedValues = self.masking?.derivedValues(text: value) {
                    derivedValues.forEach { key, value in
                        self.state.store.setValue(
                            key: "\(self.data.textActionData.key)\(key)",
                            value: value
                        )
                    }
                }

                self.state.store.createRevision()

                if let apiFragment = self.data.textActionData.api?.fragments.apiFragment {
                    bag += animator.setState(.loading)
                        .filter(predicate: { $0 })
                        .mapLatestToFuture { _ in self.state.handleApi(apiFragment: apiFragment) }
                        .onValue { link in
                            guard let link = link else {
                                return
                            }
                            callback(link)
                        }
                } else {
                    callback(self.data.textActionData.link.fragments.embarkLinkFragment)
                }
            }

            bag += input.shouldReturn.set { _ -> Bool in
                let innerBag = DisposeBag()
                innerBag += textSignal.atOnce().take(first: 1).onValue { value in
                    complete(value)
                    innerBag.dispose()
                }
                return true
            }

            bag += button.onTapSignal.withLatestFrom(textSignal.plain()).onValue { _, value in
                let innerBag = DisposeBag()
                innerBag += textSignal.atOnce().take(first: 1).onValue { value in
                    complete(value)
                    innerBag.dispose()
                }
            }

            return bag
        })
    }
}
