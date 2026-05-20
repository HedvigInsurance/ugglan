import SwiftUI
import hCore
import hCoreUI

public struct PayinChangeMethodNavigation: View {
    @StateObject private var router = NavigationRouter()
    @EnvironmentObject private var paymentsNavigationVm: PaymentsNavigationViewModel

    public init() {}
    public var body: some View {
        hNavigationStack(router: router, tracking: PayinRouterActions.changePayinMethod) {
            PayinChangeMethodScreen()
                .navigationTitle("Choose payin method")  //L10n.payinSelectPayinMethod
                .withDismissButton()
        }
    }
}

enum PayinRouterActions: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case selectedPayinMethod
    case changePayinMethod

    var nameForTracking: String {
        switch self {
        case .selectedPayinMethod:
            return String(describing: PayinSelectedMethodScreen.self)
        case .changePayinMethod:
            return String(describing: PayinChangeMethodScreen.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .selectedPayinMethod:
            return "Payin account"  //L10n.payinPageHeading
        case .changePayinMethod:
            return "Choose payin method"  //L10n.payinSelectPayinMethod
        }
    }
}
