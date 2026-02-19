import Combine
import SwiftUI
import hCore
import hCoreUI

public struct AddonSelectInsuranceScreen: View {
    @ObservedObject var vm: AddonSelectInsuranceScreenViewModel

    init(_ vm: AddonSelectInsuranceScreenViewModel) {
        self.vm = vm
    }

    private var itemPickerConfig: ItemConfig<AddonConfig> {
        .init(
            items: {
                let addonContractConfigs = vm.navigationVm.input.contractConfigs ?? []
                let items = addonContractConfigs.map {
                    (object: $0, displayName: ItemModel(title: $0.displayName, subTitle: $0.exposureName))
                }
                return items
            }(),
            preSelectedItems: { vm.selectedItems },
            onSelected: { selected in
                if let selectedConfig = selected.first?.0 {
                    vm.selectedItems = selected.compactMap(\.0)
                    vm.getAddonOffer(config: selectedConfig)
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    public var body: some View {
        successView
            .loadingWithButtonLoading($vm.processingState)
            .hStateViewButtonConfig(
                .init(actionButton: .init { withAnimation { vm.processingState = .success } })
            )
            .detent(item: $vm.deflect) { DeflectView(deflect: $0) }
    }

    private var successView: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.addonFlowSelectInsuranceTitle,
            subtitle: L10n.addonFlowSelectInsuranceSubtitle
        )
    }
}

@MainActor
class AddonSelectInsuranceScreenViewModel: ObservableObject {
    private let service = AddonsService()
    fileprivate let navigationVm: ChangeAddonNavigationViewModel

    @Published var processingState = ProcessingState.success
    @Published var selectedItems: [AddonConfig] = []
    @Published var deflect: AddonDeflect?

    init(_ navigationVm: ChangeAddonNavigationViewModel) {
        self.navigationVm = navigationVm
    }

    func navigateToAddonLandingScreen(offer: AddonOffer) {
        navigationVm.changeAddonVm = .init(offer: offer)
        navigationVm.router.push(ChangeAddonRouterActions.addonLandingScreen)
    }

    func getAddonOffer(config: AddonConfig) {
        Task { [weak self] in
            do {
                guard let source = self?.navigationVm.input.addonSource, let service = self?.service else { return }

                withAnimation { self?.processingState = .loading }

                let data = try await service.getAddonOffer(config: config, source: source)

                withAnimation { self?.processingState = .success }
                switch data {
                case .deflect(let deflect): withAnimation { self?.deflect = deflect }
                case .offer(let offer): self?.navigateToAddonLandingScreen(offer: offer)
                }
            } catch {
                withAnimation { self?.processingState = .error(errorMessage: error.localizedDescription) }
            }
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return AddonSelectInsuranceScreen(
        .init(
            ChangeAddonNavigationViewModel(
                input: .init(
                    addonSource: .insurances,
                    contractConfigs: [
                        .init(contractId: "1", exposureName: "1", displayName: "1"),
                        .init(contractId: "2", exposureName: "2", displayName: "2"),
                    ]
                )
            )
        )
    )
}
