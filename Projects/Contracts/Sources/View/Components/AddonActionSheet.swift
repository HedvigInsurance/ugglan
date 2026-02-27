import Addons
import SwiftUI
import hCore
import hCoreUI

struct AddonActionSheet: View {
    let addonAction: AddonAction
    @ObservedObject var contractsNavigationVm: ContractsNavigationViewModel
    private let router = Router()
    @State private var selectedOption: AddonAction.AddonActionType?
    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding8) {
                    titleView
                    actionsView
                }
                .padding(.top, .padding8)
                .padding(.horizontal, .padding8)
            }
            .padding(.vertical, .padding16)
            .sectionContainerStyle(.transparent)
            .disabled(isLoading)
            .animation(.default, value: selectedOption)
        }
        .hFormContentPosition(.compact)
        .embededInNavigation(
            router: router,
            options: [.navigationBarHidden],
            tracking: self
        )
        .onAppear {
            if addonAction.types.count == 1 {
                selectedOption = addonAction.types.first
            }
        }
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(addonAction.displayName).foregroundColor(hTextColor.Opaque.primary)
            hText(
                addonAction.description
            )
            .foregroundColor(hTextColor.Translucent.secondary)
        }
    }

    @ViewBuilder
    private var actionsView: some View {
        if addonAction.types.count > 1 {
            radioButtons
                .padding(.top, .padding16)
                .padding(.bottom, .padding8)
            continueButton
        } else if let type = addonAction.types.first {
            actionButton(for: type)
                .padding(.top, .padding24)
        }
        cancelButton
            .padding(.top, addonAction.types.isEmpty ? .padding24 : 0)
    }

    private var radioButtons: some View {
        VStack(spacing: .padding4) {
            ForEach(addonAction.types) { intentType in
                hRadioField(
                    id: intentType.id,
                    leftView: {
                        hText(intentType.title).asAnyView
                    },
                    selected: $selectedOption,
                    error: nil,
                    useAnimation: true
                )
                .hFieldSize(.medium)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func actionButton(for type: AddonAction.AddonActionType) -> some View {
        hButton(.large, .primary, content: .init(title: type.title)) {
            executeAction(for: type)
        }
        .hButtonIsLoading(isLoading)
    }

    private var isLoading: Bool {
        switch selectedOption {
        case .upgrade:
            return contractsNavigationVm.isAddonPresented != nil
        case .removal:
            return contractsNavigationVm.isRemoveAddonPresented != nil
        case nil:
            return false
        }
    }

    private var continueButton: some View {
        hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
            executeAction(for: selectedOption)
        }
        .hButtonIsLoading(isLoading)
        .disabled(selectedOption == nil)
    }

    private var cancelButton: some View {
        hButton(.large, .secondary, content: .init(title: L10n.generalCloseButton)) {
            router.dismiss()
        }
    }

    private func executeAction(for type: AddonAction.AddonActionType?) {
        switch type {
        case .upgrade:
            contractsNavigationVm.isAddonPresented = .init(
                addonSource: .insurances,
                contractConfigs: [addonAction.contract.asContractConfig],
                preselectedAddonTitle: addonAction.displayName
            )
        case .removal:
            contractsNavigationVm.isRemoveAddonPresented = .init(
                contractInfo: addonAction.contract.asContractConfig,
                preselectedAddons: [addonAction.displayName]
            )
        case nil:
            break
        }
    }
}

extension AddonActionSheet: TrackingViewNameProtocol {
    var nameForTracking: String {
        String(describing: AddonActionSheet.self)
    }
}

extension Contract {
    fileprivate static let preview = Contract(
        id: "1",
        currentAgreement: nil,
        exposureDisplayName: "Bilförsäkring",
        masterInceptionDate: nil,
        terminationDate: nil,
        supportsAddressChange: false,
        supportsCoInsured: false,
        supportsTravelCertificate: false,
        supportsChangeTier: false,
        upcomingChangedAgreement: nil,
        upcomingRenewal: nil,
        firstName: "Test",
        lastName: "User",
        ssn: nil,
        typeOfContract: .seHouse,
        coInsured: []
    )
}

#Preview("Upgrade + Removal") {
    AddonActionSheet(
        addonAction: AddonAction(contract: .preview, displayName: "Driving distance", types: [.upgrade, .removal]),
        contractsNavigationVm: ContractsNavigationViewModel()
    )
}

#Preview("Upgrade only") {
    AddonActionSheet(
        addonAction: AddonAction(contract: .preview, displayName: "Driving distance", types: [.upgrade]),
        contractsNavigationVm: ContractsNavigationViewModel()
    )
}

#Preview("Removal only") {
    AddonActionSheet(
        addonAction: AddonAction(contract: .preview, displayName: "Driving distance", types: [.removal]),
        contractsNavigationVm: ContractsNavigationViewModel()
    )
}

#Preview("No types") {
    AddonActionSheet(
        addonAction: AddonAction(contract: .preview, displayName: "Driving distance", types: []),
        contractsNavigationVm: ContractsNavigationViewModel()
    )
}
