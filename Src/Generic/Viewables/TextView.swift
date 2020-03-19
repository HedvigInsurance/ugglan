//
//  TextView.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-25.
//

import Flow
import Form
import Foundation
import UIKit

struct TextView {
    let placeholder: ReadWriteSignal<String>
    let keyboardTypeSignal: ReadWriteSignal<UIKeyboardType?>
    let textContentTypeSignal: ReadWriteSignal<UITextContentType?>
    let enabledSignal: ReadWriteSignal<Bool>
    let shouldReturn = Delegate<(String, UITextField), Bool>()
    let insets: UIEdgeInsets

    private let didBeginEditingCallbacker: Callbacker<Void> = Callbacker()

    var didBeginEditingSignal: Signal<Void> {
        return didBeginEditingCallbacker.providedSignal
    }

    init(
        placeholder: String,
        keyboardTypeSignal: UIKeyboardType? = nil,
        textContentType: UITextContentType? = nil,
        insets: UIEdgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 3),
        enabled: Bool = true
    ) {
        self.placeholder = ReadWriteSignal(placeholder)
        self.insets = insets
        self.keyboardTypeSignal = ReadWriteSignal(keyboardTypeSignal)
        textContentTypeSignal = ReadWriteSignal(textContentType)
        enabledSignal = ReadWriteSignal(enabled)
    }
}

extension UITextView: SignalProvider {
    public var providedSignal: ReadWriteSignal<String> {
        return Signal { callback in
            let bag = DisposeBag()

            bag += NotificationCenter.default.signal(forName: UITextView.textDidChangeNotification, object: self).onValue { _ in
                callback(self.text)
            }

            return bag
        }.readable(getValue: { () -> String in
            self.text
        }).writable(setValue: { newValue in
            self.text = newValue
        })
    }

    public var didBeginEditingSignal: Signal<Void> {
        return NotificationCenter.default.signal(forName: UITextView.textDidBeginEditingNotification, object: self).toVoid()
    }
}

extension TextView: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, ReadWriteSignal<String>) {
        let bag = DisposeBag()
        let view = UIControl()
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 6

        bag += view.traitCollectionSignal.atOnce().onValue { trait in
            if trait.userInterfaceStyle == .dark {
                view.backgroundColor = UIColor.secondaryBackground
            } else {
                view.backgroundColor = UIColor.darkGray.lighter(amount: 0.3)
            }
        }

        view.layer.borderWidth = UIScreen.main.hairlineWidth
        bag += view.applyBorderColor { trait in
            trait.userInterfaceStyle == .dark ? .offBlack : .lightGray
        }

        let paddingView = UIStackView()
        paddingView.isUserInteractionEnabled = true
        paddingView.axis = .vertical
        paddingView.isLayoutMarginsRelativeArrangement = true
        paddingView.layoutMargins = insets
        view.addSubview(paddingView)

        paddingView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let textView = UITextView()
        textView.tintColor = .primaryTintColor
        textView.font = HedvigFonts.favoritStdBook?.withSize(14)
        textView.backgroundColor = .clear

        bag += combineLatest(textContentTypeSignal.atOnce(), keyboardTypeSignal.atOnce()).bindTo { (textContentType: UITextContentType?, keyboardType: UIKeyboardType?) in
            textView.textContentType = textContentType
            textView.keyboardType = keyboardType ?? .default
            textView.reloadInputViews()
        }

        textView.snp.remakeConstraints { make in
            make.height.equalTo(34)
        }

        view.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        bag += textView.didBeginEditingSignal.onValue { _ in
            self.didBeginEditingCallbacker.callAll()
        }

        let contentHeightSignal = ReadWriteSignal<CGFloat>(0)

        bag += textView.contentSizeSignal.animated(style: SpringAnimationStyle.lightBounce()) { size in
            let cappedContentHeight = min(120, size.height)

            textView.snp.remakeConstraints { make in
                make.height.equalTo(cappedContentHeight)
            }

            view.snp.remakeConstraints { make in
                make.height.equalTo(cappedContentHeight + 6)
            }

            textView.layoutIfNeeded()
            textView.layoutSuperviewsIfNeeded()

            if textView.contentSize.height != contentHeightSignal.value {
                textView.scrollToBottom(animated: false)
            }

            contentHeightSignal.value = size.height
        }

        paddingView.addArrangedSubview(textView)

        let placeholderLabel = UILabel(value: placeholder.value, style: TextStyle.body.colored(.darkGray).resized(to: 14))
        paddingView.addSubview(placeholderLabel)

        bag += placeholder.map { Optional($0) }.bindTo(
            transition: placeholderLabel,
            style: .crossDissolve(duration: 0.25),
            placeholderLabel,
            \.text
        )

        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(paddingView.layoutMargins.left + 5)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview()
        }

        bag += textView.atOnce().onValue { value in
            placeholderLabel.alpha = value.isEmpty ? 1 : 0
        }

        bag += view.signal(for: .touchDown).filter { !textView.isFirstResponder }.onValue { _ in
            textView.becomeFirstResponder()
        }

        return (view, Signal { callback in
            bag += textView.providedSignal.onValue { value in
                callback(value)
            }

            return bag
        }.readable(getValue: { textView.value }).writable(setValue: { newValue in
            placeholderLabel.alpha = newValue.isEmpty ? 1 : 0
            textView.value = newValue
        }))
    }
}
