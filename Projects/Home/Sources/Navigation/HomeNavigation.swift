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
            var openChat: ChatConversation?
            self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]
            if let conversation = notification.object as? Chat.Conversation {
                openChat = .init(
                    chatType: .conversationId(id: conversation.id)
                )
            } else if let id = notification.object as? String {
                openChat = .init(chatType: .conversationId(id: id))
            } else {
                openChat = .init(chatType: .newConversation)
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
        existingCoInsured: {
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            return contractStore
        }()
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
