//
//  DebugStore.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-08-17.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Flow

public struct DebugState: StateProtocol {
    public init() {}
}

public enum DebugAction: ActionProtocol {
    case openOffer(fullscreen: Bool, prefersLargeTitles: Bool)
    case openDataCollection

    #if compiler(<5.5)
        public func encode(to encoder: Encoder) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }

        public init(
            from decoder: Decoder
        ) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }
    #endif
}

public final class DebugStore: StateStore<DebugState, DebugAction> {
    public override func effects(
        _ getState: () -> DebugState,
        _ action: DebugAction
    ) -> FiniteSignal<DebugAction>? {
        return nil
    }

    public override func reduce(_ state: DebugState, _ action: DebugAction) -> DebugState {
        return state
    }
}

