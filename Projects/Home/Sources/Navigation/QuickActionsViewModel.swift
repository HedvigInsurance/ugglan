import AppStateContainer
import ChangeTier
import Chat
import Contracts
import EditStakeholders
import Payment
import SafariServices
import SubmitClaimChat
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI

@MainActor
public final class QuickActionsViewModel: ObservableObject {
    @Published var editContractActions: EditInsuranceActionsWrapper?
    @Published var isTravelCertificatePresented = false
    @Published var isChangeAddressPresented = false
    @Published var firstVetPartners: FirstVetPartnersWrapper?
    @Published var sickAbroadData: SubmitClaimChat.Deflection?
    @Published var isChangeTierPresented: ChangeTierContractsInput?

    let connectPaymentVm = ConnectPaymentViewModel()
    let terminateInsuranceVm = TerminateInsuranceViewModel()
    let editStakeholdersVm = EditStakeholdersViewModel(
        existingStakeholders: globalAppStateContainer.get(ContractStore.self)
    )

    public init() {}

    public func perform(_ quickAction: QuickAction) {
        switch quickAction {
        case .connectPayments: connectPaymentVm.set()
        case .travelInsurance: isTravelCertificatePresented = true
        case let .editInsurance(insuranceQuickActions): editContractActions = insuranceQuickActions
        case .changeAddress: isChangeAddressPresented = true
        case .cancellation:
            let contractStore: ContractStore = globalAppStateContainer.get()
            let contractsConfig = terminationConfigs(from: contractStore.activeContracts)
            Task {
                do {
                    try await self.terminateInsuranceVm.start(with: contractsConfig)
                } catch let exception {
                    Toasts.shared.displayToastBar(toast: .init(type: .error, text: exception.localizedDescription))
                }
            }
        case .editCoInsured: editStakeholdersVm.start(stakeholderType: .coInsured)
        case .editCoOwners: editStakeholdersVm.start(stakeholderType: .coOwner)
        case .upgradeCoverage:
            let contractStore: ContractStore = globalAppStateContainer.get()
            let contractsSupportingChangingTier: [ChangeTierContract] = contractStore.activeContracts
                .filter(\.supportsChangeTier)
                .map {
                    .init(
                        contractId: $0.id,
                        contractDisplayName: $0.currentAgreement?.productVariant.displayName ?? "",
                        contractExposureName: $0.exposureDisplayName
                    )
                }
            isChangeTierPresented = .init(
                source: .changeTier,
                contracts: contractsSupportingChangingTier
            )
        case let .firstVet(partners): firstVetPartners = .init(partners: partners)
        case let .sickAbroad(data): sickAbroadData = data
        case .removeAddons: break
        }
    }

    func terminationConfigs(from contracts: [Contracts.Contract]) -> [TerminationConfirmConfig] {
        contracts
            .filter(\.supportsTermination)
            .map(\.asTerminationConfirmConfig)
    }
}

public enum HelpCenterRedirectType {
    case travelInsurance
    case moveFlow
    case deflect(SubmitClaimChat.Deflection)
}

extension View {
    public func handleQuickActions<RedirectContent: View>(
        with vm: QuickActionsViewModel,
        @ViewBuilder redirect: @escaping (HelpCenterRedirectType) -> RedirectContent
    ) -> some View {
        modifier(QuickActions(vm: vm, redirect: redirect))
    }
}

private struct QuickActions<RedirectContent: View>: ViewModifier {
    @ObservedObject var vm: QuickActionsViewModel
    private let redirect: (HelpCenterRedirectType) -> RedirectContent

    init(
        vm: QuickActionsViewModel,
        redirect: @escaping (HelpCenterRedirectType) -> RedirectContent
    ) {
        self.vm = vm
        self.redirect = redirect
    }

    func body(content: Content) -> some View {
        content
            .detent(
                item: $vm.firstVetPartners,
                presentationStyle: .detent(style: [.large])
            ) { partnersWrapper in
                FirstVetView(partners: partnersWrapper.partners)
                    .navigationTitle(QuickAction.firstVet(partners: []).displayTitle)
                    .withDismissButton()
                    .embededInNavigation(
                        options: [.navigationType(type: .large), .extendedNavigationWidth],
                        tracking: QuickActionDetentType.firstVet
                    )
            }
            .modally(
                item: $vm.isChangeTierPresented
            ) { input in
                ChangeTierNavigation(input: input)
            }
            .detent(
                item: $vm.sickAbroadData,
                presentationStyle: .detent(style: [.large])
            ) { sickAbroadData in
                redirect(.deflect(sickAbroadData))
            }
            .modally(
                presented: $vm.isTravelCertificatePresented,
                content: {
                    redirect(.travelInsurance)
                }
            )
            .modally(
                presented: $vm.isChangeAddressPresented,
                content: {
                    redirect(.moveFlow)
                }
            )
            .detent(
                item: $vm.editContractActions,
                content: { actionsWrapper in
                    EditContractScreen(
                        editTypes: actionsWrapper.quickActions.compactMap(\.asEditType),
                        onSelectedType: { selectedType in
                            vm.perform(selectedType.asQuickAction)
                        }
                    )
                    .navigationTitle(L10n.hcQuickActionsEditInsuranceTitle)
                    .embededInNavigation(
                        options: [.navigationType(type: .large)],
                        tracking: QuickActionDetentType.editYourInsurance
                    )
                }
            )
            .handleConnectPayment(with: vm.connectPaymentVm)
            .handleTerminateInsurance(
                vm: vm.terminateInsuranceVm
            ) { dismissType in
                let homeStore: HomeStore = globalAppStateContainer.get()
                let contractStore: ContractStore = globalAppStateContainer.get()
                switch dismissType {
                case .done:
                    Task { await contractStore.fetchContracts() }
                    Task { await homeStore.fetchQuickActions() }
                case .chat:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                case let .openFeedback(url):
                    Task { await contractStore.fetchContracts() }
                    Task { await homeStore.fetchQuickActions() }
                    var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    if urlComponent?.scheme == nil {
                        urlComponent?.scheme = "https"
                    }
                    let schema = urlComponent?.scheme
                    let requiresAuthorization = url.requiresAuthorization
                    if let finalUrl = urlComponent?.url {
                        if (schema == "https" || schema == "http") && !requiresAuthorization {
                            let vc = SFSafariViewController(url: finalUrl)
                            vc.modalPresentationStyle = .pageSheet
                            vc.preferredControlTintColor = .brand(.primaryText())
                            UIApplication.shared.getTopViewController()?.present(vc, animated: true)
                        } else {
                            Task { await Dependencies.urlOpener.open(url) }
                        }
                    }
                case .changeTierFoundBetterPriceStarted, .changeTierMissingCoverageAndTermsStarted:
                    break
                }
            }
            .handleEditStakeholders(with: vm.editStakeholdersVm)
    }
}

private enum QuickActionDetentType: TrackingViewNameProtocol {
    case firstVet, editYourInsurance

    var nameForTracking: String {
        switch self {
        case .firstVet: .init(describing: FirstVetView.self)
        case .editYourInsurance: .init(describing: EditContractScreen.self)
        }
    }
}
