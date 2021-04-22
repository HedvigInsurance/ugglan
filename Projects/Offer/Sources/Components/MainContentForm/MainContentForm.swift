//
//  MainContentForm.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-20.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct MainContentForm {
    let scrollView: UIScrollView
}

extension MainContentForm: Presentable {
    func materialize() -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let container = PassTroughStackView()
        container.axis = .vertical
        container.alignment = .leading
        container.allowTouchesOfViewsOutsideBounds = true
        
        let formContainer = UIStackView()
        formContainer.axis = .vertical
        formContainer.edgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        formContainer.insetsLayoutMarginsFromSafeArea = true
        container.addArrangedSubview(formContainer)
        
        let form = FormView()
        form.dynamicStyle = DynamicFormStyle { _ in
            .init(insets: .zero)
        }
        form.layer.cornerRadius = .defaultCornerRadius
        form.backgroundColor = .brand(.secondaryBackground())
        formContainer.addArrangedSubview(form)
        
        bag += form.append(DetailsSection())
        
        form.appendSpacing(.inbetween)
        
        bag += form.append(CoverageSection())
        
        form.appendSpacing(.inbetween)
        
        bag += merge(
            scrollView.didLayoutSignal,
            container.didLayoutSignal,
            formContainer.didLayoutSignal,
            form.didLayoutSignal,
            scrollView.didScrollSignal
        ).onValue {
            let bottomContentInset: CGFloat = scrollView.safeAreaInsets.bottom + 20
            
            if container.frame.width > Header.trailingAlignmentBreakpoint {
                formContainer.snp.remakeConstraints { make in
                    make.width.equalTo(container.frame.width - (container.frame.width * Header.trailingAlignmentFormPercentageWidth))
                }
                
                let pointInScrollView = scrollView.convert(formContainer.frameWithoutTransform, from: container)
                let transformY = -(pointInScrollView.origin.y - scrollView.safeAreaInsets.top - Header.insetTop)
                
                formContainer.transform = CGAffineTransform(translationX: 0, y: transformY)
                scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: transformY + bottomContentInset, right: 0)
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: transformY + bottomContentInset, right: 0)
                
                let extraInsetLeft: CGFloat = scrollView.safeAreaInsets.left > 0 ? 0 : 15
                
                formContainer.layoutMargins = UIEdgeInsets(top: 0, left: 15 + extraInsetLeft, bottom: 0, right: 15)
            } else {
                formContainer.snp.remakeConstraints { make in
                    make.width.equalToSuperview()
                }
                formContainer.transform = CGAffineTransform.identity
                scrollView.scrollIndicatorInsets = .zero
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomContentInset, right: 0)
                formContainer.layoutMargins = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
            }
            
            scrollView.layoutIfNeeded()
        }
                
        return (container, bag)
    }
}
