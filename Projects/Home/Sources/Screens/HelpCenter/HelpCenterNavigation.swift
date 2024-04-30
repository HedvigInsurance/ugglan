import Chat
import Contracts
import EditCoInsured
import EditCoInsuredShared
import MoveFlow
import Payment
import Presentation
import SwiftUI
import TerminateContracts
import TravelCertificate
import hCore
import hCoreUI

public class HelpCenterNavigationViewModel: ObservableObject {
    @Published var quickActions = QuickActions()

    struct QuickActions {
        var isConnectPaymentsPresented = false
        var isTravelCertificatePresented = false
        var isChangeAddressPresented = false
        var isEditCoInsuredSelectContractPresented: HomeNavigationViewModel.CoInsuredConfigModel?

        var isEditCoInsuredPresented: InsuredPeopleConfig?
        var isEditCoInsuredMissingContractPresented: InsuredPeopleConfig?

        var isCancellationPresented = false
        var isFirstVetPresented = false
        var isSickAbroadPresented = false
    }

    public struct ChatTopicModel: Identifiable, Equatable {
        public var id: String?
        var topic: ChatTopicType?
    }
}

public struct HelpCenterNavigation<Content: View>: View {
    @StateObject private var helpCenterVm = HelpCenterNavigationViewModel()
    @EnvironmentObject private var homeVm: HomeNavigationViewModel
    @PresentableStore private var store: HomeStore
    @StateObject var router = Router()
    @ViewBuilder var redirect: (_ type: HelpCenterRedirectType) -> Content

