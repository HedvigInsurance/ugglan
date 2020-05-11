//
//  Disposable+Array.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

public func += (disposeBag: DisposeBag, disposableArray: [Disposable]) {
    disposableArray.forEach { disposeBag.add($0) }
}
