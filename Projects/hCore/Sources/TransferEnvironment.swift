//
//  TransferEnvironment.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-08-17.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

public struct TransferEnvironment: ViewModifier {
    var environment: EnvironmentValues
    
    public init(environment: EnvironmentValues) {
        self.environment = environment
    }

    public func body(content: Content) -> some View {
        return Group {
            content
        }
        .environment(\.self, environment)
    }
}
