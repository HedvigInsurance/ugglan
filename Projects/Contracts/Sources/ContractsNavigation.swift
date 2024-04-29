import EditCoInsuredShared
import Foundation
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI

public struct ContractsNavigation<Content: View>: View {
    @StateObject var contractsNavigationVm = ContractsNavigationViewModel()
    @ViewBuilder var redirect: (_ type: RedirectType) -> Content
    @StateObject var router = Router()
    public init(@ViewBuilder redirect: @escaping (_ type: RedirectType) -> Content) {
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: router) {
            Contracts(showTerminated: false)
                .environmentObject(contractsNavigationVm)
                .configureTitle(L10n.InsurancesTab.title)
                .routerDestination(for: Contract.self) { contract in
                    ContractDetail(id: contract.id)
                        .environmentObject(contractsNavigationVm)
                }
                .routerDestination(for: ContractsRouterType.self) { type in
                    switch type {
                    case .terminatedContracts:
                        Contracts(showTerminated: true)
                            .environmentObject(contractsNavigationVm)
                            .configureTitle(L10n.InsurancesTab.cancelledInsurancesTitle)
                    }
                }
        }
        .detent(
            item: $contractsNavigationVm.insurableLimit,
            style: .height
        ) { insurableLimit in
            InfoView(
                title: L10n.contractCoverageMoreInfo,
                description: insurableLimit.description
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
        .detent(
            item: $contractsNavigationVm.editCoInsuredMissingAlert,
            style: .height
        ) { editCoInsuredConfig in
            redirect(
                .editCoInsured(
                    config: editCoInsuredConfig,
                    showMissingAlert: true,
                    isMissingAlertAction: { _ in

                    }
                )
            )
        }
        .fullScreenCover(item: $contractsNavigationVm.editCoInsuredConfig) { editCoInsuredConfig in
            redirect(
                .editCoInsured(
                    config: editCoInsuredConfig,
                    showMissingAlert: false,
                    isMissingAlertAction: { isMissingAlert in
                        contractsNavigationVm.editCoInsuredMissingAlert = isMissingAlert
                    }
                )
            )
        }
        .fullScreenCover(item: $contractsNavigationVm.terminationContract) { contract in
            let contractConfig: TerminationConfirmConfig = .init(contract: contract)
            TerminationViewJourney(configs: [contractConfig])
        }
        .fullScreenCover(isPresented: $contractsNavigationVm.isChangeAddressPresented) {
            redirect(.movingFlow)
        }
    }
}

public class ContractsNavigationViewModel: ObservableObject {
    public init() {}

    @Published public var insurableLimit: InsurableLimits?
    @Published public var document: Document?
    @Published public var terminationContract: Contract?
    @Published public var editCoInsuredConfig: InsuredPeopleConfig?
    @Published public var editCoInsuredMissingAlert: InsuredPeopleConfig?
    @Published public var changeYourInformationContract: Contract?
    @Published public var insuranceUpdate: Contract?
    @Published public var isChangeAddressPresented = false
}

public enum RedirectType {
    case editCoInsured(
        config: InsuredPeopleConfig,
        showMissingAlert: Bool,
        isMissingAlertAction: (InsuredPeopleConfig) -> Void
    )
    case chat
    case movingFlow
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
