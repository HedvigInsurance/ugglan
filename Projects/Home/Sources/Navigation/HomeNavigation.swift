import Chat
import Combine
import Contracts
import CrossSell
import EditCoInsuredShared
import Foundation
import Payment
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension String: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        return self
    }
}

public struct ChatConversation: Equatable, Identifiable, Sendable {
    public var id: String?
    public var chatType: ChatType
}

@MainActor
public class HomeNavigationViewModel: ObservableObject {
    public static var isChatPresented = false
    private var didShowCrossSellAfterSuccessFlow = false
    private var cancellables = Set<AnyCancellable>()
    public init() {

        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            [weak self] notification in

            var openChat: ChatConversation?

            if let chatType = notification.object as? ChatType {
                switch chatType {
                case let .conversationId(conversationId):
                    openChat = .init(chatType: .conversationId(id: conversationId))
                case .newConversation:
                    openChat = .init(chatType: .newConversation)
                case .inbox:
                    openChat = .init(chatType: .inbox)
                }
            } else {
                openChat = .init(chatType: .inbox)
            }
            Task { @MainActor in
                self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]
                if self?.openChat == nil {
                    self?.openChat = openChat
                } else if self?.openChat != openChat {
                    self?.openChat = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self?.openChat = openChat
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: .openCrossSell, object: nil, queue: nil) {
            [weak self] notification in
            if let crossSellInfo = notification.object as? CrossSellInfo {
                Task { @MainActor in
                    let typesForWhichWeShouldShowAlways = [
                        CrossSellInfo.CrossSellInfoType.closedClaim, CrossSellInfo.CrossSellInfoType.home,
                    ]
                    if self?.didShowCrossSellAfterSuccessFlow == false
                        || typesForWhichWeShouldShowAlways.contains(crossSellInfo.type)
                    {
                        try await Task.sleep(nanoseconds: crossSellInfo.type.delayInNanoSeconds)
                        if crossSellInfo.type != CrossSellInfo.CrossSellInfoType.home {
                            self?.didShowCrossSellAfterSuccessFlow = true
                        }
                        self?.navBarItems.isNewOfferPresented = crossSellInfo
                    }
                }
            }
        }

    }

    public var router = Router()

    @Published public var isSubmitClaimPresented = false
    @Published public var isHelpCenterPresented = false

    @Published public var navBarItems = NavBarItems()

    @Published public var openChat: ChatConversation?
    @Published public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isFirstVetPresented = false
        public var isNewOfferPresented: CrossSellInfo?
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var connectPaymentVm = ConnectPaymentViewModel()
    public var editCoInsuredVm = EditCoInsuredViewModel(
        existingCoInsured: globalPresentableStoreContainer.get(of: ContractStore.self)
    )
}
