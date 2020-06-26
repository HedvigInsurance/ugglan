//
//  RowAndProviderTracked.swift
//  hCore
//
//  Created by sam on 25.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Form
import Flow

public struct RowAndProviderTracking {
    public static var handler: (_ name: String) -> Void = { _ in }
}

extension RowAndProvider {
    public var trackedSignal: CoreSignal<Provider.Kind, Provider.Value> {
        providedSignal.atValue { value in
            if let derivedFromL10N = self.row.accessibilityLabel?.derivedFromL10n {
                RowAndProviderTracking.handler("tap_\(derivedFromL10N.key)")
            }
        }
    }
}
