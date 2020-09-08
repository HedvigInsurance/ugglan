//
//  ApplicationContext.swift
//  hCore
//
//  Created by sam on 27.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

public struct ApplicationContext {
    public static var shared = ApplicationContext()
    @ReadWriteState public var hasFinishedBootstrapping = false
}
