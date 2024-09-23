import Chat
import Combine
import Contracts
import EditCoInsuredShared
import Foundation
import Payment
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

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

        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: OperationQueue.main) {
            [weak self] notification in
            var openChat: ChatConversation?
            self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]

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
                // fallback on inbox view
                openChat = .init(chatType: .inbox)
            }

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
        public var type: FileUrlModelType

        public init(
            type: FileUrlModelType
        ) {
            self.type = type
        }

        public enum FileUrlModelType: Codable, Equatable {
            case url(url: URL)
            case data(data: Data, mimeType: MimeType)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var connectPaymentVm = ConnectPaymentViewModel()
    public var editCoInsuredVm = EditCoInsuredViewModel(
        existingCoInsured: globalPresentableStoreContainer.get(of: ContractStore.self)
    )
}

extension HomeNavigationViewModel.FileUrlModel.FileUrlModelType {
    public var asDocumentPreviewModelType: DocumentPreviewModel.DocumentPreviewType {
        switch self {
        case .url(let url):
            return .url(url: url)
        case .data(let data, let mimeType):
            return .data(data: data, mimeType: mimeType)
        }
    }
}
