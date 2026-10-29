import Addons
import AppStateContainer
import Combine
import Contracts
import CrossSell
import EditStakeholders
import Foundation
import Payment
import SubmitClaimChat
import SwiftUI
import hCore
import hCoreUI

public struct ChatConversation: Equatable, Identifiable, Sendable {
    public var id: String?
    public var chatType: ChatType
}

@MainActor
@Observable
public class HomeNavigationViewModel {
    public static var isChatPresented = false

    public init() {
        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            [weak self] notification in
            var openChat: ChatConversation?

            if let chatType = notification.object as? ChatType {
                openChat = .init(chatType: chatType)
            } else {
                openChat = .init(chatType: .inbox)
            }
            Task { @MainActor in
                self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]
                if self?.openChat == nil {
                    self?.openChat = openChat
                } else if self?.openChat != openChat {
                    self?.openChat = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                        self?.openChat = openChat
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: .openCrossSell, object: nil, queue: nil) {
            [weak self] notification in
            guard let crossSellInfo = notification.object as? CrossSellInfo else { return }

            Task { @MainActor in
                guard let crossSells = try? await crossSellInfo.getCrossSell() else { return }
                // A recommendation (insurance or addon) on its own uses the centered presentation;
                // combined with other cross-sells it uses the modal, and other-sells-only uses the detent.
                // A response with nothing to show does not present a sheet at all.
                if let recommended = crossSells.recommended, crossSells.others.isEmpty {
                    self?.navBarItems.isNewOfferPresentedCenter = recommended
                } else if crossSells.recommended != nil {
                    self?.navBarItems.isNewOfferPresentedModal = crossSells
                } else if !crossSells.others.isEmpty {
                    self?.navBarItems.isNewOfferPresentedDetent = crossSells
                }

                if let recommended = crossSells.recommended {
                    let store: CrossSellStore = globalAppStateContainer.get()
                    store.setHasSeenRecommendedWith(id: recommended.id)
                }
                await delay(1)
                crossSellInfo.logCrossSellEvent()
            }
        }
    }

    public func presentUpcomingPayment() async {
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        await paymentStore.load(forceUpdate: true)
        if let error = paymentStore.loadPaymentDataError {
            Toasts.shared.displayToastBar(toast: .init(type: .error, text: error))
        } else if let upcomingPayment = paymentStore.paymentData {
            isUpcomingPaymentPresented = upcomingPayment
        } else {
            Toasts.shared.displayToastBar(toast: .init(type: .info, text: L10n.paymentsNoPaymentsInProgress))
        }
    }

    @ObservationIgnored public var router = NavigationRouter()
    public let quickActionsVm = QuickActionsViewModel()

    public var claimsAutomationStartInput: StartClaimInput?
    public var isAddonPresented: ChangeAddonInput?
    public var isHelpCenterPresented = false
    public var isPayoutMethodPresented = false
    public var isAddPaymentMethodPresented = false
    public var isPaymentMethodsPresented = false
    public var payinSetupProvider: PaymentProvider?
    public var isForeverPresented = false
    public var isUpcomingPaymentPresented: PaymentData?

    public var navBarItems = NavBarItems()

    public var openChat: ChatConversation?
    public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isNewOfferPresentedModal: CrossSells?
        public var isNewOfferPresentedCenter: RecommendedCrossSell?
        public var isNewOfferPresentedDetent: CrossSells?
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @ObservationIgnored public var editStakeholdersVm = EditStakeholdersViewModel(
        existingStakeholders: globalAppStateContainer.get(ContractStore.self)
    )
}
