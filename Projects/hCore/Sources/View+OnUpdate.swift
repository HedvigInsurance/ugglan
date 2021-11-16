//
//  View+OnUpdate.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-11-16.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension View {
    @ViewBuilder public func onUpdate<Value: Equatable>(
        of value: Value,
        perform: @escaping (_ newValue: Value) -> Void
    ) -> some View {
        if #available(iOS 14, *) {
            self.onChange(of: value) { newValue in
                perform(newValue)
            }
        } else {
            self.onReceive(Just(value)) { _ in
                perform(value)
            }
        }
    }
}
