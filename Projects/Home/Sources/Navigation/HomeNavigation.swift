import Contracts
import EditCoInsuredShared
import Foundation
import Payment
import SwiftUI
import hCore
import hCoreUI

public class HomeNavigationViewModel: ObservableObject {
    public init() {

        NotificationCenter.default.addObserver(forName: .openChat, object: nil, queue: nil) {
            [weak self] notification in
            if let topicWrapper = notification.object as? ChatTopicWrapper {
                self?.openChatOptions = topicWrapper.onTop ? [.alwaysOpenOnTop] : []
                self?.openChat = topicWrapper
            } else {
                self?.openChatOptions = [.alwaysOpenOnTop]
                self?.openChat = .init(topic: nil, onTop: false)
            }
        }
    }

    @Published public var isSubmitClaimPresented = false
    @Published public var isHelpCenterPresented = false
    @Published public var isMissingEditCoInsuredAlertPresented: InsuredPeopleConfig?

    // scroll view cards
    @Published public var isEditCoInsuredSelectContractPresented: CoInsuredConfigModel?
    @Published public var isEditCoInsuredPresented: InsuredPeopleConfig?

    //claim details
    @Published public var document: InsuranceTerm? = nil

    @Published public var navBarItems = NavBarItems()

    @Published public var openChat: ChatTopicWrapper?
    @Published public var openChatOptions: DetentPresentationOption = []

    public struct NavBarItems {
        public var isFirstVetPresented = false
        public var isNewOfferPresented = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var connectPaymentVm = ConnectPaymentViewModel()
}
