import ChangeTier
import Chat
import Contracts
import EditCoInsuredShared
import Payment
import PresentableStore
import SafariServices
import SwiftUI
import TerminateContracts
import TravelCertificate
import hCore
import hCoreUI

public class HelpCenterNavigationViewModel: ObservableObject {
    @Published var quickActions = QuickActions()
    var connectPaymentsVm = ConnectPaymentViewModel()
    public let editCoInsuredVm = EditCoInsuredViewModel(
        existingCoInsured: globalPresentableStoreContainer.get(of: ContractStore.self)
    )
    let terminateInsuranceVm = TerminateInsuranceViewModel()

    struct QuickActions {
        var isTravelCertificatePresented = false
        var isChangeAddressPresented = false
        var isCancellationPresented = false
        var isFirstVetPresented = false
        var isSickAbroadPresented = false
    }

    public init() {}
}

public enum HelpCenterNavigationRouterType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: InboxView.self)
    }
    case inbox
}

private enum HelpCenterDetentRouterType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .startView:
            return .init(describing: HelpCenterStartView.self)
        case .firstVet:
            return .init(describing: FirstVetView.self)
        }
    }

    case startView
    case firstVet

}

public struct HelpCenterNavigation<Content: View>: View {
    @ObservedObject var helpCenterVm: HelpCenterNavigationViewModel
    @EnvironmentObject private var homeVm: HomeNavigationViewModel
    @PresentableStore private var store: HomeStore
    @ViewBuilder var redirect: (_ type: HelpCenterRedirectType) -> Content
    @StateObject var router = Router()

    public init(
        helpCenterVm: HelpCenterNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: HelpCenterRedirectType) -> Content
    ) {
        self.helpCenterVm = helpCenterVm
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: router, tracking: HelpCenterDetentRouterType.startView) {
            HelpCenterStartView(
                onQuickAction: { quickAction in
                    handle(quickAction: quickAction)
                }
            )
            .navigationTitle(L10n.hcTitle)
            .withDismissButton()
            .routerDestination(for: Question.self) { question in
                HelpCenterQuestionView(question: question, router: router)
            }
            .routerDestination(for: CommonTopic.self) { topic in
                HelpCenterTopicView(commonTopic: topic, router: router)
            }
            .routerDestination(for: HelpCenterNavigationRouterType.self) { _ in
                InboxView()
                    .configureTitle(L10n.chatConversationInbox)
            }
        }
        .ignoresSafeArea()
        .detent(
            presented: $helpCenterVm.quickActions.isFirstVetPresented,
            style: [.large]
        ) {
            FirstVetView(partners: store.state.quickActions.getFirstVetPartners ?? [])
                .configureTitle(QuickAction.firstVet(partners: []).displayTitle)
                .withDismissButton()
                .embededInNavigation(
                    options: .navigationType(type: .large),
                    tracking: HelpCenterDetentRouterType.firstVet
                )
        }
        .detent(
            presented: $helpCenterVm.quickActions.isSickAbroadPresented,
            style: [.large]
        ) {
            getSubmitClaimDeflectScreen()
        }
        .modally(
            presented: $helpCenterVm.quickActions.isTravelCertificatePresented,
            content: {
                redirect(
                    .travelInsurance
                )
            }
        )
        .modally(
            presented: $helpCenterVm.quickActions.isChangeAddressPresented,
            content: {
                redirect(.moveFlow)
            }
        )
        .handleConnectPayment(with: helpCenterVm.connectPaymentsVm)
        .handleTerminateInsurance(vm: helpCenterVm.terminateInsuranceVm) { dismissType in
            switch dismissType {
            case .done:
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)
                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                homeStore.send(.fetchQuickActions)
            case .chat:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                }
            case let .openFeedback(url):
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)
                let homeStore: HomeStore = globalPresentableStoreContainer.get()
                homeStore.send(.fetchQuickActions)
                var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if urlComponent?.scheme == nil {
                    urlComponent?.scheme = "https"
                }
                let schema = urlComponent?.scheme
                if let finalUrl = urlComponent?.url {
                    if schema == "https" || schema == "http" {
                        let vc = SFSafariViewController(url: finalUrl)
                        vc.modalPresentationStyle = .pageSheet
                        vc.preferredControlTintColor = .brand(.primaryText())
                        UIApplication.shared.getTopViewController()?.present(vc, animated: true)
                    } else {
                        UIApplication.shared.open(url)
                    }
                }
            case .changeTierFoundBetterPriceStarted, .changeTierMissingCoverageAndTermsStarted:
                break
            }
        }
        .environmentObject(helpCenterVm)
    }

    private func handle(quickAction: QuickAction) {
        switch quickAction {
        case .connectPayments:
            helpCenterVm.connectPaymentsVm.set(for: nil)
        case .travelInsurance:
            helpCenterVm.quickActions.isTravelCertificatePresented = true
        case .changeAddress:
            helpCenterVm.quickActions.isChangeAddressPresented = true
        case .cancellation:
            let contractStore: ContractStore = globalPresentableStoreContainer.get()

            let contractsConfig: [TerminationConfirmConfig] = contractStore.state.activeContracts
                .filter({ $0.canTerminate })
                .map({
                    $0.asTerminationConfirmConfig
                })
            helpCenterVm.terminateInsuranceVm.start(with: contractsConfig)
        case .firstVet:
            helpCenterVm.quickActions.isFirstVetPresented = true
        case .sickAbroad:
            helpCenterVm.quickActions.isSickAbroadPresented = true
        case .editCoInsured:
            helpCenterVm.editCoInsuredVm.start()
        }
    }

    private func getSubmitClaimDeflectScreen() -> some View {
        redirect(.deflect)
    }
}

public enum HelpCenterRedirectType {
    case travelInsurance
    case moveFlow
    case deflect
}

#Preview {
    HelpCenterNavigation(helpCenterVm: .init(), redirect: { _ in })
}
