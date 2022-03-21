import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

internal typealias EmbarkNumberActionData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action
    .AsEmbarkNumberAction.NumberActionDatum

struct EmbarkNumberAction {
    internal init(
        state: EmbarkState,
        data: EmbarkNumberActionData,
        style: FieldStyle = .embarkInputLarge
    ) {
        self.state = state
        self.data = data
        self.style = style
    }

    let state: EmbarkState
    let data: EmbarkNumberActionData
    let style: FieldStyle

    private func isInRange(number: Int?) -> Bool {
        guard let number = number else {
            return false
        }

        if let minValue = data.minValue, number < minValue {
            return false
        }

        if let maxValue = data.maxValue, number > maxValue {
            return false
        }

        return true
    }
}

extension EmbarkNumberAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10

        let box = UIView()
        box.backgroundColor = .brand(.secondaryBackground())
        box.layer.cornerRadius = 10
        bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }

        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        return (
            view,
            Signal { callback in
                func handleSubmit(textValue: String) {
                    let key = self.data.key
                    self.state.store.setValue(key: key, value: textValue)
                    if let passageName = self.state.passageNameSignal.value {
                        self.state.store.setValue(key: "\(passageName)Result", value: textValue)
                    }
                    callback(self.data.link.fragments.embarkLinkFragment)
                }

                let masking = Masking(type: .digits)
                let textField = EmbarkInput(
                    placeholder: self.data.placeholder,
                    keyboardType: masking.keyboardType,
                    textContentType: masking.textContentType,
                    autocapitalisationType: masking.autocapitalizationType,
                    masking: masking,
                    fieldStyle: self.style
                )
                let (textInputView, textSignal) = textField.materialize(events: events)
                textSignal.value = masking.maskValueFromStore(
                    text: state.store.getPrefillValue(key: data.key) ?? ""
                )
                boxStack.addArrangedSubview(textInputView)

                let isValidSignal = textSignal.atOnce()
                    .map { text in
                        !text.isEmpty && masking.isValid(text: text)
                            && self.isInRange(number: Int(masking.unmaskedValue(text: text)))
                    }

                bag += textField.shouldReturn.set { value -> Bool in
                    if isValidSignal.value { handleSubmit(textValue: value) }
                    return true
                }

                if let unit = self.data.unit {
                    let unitLabel = MultilineLabel(
                        value: unit,
                        style: TextStyle.brand(.body(color: .primary)).centerAligned
                    )
                    bag += boxStack.addArranged(unitLabel)
                }

                box.addSubview(boxStack)
                boxStack.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }

                view.addArrangedSubview(box)

                let button = Button(
                    title: self.data.link.fragments.embarkLinkFragment.label,
                    type: .standard(
                        backgroundColor: .brand(.secondaryButtonBackgroundColor),
                        textColor: .brand(.secondaryButtonTextColor)
                    )
                )

                bag += isValidSignal.bindTo(button.isEnabled)

                bag += view.addArranged(button)

                bag += button.onTapSignal.withLatestFrom(textSignal.atOnce().plain())
                    .onFirstValue { _, textValue in handleSubmit(textValue: textValue) }

                return bag
            }
        )
    }
}
