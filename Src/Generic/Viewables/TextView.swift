//
//  TextView.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-25.
//

import Flow
import Foundation
import UIKit

struct TextView {
    let value: ReadWriteSignal<String>
    let placeholder: ReadWriteSignal<String>
    let enabledSignal: ReadWriteSignal<Bool>
    let shouldReturn = Delegate<(String, UITextField), Bool>()
    
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
}

extension TextView: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIControl()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        
        view.layer.borderWidth = 1
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
        bag += value.atOnce().bidirectionallyBindTo(textView)
        //bag += placeholder.atOnce().bindTo(textView, \.placeholder)
        //bag += enabledSignal.atOnce().bindTo(textView, \.isEnabled)
        
        textView.snp.remakeConstraints { make in
            make.height.equalTo(34)
        }
        
        view.snp.makeConstraints({ make in
            make.height.equalTo(40)
        })
        
        bag += textView.animated(style: SpringAnimationStyle.lightBounce()) { _ in
            let contentHeight = min(80, textView.contentSize.height)
            
            textView.snp.remakeConstraints { make in
                make.height.equalTo(contentHeight)
            }
            
            view.snp.remakeConstraints({ make in
                make.height.equalTo(contentHeight + 6)
            })
            
            textView.layoutSuperviewsIfNeeded()
            textView.contentOffset = CGPoint(x: 0, y: textView.contentSize.height - textView.bounds.size.height)
        }
        
        paddingView.addArrangedSubview(textView)
        
        bag += view.signal(for: .touchDown).filter { !textView.isFirstResponder }.onValue { _ in
            textView.becomeFirstResponder()
        }
        
        return (view, bag)
    }
}

