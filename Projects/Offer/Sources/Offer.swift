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

public enum OfferResult {
    case signed(ids: [String], startDates: [String: Date?])
    case signedQuoteCart(accessToken: String, startDates: [String: Date?])
    case close
    case chat
    case menu(_ action: MenuChildAction)
}
