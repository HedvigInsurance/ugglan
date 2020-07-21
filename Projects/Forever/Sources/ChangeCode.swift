//
//  ChangeCode.swift
//  Forever
//
//  Created by sam on 15.7.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import Presentation
import Form
import UIKit
import hCore
import hCoreUI

struct ChangeCode {
    let service: ForeverService
    
    enum ResultError: Error {
        case cancelled
    }
}

extension FormView {
    enum SpacingType {
        case top
        case inbetween
        
        var height: CGFloat {
            switch self {
            case .top:
                return 40
            case .inbetween:
                return 16
            }
        }
    }
    
    func appendSpacing(_ type: SpacingType) {
        let view = UIView()
        
        view.snp.makeConstraints { make in
            make.height.equalTo(type.height)
        }
        
        append(view)
    }
}

extension ChangeCode: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let cancelBarButtonItem = UIBarButtonItem(title: L10n.NavBar.cancel, style: .brand(.body(color: .primary)))
        viewController.navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        let saveBarButtonItem = UIBarButtonItem(title: L10n.NavBar.save, style: .brand(.body(color: .link)))
        viewController.navigationItem.rightBarButtonItem = saveBarButtonItem
                
        let form = FormView()
        bag += viewController.install(form)
        
        form.appendSpacing(.top)
        form.append(L10n.ReferralsChangeCodeSheet.headline)
        form.appendSpacing(.inbetween)
        bag += form.append(
            MultilineLabel(
                value: L10n.ReferralsChangeCodeSheet.body,
                style: TextStyle.brand(.body(color: .tertiary)).centerAligned
            )
        )
        form.appendSpacing(.top)
        
        let textFieldSection = form.appendSection()
        let textFieldRow = textFieldSection.appendRow()
        
        let normalFieldStyle = FieldStyle.default.restyled({ (style: inout FieldStyle) in
            style.text.alignment = .center
        })
        
        let errorFieldStyle = normalFieldStyle.restyled { (style: inout FieldStyle) in
            style.text.color = .brand(.regularCaution)
        }
                
        let textField = UITextField(value: "", placeholder: L10n.ReferralsChangeCodeSheet.textFieldPlaceholder, style: normalFieldStyle)
        textFieldRow.append(textField)
        
        textField.becomeFirstResponder()
        
        let textFieldErrorSignal: ReadWriteSignal<ForeverChangeCodeError?> = ReadWriteSignal(nil).distinct()
        
        bag += textFieldErrorSignal.atOnce().map { error in
            if error != nil {
                return errorFieldStyle
            }
            
            return normalFieldStyle
        }.bindTo(animate: .easeOut(duration: 0.25), textField, \.style)
                        
        bag += textField.animated(style: .easeOut(duration: 0.25)) { _ in
            textFieldErrorSignal.value = nil
        }
        
        let errorMessageLabel = MultilineLabel(
            value: "",
            style: TextStyle.brand(.footnote(color: .destructive)).centerAligned
        )
        
        bag += textFieldErrorSignal
            .compactMap { $0?.localizedDescription }
            .bindTo(errorMessageLabel.valueSignal)
        
        form.appendSpacing(.inbetween)
        bag += form.append(errorMessageLabel) { errorMessageLabelView in
            func alphaAnimation(_ error: Error?) {
                errorMessageLabelView.alpha = error == nil ? 0 : 1
            }
            
            func isHiddenAnimation(_ error: Error?) {
                errorMessageLabelView.animationSafeIsHidden = error == nil
            }
            
            bag += textFieldErrorSignal.atOnce().animated(style: .easeOut(duration: 0.25)) { error in
                if error == nil {
                    alphaAnimation(error)
                } else {
                    isHiddenAnimation(error)
                }
            }.animated(style: .easeOut(duration: 0.25)) { error in
                if error == nil {
                    isHiddenAnimation(error)
                } else {
                    alphaAnimation(error)
                }
            }
        }
        
        func onSave() -> Signal<Void> {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            viewController.navigationItem.setRightBarButton(UIBarButtonItem(customView: activityIndicator), animated: true)
            
            return service.changeDiscountCode(textField.value).atValue { _ in
                viewController.navigationItem.setRightBarButton(saveBarButtonItem, animated: true)
                textFieldErrorSignal.value = .nonUnique
            }
            .filter(predicate: { $0.left != nil })
            .toVoid()
        }
        
        return (viewController, Future { completion in
            bag += cancelBarButtonItem.onValue {
                completion(.failure(ResultError.cancelled))
            }
            
            bag += textField.shouldReturn.set { _ -> Bool in
                bag += onSave().onValue {
                    completion(.success)
                }
                return true
            }
            
            bag += saveBarButtonItem.onValue {
                bag += onSave().onValue {
                    completion(.success)
                }
            }
            
            return bag
        })
    }
}
