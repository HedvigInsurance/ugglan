//
//  KeyGearCategoryButton.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-07.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

struct KeyGearCategoryButton {
    let title: String
    let selectedSignal: ReadWriteSignal<Bool> = .static(false)
}


extension KeyGearCategoryButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.layer.cornerRadius = 8
        control.layer.borderWidth = 1
        control.layer.borderColor = UIColor.lightGray.cgColor
        control.layer.backgroundColor = UIColor.lightGray.cgColor

        let titleLabel = UILabel(value: title, style: .draggableOverlayDescription)
        control.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-24)
            make.centerX.centerY.equalToSuperview()
        }
        
        let touchUpInside = control.signal(for: .touchUpInside)
        bag += touchUpInside.feedback(type: .impactLight)
        
        bag += selectedSignal.atOnce().onValue { selected in
            if selected {
                titleLabel.textColor = .purple
                control.layer.borderColor = UIColor.purple.cgColor

            } else {
                titleLabel.textColor = .darkGray
                control.layer.borderColor = UIColor.lightGray.cgColor

            }
            
        }
        
        return (control, control.signal(for: .touchUpInside).hold(bag))
    }
}
