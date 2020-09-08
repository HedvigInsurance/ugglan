//
//  UIView+ShouldPerformEntryAnimation.swift
//  hCore
//
//  Created by sam on 27.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIView {
    public var safeToPerformEntryAnimationSignal: ReadSignal<Bool> {
        combineLatest(hasWindowSignal, ApplicationContext.shared.$hasFinishedBootstrapping).map { hasWindow, hasBootstrapped in hasWindow && hasBootstrapped }
    }
}
