//
//  EmbarkInput.swift
//  Ugglan
//
//  Created by Axel Backlund on 2020-02-13.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import SnapKit
import UIKit

struct EmbarkInput {
    let placeholder: ReadWriteSignal<String>
    let keyboardTypeSignal: ReadWriteSignal<UIKeyboardType?>
    let textContentTypeSignal: ReadWriteSignal<UITextContentType?>
    let enabledSignal: ReadWriteSignal<Bool>
    let shouldReturn = Delegate<String, Bool>()
    let insets: UIEdgeInsets
    let masking: Masking?
    let shouldAutoFocus: Bool
    
    init(
        placeholder: String,
        keyboardType: UIKeyboardType? = nil,
        textContentType: UITextContentType? = nil,
        insets: UIEdgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 3),
        enabled: Bool = true,
        masking: Masking? = nil,
        shouldAutoFocus: Bool = true
    ) {
        self.placeholder = ReadWriteSignal(placeholder)
        self.insets = insets
        keyboardTypeSignal = ReadWriteSignal(keyboardType)
        textContentTypeSignal = ReadWriteSignal(textContentType)
        enabledSignal = ReadWriteSignal(enabled)
        self.masking = masking
        self.shouldAutoFocus = shouldAutoFocus
    }
}

extension EmbarkInput: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, ReadWriteSignal<String>) {
        let bag = DisposeBag()
        let view = UIControl()
        view.isUserInteractionEnabled = true

        let paddingView = UIStackView()
        paddingView.isUserInteractionEnabled = true
        paddingView.axis = .vertical
        paddingView.isLayoutMarginsRelativeArrangement = true
        paddingView.insetsLayoutMarginsFromSafeArea = false
        paddingView.layoutMargins = insets
        view.addSubview(paddingView)

        paddingView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let textField = UITextField()
        textField.textAlignment = .center
        textField.tintColor = .brand(.primaryTintColor)
        textField.font = Fonts.favoritStdBook.withSize(38)
        textField.backgroundColor = .clear
        textField.placeholder = placeholder.value

        bag += combineLatest(textContentTypeSignal.atOnce(), keyboardTypeSignal.atOnce()).bindTo { (textContentType: UITextContentType?, keyboardType: UIKeyboardType?) in
            textField.textContentType = textContentType
            textField.keyboardType = keyboardType ?? .default
            textField.reloadInputViews()
        }

        paddingView.addArrangedSubview(textField)

        let placeholderLabel = UILabel(value: placeholder.value, style: .brand(.largeTitle(color: .primary)))
        placeholderLabel.textAlignment = .center

        bag += textField.atOnce().onValue { value in
            placeholderLabel.alpha = value.isEmpty ? 1 : 0
        }

        bag += textField.didMoveToWindowSignal.delay(by: 0.5).filter(predicate: { self.shouldAutoFocus }).onValue { _ in
            textField.becomeFirstResponder()
        }

        bag += view.signal(for: .touchDown).filter { !textField.isFirstResponder }.onValue { _ in
            textField.becomeFirstResponder()
        }

        var oldText = ""
        bag += textField.distinct().onValue { textValue in
            if let mask = self.masking {
                let maskedValue = mask.maskValue(text: textValue, previousText: oldText)
                textField.value = maskedValue
                oldText = maskedValue
            }
        }

        bag += textField.shouldReturn.set { value -> Bool in
            self.shouldReturn.call(value) ?? false
        }

        return (view, Signal { callback in
            bag += textField.providedSignal.onValue { value in
                callback(value)
            }

            return bag
        }.readable(getValue: { textField.value }).writable(setValue: { newValue in
            placeholderLabel.alpha = newValue.isEmpty ? 1 : 0
            textField.value = newValue
        }))
    }
}
