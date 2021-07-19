//
//  UgglanStore.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-18.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Flow
import Apollo
import hCore
import hGraphQL
import Offer

public struct UgglanState: Codable {
    var selectedTabIndex = 0
    
    public enum Feature: Codable {
        case referrals
        case keyGear
    }
    
    var features: [Feature]? = nil
}

public enum UgglanAction {
    case setSelectedTabIndex(_ index: Int)
    case fetchFeatures
    case setFeatures(_ features: [UgglanState.Feature]?)
}

public final class UgglanStore: Store {
    @Inject var client: ApolloClient
    
    public var providedSignal: ReadWriteSignal<UgglanState>
    public var onAction = Callbacker<UgglanAction>()
    
    public func effects(_ state: UgglanState, _ action: UgglanAction) -> Future<UgglanAction>? {
        
        switch action {
        case .fetchFeatures:
            return client.fetch(
                query: GraphQL.FeaturesQuery(),
                cachePolicy: .fetchIgnoringCacheData
            )
            .compactMap { $0.member.features }
            .map { .setFeatures([UgglanState.Feature.referrals]) }
        default:
            break
        }
        
        return nil
    }
    
    public func reduce(_ state: UgglanState, _ action: UgglanAction) -> UgglanState {
        var newState = state
        
        switch action {
        case let .setSelectedTabIndex(tabIndex):
            newState.selectedTabIndex = tabIndex
        case let .setFeatures(features):
            newState.features = features
        default:
            break
        }
        
        return newState
    }
    
    public init() {
        self.providedSignal = ReadWriteSignal(
            Self.restore() ?? UgglanState()
        )
    }
}
