import Combine
import Contracts
import CrossSell
import EditCoInsured
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
                if let recommended = crossSells.recommended {
                    if crossSells.others.isEmpty {
                        self?.navBarItems.isNewOfferPresentedCenter = recommended
                    } else {
                        self?.navBarItems.isNewOfferPresentedModal = crossSells
                    }
                } else {
                    self?.navBarItems.isNewOfferPresentedDetent = crossSells
                }

                crossSellInfo.logCrossSellEvent()

                if let recommended = crossSells.recommended {
                    let store: CrossSellStore = globalPresentableStoreContainer.get()
                    store.send(.setHasSeenRecommendedWith(id: recommended.id))
                }
            }
        }
    }

    public var router = NavigationRouter()

    @Published public var isSubmitClaimPresented = false
    @Published public var claimsAutomationStartInput: StartClaimInput?
    @Published public var isHelpCenterPresented = false

    @Published public var navBarItems = NavBarItems()

    @Published public var openChat: ChatConversation?
    @Published public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isFirstVetPresented = false
        public var isNewOfferPresentedModal: CrossSells?
        public var isNewOfferPresentedCenter: CrossSell?
        public var isNewOfferPresentedDetent: CrossSells?
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var connectPaymentVm = ConnectPaymentViewModel()
    public var editCoInsuredVm = EditCoInsuredViewModel(
        existingCoInsured: globalPresentableStoreContainer.get(of: ContractStore.self)
    )
    public var pushToProfile: (() -> Void)?
}
