import EditCoInsuredShared
import Foundation
import SafariServices
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI

public struct ContractsNavigation<Content: View>: View {
    @StateObject var contractsNavigationVm = ContractsNavigationViewModel()
    @ViewBuilder var redirect: (_ type: RedirectType) -> Content

    public init(@ViewBuilder redirect: @escaping (_ type: RedirectType) -> Content) {
        self.redirect = redirect
    }

    public var body: some View {
        Contracts(showTerminated: false)
            .environmentObject(contractsNavigationVm)
            .routerDestination(for: Contract.self) { contract in
                ContractDetail(id: contract.id)
                    .environmentObject(contractsNavigationVm)
            }
            .routerDestination(for: ContractsRouterType.self) { type in
                switch type {
                case .terminatedContracts:
                    Contracts(showTerminated: true)
                        .environmentObject(contractsNavigationVm)
                }
            }
            .embededInNavigation()
            .detent(
                item: $contractsNavigationVm.insurableLimit,
                style: .height
            ) { insurableLimit in
                InfoView(
                    title: L10n.contractCoverageMoreInfo,
                    description: insurableLimit.description,
                    onDismiss: {
                        contractsNavigationVm.insurableLimit = nil
                    }
                )
            }
            .detent(
                item: $contractsNavigationVm.document,
                style: .large
            ) { document in
                redirect(.pdf(document: document))
            }
            .detent(
                item: $contractsNavigationVm.changeYourInformationContract,
                style: .height
            ) { contract in
                EditContract(id: contract.id)
                    .configureTitle(L10n.contractChangeInformationTitle)
                    .environmentObject(contractsNavigationVm)
                    .embededInNavigation(options: .navigationType(type: .large))
            }
            .detent(
                presented: $contractsNavigationVm.isChatPresented,
                style: .large
            ) {
                redirect(.chat)
            }
            .detent(
                item: $contractsNavigationVm.insuranceUpdate,
                style: .height
            ) { insuranceUpdate in
                UpcomingChangesScreen(
                    updateDate: insuranceUpdate.upcomingChangedAgreement?.activeFrom ?? "",
                    upcomingAgreement: insuranceUpdate.upcomingChangedAgreement
                )
                .onDisappear {
                    contractsNavigationVm.insuranceUpdate = nil
                }
            }
            .fullScreenCover(item: $contractsNavigationVm.editCoInsuredConfig) { editCoInsuredConfig in
                redirect(
                    .editCoInsured(
                        config: editCoInsuredConfig,
                        onDismiss: {
                            contractsNavigationVm.editCoInsuredConfig = nil
                        }
                    )
                )
            }
            .fullScreenCover(item: $contractsNavigationVm.terminationContract) { contract in
                let contractConfig: TerminationConfirmConfig = .init(contract: contract)
                TerminationFlowNavigation(
                    configs: [contractConfig],
                    isFlowPresented: { terminationAction in
                        contractsNavigationVm.terminationContract = nil
                        switch terminationAction {
                        case .none:
                            break
                        case .chat:
                            contractsNavigationVm.isChatPresented = true
                        case let .openFeedback(url):
                            // TODO: move somewhere else. Also not working
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
                        }
                    }
                )
            }
            .fullScreenCover(isPresented: $contractsNavigationVm.isChangeAddressPresented) {
                redirect(.movingFlow(isFlowPresented: $contractsNavigationVm.isChangeAddressPresented))
            }
    }
}

public class ContractsNavigationViewModel: ObservableObject {
    public init() {}

    @Published public var insurableLimit: InsurableLimits?
    @Published public var document: Document?
    @Published public var terminationContract: Contract?
    @Published public var editCoInsuredConfig: InsuredPeopleConfig?
    @Published public var changeYourInformationContract: Contract?
    @Published public var insuranceUpdate: Contract?
    @Published public var isChangeAddressPresented = false
    @Published public var isChatPresented = false
}

public enum RedirectType {
    case editCoInsured(config: InsuredPeopleConfig, onDismiss: () -> Void)
    case chat
    case movingFlow(isFlowPresented: Binding<Bool>)
    case pdf(document: Document)
}

enum ContractsRouterType {
    case terminatedContracts
}

extension TerminationConfirmConfig {
    public init(
        contract: Contract
    ) {
        self.init(
            contractId: contract.id,
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            contractExposureName: contract.exposureDisplayName,
            activeFrom: contract.currentAgreement?.activeFrom
        )
    }
}