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
    var redirectAction: (_ action: RedirectAction) -> Void
    public init(
        contractsNavigationVm: ContractsNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: RedirectType) -> Content,
        redirectAction: @escaping (_ type: RedirectAction) -> Void
    ) {
        self.contractsNavigationVm = contractsNavigationVm
        self.redirect = redirect
        self.redirectAction = redirectAction
    }

    public var body: some View {
        RouterHost(router: contractsNavigationVm.contractsRouter) {
            Contracts(showTerminated: false)
                .environmentObject(contractsNavigationVm)
                .configureTitle(L10n.InsurancesTab.title)
                .routerDestination(for: Contract.self) { contract in
                    ContractDetail(id: contract.id)
                        .environmentObject(contractsNavigationVm)
                        .configureTitle(contract.currentAgreement?.productVariant.displayName ?? "")
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
        .modally(presented: $contractsNavigationVm.isChangeAddressPresented) {
            redirect(.movingFlow)
        }
        .detent(
            item: $contractsNavigationVm.insuranceUpdate,
            style: .height
        ) { insuranceUpdate in
            UpcomingChangesScreen(
                updateDate: insuranceUpdate.upcomingChangedAgreement?.activeFrom ?? "",
                upcomingAgreement: insuranceUpdate.upcomingChangedAgreement
            )
            .environmentObject(contractsNavigationVm)
        }
        .handleTerminateInsurance(vm: contractsNavigationVm.terminateInsuranceVm) { dismissType in
            redirectAction(.termination(action: dismissType))
            contractsNavigationVm.contractsRouter.popToRoot()
        }
    }
}

public class ContractsNavigationViewModel: ObservableObject {
    public let contractsRouter = Router()
    let terminateInsuranceVm = TerminateInsuranceViewModel()
    @Published public var insurableLimit: InsurableLimits?
    @Published public var document: Document?
    @Published public var editCoInsuredConfig: InsuredPeopleConfig?
    @Published public var editCoInsuredMissingAlert: InsuredPeopleConfig?
    @Published public var changeYourInformationContract: Contract?
    @Published public var insuranceUpdate: Contract?
    @Published public var isChangeAddressPresented = false

    public var editCoInsuredVm = EditCoInsuredViewModel()

    public init() {}
}

public enum RedirectType {
    case chat
    case movingFlow
    case pdf(document: Document)
}

public enum RedirectAction {
    case termination(action: DismissTerminationAction)
}

enum ContractsRouterType {
    case terminatedContracts
}

extension ContractsRouterType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .terminatedContracts:
            return "Terminated Contracts"
        }
    }

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
