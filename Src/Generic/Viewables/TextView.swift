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
    let value: ReadWriteSignal<String>
    let placeholder: ReadWriteSignal<String>
    let enabledSignal: ReadWriteSignal<Bool>
    let shouldReturn = Delegate<(String, UITextField), Bool>()

    private let didBeginEditingCallbacker: Callbacker<Void> = Callbacker()

    var didBeginEditingSignal: Signal<Void> {
        return didBeginEditingCallbacker.providedSignal
    }

    init(value: String, placeholder: String, enabled: Bool = true) {
        self.value = ReadWriteSignal(value)
        self.placeholder = ReadWriteSignal(placeholder)
        enabledSignal = ReadWriteSignal(enabled)
    }
}

extension UITextView: SignalProvider {
    public var providedSignal: ReadWriteSignal<String> {
        return Signal { callback in
            let bag = DisposeBag()

            bag += NotificationCenter.default.signal(forName: UITextView.textDidChangeNotification, object: self).onValue({ _ in
                callback(self.text)
            })

            return bag
        }.readable(initial: text ?? "").writable(setValue: { newValue in
            self.text = newValue
        })
    }

    public var didBeginEditingSignal: Signal<Void> {
        return NotificationCenter.default.signal(forName: UITextView.textDidBeginEditingNotification, object: self).toVoid()
    }
}

extension TextView: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIControl()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        view.isUserInteractionEnabled = true

        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.borderColor = UIColor.lightGray.cgColor
        bag += view.didLayoutSignal.onValue { _ in
            view.layer.cornerRadius = min(view.frame.height / 2, 20)
        }

        let paddingView = UIStackView()
        paddingView.isUserInteractionEnabled = true
        paddingView.axis = .vertical
        paddingView.isLayoutMarginsRelativeArrangement = true
        paddingView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 3)
        view.addSubview(paddingView)

        paddingView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        let textView = UITextView()
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.font = HedvigFonts.circularStdBook?.withSize(14)
        textView.backgroundColor = .clear
        bag += value.atOnce().bidirectionallyBindTo(textView)

        textView.snp.remakeConstraints { make in
            make.height.equalTo(34)
        }

        view.snp.makeConstraints({ make in
            make.height.equalTo(40)
        })

        bag += textView.didBeginEditingSignal.onValue({ _ in
            self.didBeginEditingCallbacker.callAll()
        })

        bag += merge(
            textView.toVoid(),
            value.toVoid()
        ).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            let numberOfLines = textView.value.components(separatedBy: "\n").count
            let contentHeight = min(120, numberOfLines * 34)

            textView.snp.remakeConstraints { make in
                make.height.equalTo(contentHeight)
            }

            view.snp.remakeConstraints({ make in
                make.height.equalTo(contentHeight + 6)
            })

            textView.layoutSuperviewsIfNeeded()
            textView.contentOffset = CGPoint(x: 0, y: contentHeight - 34)
        }

        paddingView.addArrangedSubview(textView)

        let placeholderLabel = UILabel(value: "Aa", style: TextStyle.body.colored(.darkGray).resized(to: 14))
        paddingView.addSubview(placeholderLabel)

        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(paddingView.layoutMargins.left + 5)
            make.centerY.equalToSuperview().offset(2)
            make.width.equalToSuperview()
        }

        bag += textView.onValue { value in
            placeholderLabel.alpha = value.isEmpty ? 1 : 0
        }

        bag += view.signal(for: .touchDown).filter { !textView.isFirstResponder }.onValue { _ in
            textView.becomeFirstResponder()
        }

        return (view, bag)
    }
}
