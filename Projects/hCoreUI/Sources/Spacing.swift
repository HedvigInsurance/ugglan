//
//  Spacing.swift
//  CoreUI
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit
import hCore

public struct Spacing {
    public init(height: Float) {
        self.height = height
    }
    
    public let height: Float
    public let isHiddenSignal = ReadWriteSignal<Bool>(false)
}

extension Spacing: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        view.snp.makeConstraints { make in
            make.height.equalTo(self.height).priority(.required)
        }

        view.layoutIfNeeded()

        bag += isHiddenSignal.bindTo(view, \.isHidden)

        return (view, bag)
    }
}
