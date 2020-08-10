//
//  RowAndProviderTracked.swift
//  hCore
//
//  Created by sam on 25.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

public struct RowAndProviderTracking {
    public static var handler: (_ name: String) -> Void = { _ in }
}

extension RowAndProvider {
    public var trackedSignal: CoreSignal<Provider.Kind, Provider.Value> {
        providedSignal.atValue { _ in
            if let derivedFromL10N = self.row.accessibilityLabel?.derivedFromL10n {
                RowAndProviderTracking.handler("tap_\(derivedFromL10N.key)")
            }
        }
    }
}
