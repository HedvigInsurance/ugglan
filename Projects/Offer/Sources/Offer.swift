import Apollo
import Flow
import Form
import Foundation
import Presentation
import SafariServices
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public enum OfferOption {
    case menuToTrailing
    case shouldPreserveState
}

public struct Offer {
    let menu: hCore.Menu?
    let options: Set<OfferOption>

    public init(
        menu: hCore.Menu?,
        options: Set<OfferOption> = []
    ) {
        self.menu = menu
        self.options = options
    }
}

extension Offer {
    public func setIds(_ ids: [String]) -> Self {
        let store: OfferStore = globalPresentableStoreContainer.get()
        store.send(.setIds(ids: ids, selectedIds: ids))
        return self
    }

    public func setIds(_ ids: [String], selectedIds: [String]) -> Self {
        let store: OfferStore = globalPresentableStoreContainer.get()
        store.send(.setIds(ids: ids, selectedIds: selectedIds))
        return self
    }

    public func setQuoteCart(_ id: String, selectedInsuranceTypes: [String]) -> Self {
        let store: OfferStore = globalPresentableStoreContainer.get()
        store.send(.setQuoteCartId(id: id, insuranceTypes: selectedInsuranceTypes))
        return self
    }
}

public enum OfferResult {
    case signed(ids: [String], startDates: [String: Date?])
    case signedQuoteCart(accessToken: String, startDates: [String: Date?])
    case close
    case chat
    case menu(_ action: MenuChildAction)
}
