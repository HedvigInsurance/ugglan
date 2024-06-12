import Contracts
import EditCoInsuredShared
import Foundation
import Payment
import SwiftUI
import hCore
import hCoreUI

extension String: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return self
    }
}

public class HomeNavigationViewModel: ObservableObject {
    public static var isChatPresented = false
    public init() {

        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            [weak self] notification in
            if Dependencies.featureFlags().isConversationBasedMessagesEnabled {
                self?.router.push("Chat")
            } else {
                if let topicWrapper = notification.object as? ChatTopicWrapper {
                    self?.openChatOptions =
                        topicWrapper.onTop ? [.alwaysOpenOnTop, .withoutGrabber] : [.withoutGrabber]
                    self?.openChat = topicWrapper
                } else {
                    self?.openChatOptions = [.alwaysOpenOnTop, .withoutGrabber]
                    self?.openChat = .init(topic: nil, onTop: false)
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

    @Published public var openChat: ChatTopicWrapper?
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
