import Combine
import Contracts
import CrossSell
import EditStakeholders
import Foundation
import Payment
import PresentableStore
import SubmitClaimChat
import SwiftUI
import hCore
import hCoreUI

public struct ChatConversation: Equatable, Identifiable, Sendable {
    public var id: String?
    public var chatType: ChatType
}

@MainActor
public class HomeNavigationViewModel: ObservableObject {
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
                let crossSells = try await crossSellInfo.getCrossSell()
                // The centered presentation only supports an insurance cross-sell today;
                // addon recommendations fall back to the detent until their UI is wired up.
                if let recommendedInsurance = crossSells.recommended, crossSells.others.isEmpty {
                    self?.navBarItems.isNewOfferPresentedCenter = recommendedInsurance
                } else if crossSells.recommended != nil {
                    self?.navBarItems.isNewOfferPresentedModal = crossSells
                } else {
                    self?.navBarItems.isNewOfferPresentedDetent = crossSells
                }

                if let recommended = crossSells.recommended {
                    let store: CrossSellStore = globalPresentableStoreContainer.get()
                    store.send(.setHasSeenRecommendedWith(id: recommended.id))
                }
                await delay(1)
                crossSellInfo.logCrossSellEvent()
            }
        }
    }

    public var router = NavigationRouter()

    @Published public var claimsAutomationStartInput: StartClaimInput?
    @Published public var isHelpCenterPresented = false
    @Published public var isPayoutMethodPresented = false

    @Published public var navBarItems = NavBarItems()

    @Published public var openChat: ChatConversation?
    @Published public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isFirstVetPresented = false
        public var isNewOfferPresentedModal: CrossSells?
        public var isNewOfferPresentedCenter: RecommendedCrossSell?
        public var isNewOfferPresentedDetent: CrossSells?
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var connectPaymentVm = ConnectPaymentViewModel()
    public var editStakeholdersVm = EditStakeholdersViewModel(
        existingStakeholders: globalPresentableStoreContainer.get(of: ContractStore.self)
    )
}
