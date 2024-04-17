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
    @Published public var isChatPresented = false
    @Published var quickActions = QuickActions()

    struct QuickActions {
        var isConnectPaymentsPresented = false
        var isTravelCertificatePresented = false
        var isChangeAddressPresented = false
        var isEditCoInsuredPresented = false
        var isCancellationPresented = false
        var isFirstVetPresented = false
        var isSickAbroadPresented = false
    }
}

public struct HelpCenterNavigation: View {
    @StateObject private var helpCenterVm = HelpCenterNavigationViewModel()
    @EnvironmentObject private var homeVm: HomeNavigationViewModel
    @PresentableStore private var store: HomeStore

    public init() {}

    public var body: some View {
        NavigationStack {
            HelpCenterStartView { quickAction in
                handle(quickAction: quickAction)
            }
            .navigationTitle(L10n.hcTitle)
            .navigationBarTitleDisplayMode(.inline)
            .withClose(for: $homeVm.isHelpCenterPresented)
            .navigationDestination(
                for: CommonTopic.self,
                destination: { topic in
                    HelpCenterTopicView(commonTopic: topic)
                }
            )
            .navigationDestination(
                for: Question.self,
                destination: { question in
                    HelpCenterQuestionView(question: question)
                }
            )
            .detent(
                presented: $helpCenterVm.quickActions.isConnectPaymentsPresented,
                style: .large
            ) {
                PaymentsView()
            }
            .detent(
                presented: $helpCenterVm.quickActions.isEditCoInsuredPresented,
                style: .height
            ) {
                getEditCoInsuredView()
            }
            .detent(
                presented: $helpCenterVm.isChatPresented,
                style: .large
            ) {
                ChatScreen(vm: .init(topicType: nil))
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
                            .withClose(for: $helpCenterVm.quickActions.isTravelCertificatePresented)
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
        }
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
            helpCenterVm.quickActions.isEditCoInsuredPresented = true
        }
    }

    private func getEditCoInsuredView() -> some View {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()

        let contractsSupportingCoInsured = contractStore.state.activeContracts
            .filter({ $0.showEditCoInsuredInfo })
            .compactMap({
                InsuredPeopleConfig(contract: $0, fromInfoCard: false)
            })

        return EditCoInsuredViewJourney(
            configs: contractsSupportingCoInsured,
            onDisappear: {
                helpCenterVm.quickActions.isEditCoInsuredPresented = false
            }
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
                homeVm.isChatPresented = true
            },
            isEmergencyStep: true,
            partners: sickAbroadPartners ?? [],
            config: config
        )
    }
}

#Preview{
    HelpCenterNavigation()
}
