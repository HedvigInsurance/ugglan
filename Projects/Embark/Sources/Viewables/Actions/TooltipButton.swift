//
//  TooltipButton.swift
//  Embark
//
//  Created by sam on 19.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import UIKit
import Flow

struct TooltipButton {
    let state: EmbarkState
}

extension TooltipButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UILabel(value: "fishes", style: .brand(.body(color: .primary)))
        let bag = DisposeBag()
        
        
        
        return (view, bag)
    }
}
