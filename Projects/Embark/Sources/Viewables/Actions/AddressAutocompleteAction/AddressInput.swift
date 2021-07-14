import Flow
import Foundation
import Hero
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct AddressInput {
    let placeholder: String
    let textSignal: ReadWriteSignal<String> = ReadWriteSignal("")
    let setIsFirstResponderSignal = ReadWriteSignal<Bool>(true)
    let shouldReturn = Delegate<String, Bool>()
}

extension AddressInput: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        boxStack.isLayoutMarginsRelativeArrangement = true

        let input = EmbarkInput(
            placeholder: placeholder,
            autocapitalisationType: .none,
            masking: Masking(type: .none),
            shouldAutoSize: true
        )
        bag += boxStack.addArranged(input).bidirectionallyBindTo(textSignal)
        boxStack.isUserInteractionEnabled = false
        
        bag += input.shouldReturn.set { value -> Bool in self.shouldReturn.call(value) ?? false }
        
        bag += setIsFirstResponderSignal.bindTo(input.setIsFirstResponderSignal)

        return (boxStack, bag)
    }
}
