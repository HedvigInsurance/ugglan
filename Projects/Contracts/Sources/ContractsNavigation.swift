import EditCoInsuredShared
import Foundation
import SafariServices
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI

public struct ContractsNavigation<Content: View>: View {
    @ObservedObject var contractsNavigationVm: ContractsNavigationViewModel
    @ViewBuilder var redirect: (_ type: RedirectType) -> Content

    public init(
        contractsNavigationVm: ContractsNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: RedirectType) -> Content
    ) {
        self.contractsNavigationVm = contractsNavigationVm
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: contractsNavigationVm.contractsRouter) {
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
        .fullScreenCover(item: $contractsNavigationVm.terminationContract) { contract in
            redirect(
                .cancellation(
                    contractConfig: .init(contract: contract)
                )
            )
        }
    }
}

public class ContractsNavigationViewModel: ObservableObject {
    public let contractsRouter = Router()

    @Published public var insurableLimit: InsurableLimits?
    @Published public var document: Document?
    @Published public var terminationContract: Contract?
    @Published public var changeYourInformationContract: Contract?
    @Published public var insuranceUpdate: Contract?
    @Published public var isChangeAddressPresented = false

    public var editCoInsuredVm: EditCoInsuredViewModel

    public init(
        editCoInsuredVm: EditCoInsuredViewModel
    ) {
        self.editCoInsuredVm = editCoInsuredVm
    }
}

public enum RedirectType {
    case chat
    case movingFlow
    case pdf(document: Document)
    case cancellation(contractConfig: TerminationConfirmConfig)
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
