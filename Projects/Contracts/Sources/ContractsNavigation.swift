import Addons
import ChangeTier
import EditCoInsured
import Foundation
import PresentableStore
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
        RouterHost(router: contractsNavigationVm.contractsRouter, tracking: self) {
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
            transitionType: .detent(style: [.height])
        ) { insurableLimit in
            InfoView(
                title: L10n.contractCoverageMoreInfo,
                description: insurableLimit.description
            )
        }
        .detent(
            item: $contractsNavigationVm.document,
            transitionType: .detent(style: [.large])
        ) { document in
            redirect(.pdf(document: document))
        }
        .detent(
            item: $contractsNavigationVm.changeYourInformationContract,
            transitionType: .detent(style: [.height])
        ) { contract in
            EditContractScreen(
                editTypes: EditType.getTypes(for: contract),
                onSelectedType: { selectedType in
                    contractsNavigationVm.changeYourInformationContract = nil
                    switch selectedType {
                    case .coInsured:
                        let configContract: InsuredPeopleConfig = .init(
                            contract: contract,
                            fromInfoCard: false
                        )
                        contractsNavigationVm.editCoInsuredVm.start(fromContract: configContract)
                    case .changeTier:
                        contractsNavigationVm.changeTierInput = .contractWithSource(
                            data: .init(source: .changeTier, contractId: contract.id)
                        )
                    case .cancellation:
                        let config = TerminationConfirmConfig(contract: contract)
                        Task {
                            do {
                                try await contractsNavigationVm.terminateInsuranceVm.start(with: [config])
                            } catch let exception {
                                Toasts.shared.displayToastBar(
                                    toast: .init(type: .error, text: exception.localizedDescription)
                                )
                            }
                        }
                    case .changeAddress:
                        break
                    }
                }
            )
            .configureTitle(L10n.contractChangeInformationTitle)
            .embededInNavigation(options: [.navigationType(type: .large)], tracking: ContractsDetentType.editContract)
        }
        .modally(presented: $contractsNavigationVm.isChangeAddressPresented) {
            redirect(.movingFlow)
        }
        .modally(item: $contractsNavigationVm.changeTierInput) { input in
            redirect(.changeTier(input: input))
        }
        .modally(item: $contractsNavigationVm.isAddonPresented) { input in
            redirect(.addon(input: input))
        }
        .detent(
            item: $contractsNavigationVm.insuranceUpdate,
            transitionType: .detent(style: [.height])
        ) { insuranceUpdate in
            UpcomingChangesScreen(
                updateDate: insuranceUpdate.upcomingChangedAgreement?.activeFrom ?? "",
                upcomingAgreement: insuranceUpdate.upcomingChangedAgreement
            )
            .configureTitle(L10n.InsuranceDetails.updateDetailsSheetTitle)
            .embededInNavigation(
                options: [.navigationType(type: .large)],
                tracking: ContractsDetentType.upcomingChanges
            )
            .environmentObject(contractsNavigationVm)
        }
        .handleTerminateInsurance(
            vm: contractsNavigationVm.terminateInsuranceVm
        ) { dismissType in
            redirectAction(.termination(action: dismissType))
            switch dismissType {
            case .done, .chat, .openFeedback:
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)
                contractsNavigationVm.contractsRouter.popToRoot()
            case .changeTierFoundBetterPriceStarted, .changeTierMissingCoverageAndTermsStarted:
                break
            }
        }
    }
}
@MainActor
public class ContractsNavigationViewModel: ObservableObject {
    public let contractsRouter = Router()
    let terminateInsuranceVm = TerminateInsuranceViewModel()

    @Published public var insurableLimit: InsurableLimits?
    @Published public var document: hPDFDocument?
    @Published public var editCoInsuredConfig: InsuredPeopleConfig?
    @Published public var editCoInsuredMissingAlert: InsuredPeopleConfig?
    @Published public var changeYourInformationContract: Contract?
    @Published public var insuranceUpdate: Contract?
    @Published public var isChangeAddressPresented = false
    @Published public var changeTierInput: ChangeTierInput?
    @Published public var isAddonPresented: ChangeAddonInput?

    public var editCoInsuredVm = EditCoInsuredViewModel(
        existingCoInsured: globalPresentableStoreContainer.get(of: ContractStore.self)
    )

    public init() {}
}

public enum RedirectType {
    case chat
    case movingFlow
    case pdf(document: hPDFDocument)
    case changeTier(input: ChangeTierInput)
    case addon(input: ChangeAddonInput)
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
            activeFrom: contract.currentAgreement?.activeFrom,
            typeOfContract: TypeOfContract.resolve(for: contract.currentAgreement?.productVariant.typeOfContract ?? "")
        )
    }
}

private enum ContractsDetentType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .editContract:
            return .init(describing: EditContractScreen.self)
        case .upcomingChanges:
            return .init(describing: UpcomingChangesScreen.self)
        }
    }

    case editContract
    case upcomingChanges
}

extension ContractsNavigation: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: Contracts.self)
    }
}
