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
        let container = PassTroughStackView()
        container.axis = .vertical
        container.alignment = .leading
        container.allowTouchesOfViewsOutsideBounds = true
        
        let form = FormView()
        form.dynamicStyle = DynamicFormStyle { _ in
            .init(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }
        container.addArrangedSubview(form)
        let bag = DisposeBag()
        
        let section = form.appendSection()
        section.dynamicStyle = .brandGrouped(separatorType: .standard, backgroundColor: .brand(.secondaryBackground()))
        
        for _ in 0...100 {
            bag += section.appendRow(title: "test").onValue { _ in
                
            }
        }
        
        bag += merge(
            form.didLayoutSignal,
            form.traitCollectionSignal.plain().toVoid(),
            container.signal(for: \.bounds).plain().toVoid()
        ).onValue({ _ in
            if container.frame.width > Header.trailingAlignmentBreakpoint {
                form.snp.remakeConstraints { make in
                    make.width.equalTo(container.frame.width - (container.frame.width * Header.trailingAlignmentFormPercentageWidth))
                }
                
                let pointInScrollView = scrollView.convert(form.frameWithoutTransform, from: container)
                form.transform = CGAffineTransform(translationX: 0, y: -(pointInScrollView.origin.y - scrollView.safeAreaInsets.top - Header.insetTop))
            } else {
                form.snp.remakeConstraints { make in
                    make.width.equalToSuperview()
                }
                form.transform = CGAffineTransform.identity
            }
        })
                
        return (container, bag)
    }
}
