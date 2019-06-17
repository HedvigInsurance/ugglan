//
//  TextField.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-14.
//

import Foundation
import UIKit
import Flow

struct TextField {}

extension TextField: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIControl()
        
        view.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        bag += view.didLayoutSignal.onValue { _ in
            view.layer.cornerRadius = view.frame.height / 2
        }
        
        let paddingView = UIStackView()
        paddingView.isUserInteractionEnabled = false
        paddingView.axis = .vertical
        paddingView.isLayoutMarginsRelativeArrangement = true
        paddingView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 10)
        view.addSubview(paddingView)
        
        paddingView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }
        
        let textField = UITextField(value: "", placeholder: "Kod", style: .default)
        paddingView.addArrangedSubview(textField)
        
        bag += view.signal(for: .touchDown).onValue { _ in
            textField.becomeFirstResponder()
        }
        
        return (view, bag)
    }
}
