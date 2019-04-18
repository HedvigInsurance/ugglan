//
//  CloseButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-18.
//

import Foundation
import Form
import Flow

struct CloseButton {}

extension CloseButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIControl, Disposable) {
        let button = UIControl()
        
        let icon = Icon(icon: Asset.close, iconWidth: 20)
        button.addSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        
        return (button, NilDisposer())
    }
}