    public init(@ViewBuilder redirect: @escaping (_ type: HelpCenterRedirectType) -> Content) {
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: router) {
            HelpCenterStartView { quickAction in
                handle(quickAction: quickAction)
            }
            .navigationTitle(L10n.hcTitle)
            .withDismissButton()
            .routerDestination(for: Question.self) { question in
                HelpCenterQuestionView(question: question)
            }
            .routerDestination(for: CommonTopic.self) { topic in
                HelpCenterTopicView(commonTopic: topic)
            }
        }
        .ignoresSafeArea()
        .detent(
            presented: $helpCenterVm.quickActions.isConnectPaymentsPresented,
            style: .large
        ) {
            PaymentsView()
        }
        .detent(
            item: $helpCenterVm.quickActions.isEditCoInsuredMissingContractPresented,
            style: .height
        ) { config in
            redirect(
                .editCoInsured(
                    config: config,
                    showMissingAlert: true,
                    isMissingAlertAction: { isMissing in
                    }
                )
            )
        }
        .detent(
            item: $helpCenterVm.quickActions.isEditCoInsuredSelectContractPresented,
            style: .height
        ) { configs in
            redirect(
                .editCoInuredSelectInsurance(
                    configs: configs.configs,
                    isMissingAlertAction: { missingContract in
                        helpCenterVm.quickActions.isEditCoInsuredSelectContractPresented = nil
                        helpCenterVm.quickActions.isEditCoInsuredMissingContractPresented = missingContract
                    }
                )
            )
        }
        .fullScreenCover(
            item: $helpCenterVm.quickActions.isEditCoInsuredPresented
        ) { config in
            getEditCoInsuredView(config: config)
        }
        .detent(
            presented: $helpCenterVm.quickActions.isFirstVetPresented,
            style: .large
        ) {
            FirstVetView(partners: store.state.quickActions.getFirstVetPartners ?? [])
        }
        .detent(
            presented: $helpCenterVm.quickActions.isSickAbroadPresented,
            style: .large
        ) {
            getSubmitClaimDeflectScreen()
        }
        .fullScreenCover(
            isPresented: $helpCenterVm.quickActions.isTravelCertificatePresented,
            content: {
                NavigationStack {
                    ListScreen(canAddTravelInsurance: true, infoButtonPlacement: .topBarLeading)
                        .withDismissButton()
                }
            }
        )
        .fullScreenCover(
            isPresented: $helpCenterVm.quickActions.isChangeAddressPresented,
            content: {
                MovingFlowViewJourney()
            }
        )
        .fullScreenCover(
            isPresented: $helpCenterVm.quickActions.isCancellationPresented,
            content: {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let contractsConfig: [TerminationConfirmConfig] = contractStore.state.activeContracts
                    .filter({ $0.canTerminate })
                    .map({
                        $0.asTerminationConfirmConfig
                    })
                TerminationViewJourney(configs: contractsConfig)
            }
        )
        .environmentObject(helpCenterVm)
    }

    private func handle(quickAction: QuickAction) {
        switch quickAction {
        case .connectPayments:
            helpCenterVm.quickActions.isConnectPaymentsPresented = true
        case .travelInsurance:
            helpCenterVm.quickActions.isTravelCertificatePresented = true
        case .changeAddress:
            helpCenterVm.quickActions.isChangeAddressPresented = true
        case .cancellation:
            helpCenterVm.quickActions.isCancellationPresented = true
        case .firstVet:
            helpCenterVm.quickActions.isFirstVetPresented = true
        case .sickAbroad:
            helpCenterVm.quickActions.isSickAbroadPresented = true
        case .editCoInsured:
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            let contractsSupportingCoInsured = contractStore.state.activeContracts
                .filter({ $0.showEditCoInsuredInfo })
                .compactMap({
                    InsuredPeopleConfig(contract: $0, fromInfoCard: true)
                })

            if contractsSupportingCoInsured.count > 1 {
                helpCenterVm.quickActions.isEditCoInsuredSelectContractPresented = .init(
                    configs: contractsSupportingCoInsured
                )
            } else {
                helpCenterVm.quickActions.isEditCoInsuredPresented = contractsSupportingCoInsured.first
            }
        }
    }

    private func getEditCoInsuredView(config: InsuredPeopleConfig) -> some View {
        redirect(
            .editCoInsured(
                config: config,
                showMissingAlert: false,
                isMissingAlertAction: { missingContract in
                    helpCenterVm.quickActions.isEditCoInsuredPresented = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        helpCenterVm.quickActions.isEditCoInsuredMissingContractPresented = missingContract
                    }
                }
            )
        )
    }

    private func getSubmitClaimDeflectScreen() -> some View {
        let store: HomeStore = globalPresentableStoreContainer.get()
        let quickActions = store.state.quickActions
        let sickAbroadPartners: [Partner]? = quickActions.first(where: { $0.sickAboardPartners != nil })?
            .sickAboardPartners
            .map { sickabr in
                sickabr.map { partner in
                    Partner(id: "", imageUrl: partner.imageUrl, url: "", phoneNumber: partner.phoneNumber)
                }
            }

        let config = FlowClaimDeflectConfig(
            infoText: L10n.submitClaimEmergencyInfoLabel,
            infoSectionText: L10n.submitClaimEmergencyInsuranceCoverLabel,
            infoSectionTitle: L10n.submitClaimEmergencyInsuranceCoverTitle,
            cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
            cardText: L10n.submitClaimEmergencyGlobalAssistanceLabel,
            buttonText: nil,
            infoViewTitle: nil,
            infoViewText: nil,
            questions: [
                .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
                .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
                .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
                .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
                .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
                .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),
            ]
        )
        return SubmitClaimDeflectScreen(
            openChat: {
                NotificationCenter.default.post(name: .openChat, object: ChatTopicWrapper(topic: nil, onTop: true))
            },
            isEmergencyStep: true,
            partners: sickAbroadPartners ?? [],
            config: config
        )
    }
}

public enum HelpCenterRedirectType {
    case editCoInsured(
        config: InsuredPeopleConfig,
        showMissingAlert: Bool,
        isMissingAlertAction: (InsuredPeopleConfig) -> Void
    )
    case editCoInuredSelectInsurance(
        configs: [InsuredPeopleConfig],
        isMissingAlertAction: (InsuredPeopleConfig) -> Void
    )
}

#Preview{
    HelpCenterNavigation<EmptyView>(redirect: { _ in })
}