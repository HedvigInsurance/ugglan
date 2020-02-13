//
//  KeyGearListButton.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-12.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

struct KeyGearListButton {
    var title: String
//    let selectedSignal: ReadWriteSignal<Bool> = .static(false)
}

extension KeyGearListButton: Reusable {
    static func makeAndConfigure() -> (make: UIControl, configure: (KeyGearListButton) -> Disposable) {
        let control = UIControl()
        let titleLabel = UILabel()
        control.addSubview(titleLabel)
        control.backgroundColor = .orange
        
        return (control, {KeyGearListButton in
            titleLabel.text = KeyGearListButton.title
            
            return NilDisposer()
        } )
    }
}
