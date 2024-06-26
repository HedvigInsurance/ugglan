import Chat
import Combine
import Contracts
import EditCoInsuredShared
import Foundation
import Payment
import Presentation
import SwiftUI
import hCore
import hCoreUI

extension String: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return self
    }
}

public struct ChatConversation: Equatable, Identifiable {
    public var id: String?
    public var chatType: ChatType
}

public class HomeNavigationViewModel: ObservableObject {
    public static var isChatPresented = false
    private var cancellables = Set<AnyCancellable>()

    public init() {

        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            [weak self] notification in
            if Dependencies.featureFlags().isConversationBasedMessagesEnabled {
                self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]
                if let conversation = notification.object as? Chat.Conversation {
                    self?.openChat = .init(
                        chatType: .conversation(conversationId: conversation.id, title: conversation.title)
                    )
                } else if let id = notification.object as? String {
                    self?.openChat = .init(chatType: .conversationId(id: id))
                } else {
                    self?.openChat = .init(chatType: .newConversation)
                }
            } else {
                if let topicWrapper = notification.object as? ChatTopicWrapper, let topic = topicWrapper.topic {
                    self?.openChat = .init(chatType: .topic(topic: topic))
                } else {
                    self?.openChat = .init(chatType: .none)
                }
            }
        }

        let store: ChatStore = globalPresentableStoreContainer.get()
        store.stateSignal.plain()
            .publisher
            .map({ $0.messagesTimeStamp })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { value in
                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                homeStore.send(.setChatNotificationTimeStamp(sentAt: value))
            }
            .store(in: &cancellables)

        store.stateSignal.plain()
            .publisher
            .map({ $0.conversationsTimeStamp })
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { value in
                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                if let latestDate = value.values.max() {
                    homeStore.send(.setChatNotificationTimeStamp(sentAt: latestDate))
                }
            }
            .store(in: &cancellables)
    }

    public var router = Router()

    @Published public var isSubmitClaimPresented = false
    @Published public var isHelpCenterPresented = false

    //claim details
    @Published public var document: InsuranceTerm? = nil

    @Published public var navBarItems = NavBarItems()

    @Published public var openChat: ChatConversation?
    @Published public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isFirstVetPresented = false
        public var isNewOfferPresented = false
    }

    public struct FileUrlModel: Identifiable, Equatable {
        public var id: String?
        public var url: URL

        public init(
            url: URL
        ) {
            self.url = url
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var connectPaymentVm = ConnectPaymentViewModel()
    public var editCoInsuredVm = EditCoInsuredViewModel()
}
