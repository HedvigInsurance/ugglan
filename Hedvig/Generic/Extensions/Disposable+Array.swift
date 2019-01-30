//
//  Disposable+Array.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-24.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

public func += (disposeBag: DisposeBag, disposableArray: [Disposable]) {
    disposableArray.forEach { disposeBag.add($0) }
}
