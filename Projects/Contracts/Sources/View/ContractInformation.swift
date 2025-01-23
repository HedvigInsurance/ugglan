import Combine
import EditCoInsuredShared
import Foundation
import PresentableStore
import SwiftUI
import TerminateContracts
import UnleashProxyClientSwift
import hCore
import hCoreUI
import hGraphQL

struct ContractInformationView: View {
    @PresentableStore var store: ContractStore
    @StateObject private var vm = ContractsInformationViewModel()
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel

    let id: String
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract {
                VStack(spacing: 0) {
                    upatedContractView(contract)
                        .transition(.opacity.combined(with: .scale))
                    VStack(spacing: 0) {
                        if let displayItems = contract.currentAgreement?.displayItems {
                            hSection(displayItems, id: \.displayTitle) { item in
                                hRow {
                                    hText(item.displayTitle)
                                }
                                .withCustomAccessory {
                                    Spacer()
                                    Group {
                                        if let date = item.displayValue.localDateToDate?.displayDateDDMMMYYYYFormat {
                                            hText(date)
                                        } else {
                                            hText(item.displayValue)
                                        }
                                    }
                                    .foregroundColor(hTextColor.Opaque.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }
                            if contract.supportsCoInsured {
                                hRowDivider()
                                    .padding(.horizontal, 16)
                                addCoInsuredView(contract: contract)
                            }

                            VStack(spacing: 8) {
                                if contract.showEditInfo {
                                    hSection {
                                        hButton.LargeButton(type: .secondary) {
                                            if contract.onlyCoInsured()
                                                && Dependencies.featureFlags().isEditCoInsuredEnabled
                                            {
                                                let contract: InsuredPeopleConfig = .init(
                                                    contract: contract,
                                                    fromInfoCard: false
                                                )

                                                contractsNavigationVm.editCoInsuredVm.start(fromContract: contract)
                                            } else {
                                                contractsNavigationVm.changeYourInformationContract = contract
                                            }
                                        } content: {
                                            if contract.onlyCoInsured()
                                                && Dependencies.featureFlags().isEditCoInsuredEnabled
                                            {
                                                hText(L10n.contractEditCoinsured)
                                            } else {
                                                hText(L10n.contractEditInfoLabel)
                                            }
                                        }
                                    }
                                }
                                if contract.canTerminate {
                                    displayTerminationButton
                                }
                            }
                            .padding(.bottom, .padding16)
                        }
                    }
                    .hWithoutHorizontalPadding
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    func insuredField(contract: Contract) -> some View {
        VStack {
            HStack {
                hText(L10n.coinsuredEditTitle)
                Spacer()
                hText(
                    contract.coInsured.count > 0
                        ? L10n.changeAddressYouPlus(contract.coInsured.count) : L10n.changeAddressOnlyYou
                )
                .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func addCoInsuredView(contract: Contract) -> some View {
        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
        VStack(spacing: 0) {
            hSection {
                HStack {
                    if Dependencies.featureFlags().isEditCoInsuredEnabled {
                        hRow {
                            insuredField(contract: contract)
                        }
                    } else {
                        hRow {
                            insuredField(contract: contract)
                        }
                        .hWithoutDivider
                    }
                }

                if Dependencies.featureFlags().isEditCoInsuredEnabled {
                    hRow {
                        let hasContentBelow =
                            !vm.getListToDisplay(contract: contract).isEmpty || nbOfMissingCoInsured > 0
                        ContractOwnerField(
                            enabled: true,
                            hasContentBelow: hasContentBelow,
                            fullName: contract.fullName,
                            SSN: contract.ssn ?? ""
                        )
                    }
                    .verticalPadding(0)
                    .padding(.top, .padding16)
                }
            }

            if Dependencies.featureFlags().isEditCoInsuredEnabled {
                hSection(vm.getListToDisplay(contract: contract)) { coInsured in
                    hRow {
                        if coInsured.coInsured.hasMissingInfo {
                            addMissingCoInsuredView(contract: contract, coInsured: coInsured.coInsured)
                        } else {
                            CoInsuredField(
                                coInsured: coInsured.coInsured,
                                accessoryView: EmptyView(),
                                includeStatusPill: includeStatusPill(type: coInsured.type),
                                date: coInsured.date
                            )
                        }
                    }
                }

                if contract.nbOfMissingCoInsuredWithoutTermination != 0 && contract.showEditCoInsuredInfo {
                    hSection {
                        CoInsuredInfoView(
                            text: L10n.contractCoinsuredAddPersonalInfo,
                            config: .init(contract: contract, fromInfoCard: true)
                        )
                        .padding(.bottom, .padding16)
                        .accessibilityElement(children: .combine)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private func includeStatusPill(type: StatusPillType?) -> StatusPillType? {
        if type == nil {
            return nil
        } else {
            return type
        }
    }

    @ViewBuilder
    private func addMissingCoInsuredView(contract: Contract, coInsured: CoInsuredModel) -> some View {
        var statusPill: StatusPillType? {
            if coInsured.terminatesOn != nil {
                return .deleted
            } else if coInsured.activatesOn != nil {
                return .added
            }
            return nil
        }

        CoInsuredField(
            accessoryView: getAccessoryView(contract: contract, coInsured: coInsured)
                .foregroundColor(hSignalColor.Amber.element),
            includeStatusPill: statusPill,
            date: coInsured.terminatesOn ?? coInsured.activatesOn,
            title: L10n.contractCoinsured,
            subTitle: L10n.contractNoInformation
        )
        .onTapGesture {
            if contract.showEditCoInsuredInfo && coInsured.terminatesOn == nil {
                let contract: InsuredPeopleConfig = .init(
                    contract: contract,
                    fromInfoCard: false
                )
                contractsNavigationVm.editCoInsuredVm.start(fromContract: contract)
            }
        }
    }

    @ViewBuilder
    private func getAccessoryView(contract: Contract, coInsured: CoInsuredModel) -> some View {
        if contract.showEditCoInsuredInfo && coInsured.terminatesOn == nil {
            Image(uiImage: hCoreUIAssets.warningTriangleFilledSmall.image)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func upatedContractView(_ contract: Contract) -> some View {
        if let upcomingRenewal = contract.upcomingRenewal,
            let days = upcomingRenewal.renewalDate.localDateToDate?.daysBetween(start: Date()),
            URL(string: upcomingRenewal.certificateUrl) != nil
        {
            hSection {
                InfoCard(
                    text: days == 0
                        ? L10n.dashboardRenewalPrompterBodyTomorrow : L10n.dashboardRenewalPrompterBody(days),
                    type: .info
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.dashboardRenewalPrompterBodyButton,
                        buttonAction: {
                            contractsNavigationVm.document = hPDFDocument(
                                displayName: L10n.insuranceCertificateTitle,
                                url: upcomingRenewal.certificateUrl ?? "",
                                type: .unknown
                            )
                        }
                    )
                ])
            }
            .padding(.top, .padding8)
        } else if let upcomingChangedAgreement = contract.upcomingChangedAgreement,
            URL(string: upcomingChangedAgreement.certificateUrl) != nil
        {
            hSection {
                HStack {
                    if contract.coInsured.first(where: {
                        return ($0.activatesOn != nil || $0.terminatesOn != nil)
                    }) != nil, Dependencies.featureFlags().isEditCoInsuredEnabled {
                        InfoCard(
                            text: L10n.contractCoinsuredUpdateInFuture(
                                contract.coInsured.count,
                                upcomingChangedAgreement.activeFrom?.localDateToDate?
                                    .displayDateDDMMMYYYYFormat ?? ""
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.contractViewCertificateButton,
                                buttonAction: {
                                    contractsNavigationVm.document = hPDFDocument(
                                        displayName: L10n.myDocumentsInsuranceCertificate,
                                        url: upcomingChangedAgreement.certificateUrl ?? "",
                                        type: .unknown
                                    )
                                }
                            )
                        ])
                        .padding(.top, .padding8)
                    } else {
                        InfoCard(
                            text: L10n.InsurancesTab.yourInsuranceWillBeUpdated(
                                upcomingChangedAgreement.activeFrom ?? ""
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.InsurancesTab.viewDetails,
                                buttonAction: {
                                    contractsNavigationVm.insuranceUpdate = contract
                                }
                            )
                        ])
                        .padding(.top, .padding8)
                    }
                }
            }
        } else if let upcomingChangedAgreement = contract.upcomingChangedAgreement,
            upcomingChangedAgreement.certificateUrl == nil
        {
            Rectangle()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        store.send(.fetchContracts)
                    }
                }
                .frame(height: 0)
                .id(UUID().uuidString)
        }
    }

    @ViewBuilder
    private var displayTerminationButton: some View {
        if Dependencies.featureFlags().isTerminationFlowEnabled {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.contractForId(id)
                }
            ) { contract in
                if contract?.canTerminate ?? false {
                    hSection {
                        hButton.LargeButton(type: .ghost) {
                            if let contract {
                                let config = TerminationConfirmConfig(contract: contract)
                                Task {
                                    withAnimation {
                                        vm.cancelInsuranceState = .loading
                                    }
                                    do {
                                        try await contractsNavigationVm.terminateInsuranceVm.start(with: [config])
                                    } catch let exception {
                                        Toasts.shared.displayToastBar(
                                            toast: .init(type: .error, text: exception.localizedDescription)
                                        )
                                    }
                                    withAnimation {
                                        vm.cancelInsuranceState = .success
                                    }
                                }
                            }
                        } content: {
                            hText(L10n.terminationButton, style: .body1)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                    .hButtonIsLoading(vm.cancelInsuranceState == .loading)
                }
            }
        }
    }
}

@MainActor
private class ContractsInformationViewModel: ObservableObject {
    var cancellable: AnyCancellable?
    @Published var cancelInsuranceState: ProcessingState = .success
    func getListToDisplay(contract: Contract) -> [CoInsuredListType] {
        return contract.coInsured
            .map {
                CoInsuredListType(
                    coInsured: $0,
                    date: $0.activatesOn ?? $0.terminatesOn,
                    locallyAdded: false
                )
            }
    }
}

public struct CoInsuredInfoView: View {
    @PresentableStore var store: ContractStore
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel

    let text: String
    let config: InsuredPeopleConfig
    public init(
        text: String,
        config: InsuredPeopleConfig
    ) {
        self.text = text
        self.config = config
    }

    public var body: some View {
        InfoCard(text: text, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: {
                        contractsNavigationVm.editCoInsuredVm.start(fromContract: config)
                    }
                )
            ])
    }
}
