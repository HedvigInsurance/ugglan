import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonScreen: View {
    @EnvironmentObject var navigationVm: RemoveAddonNavigationViewModel
    @ObservedObject var vm: RemoveAddonViewModel

    init(_ removeAddonVm: RemoveAddonViewModel) {
        self.vm = removeAddonVm
    }

    var body: some View {
        successView
            .loading($vm.fetchState)
            .disabled(vm.fetchingCostState == .loading)
            .trackErrorState(for: $vm.fetchingCostState)
            .hStateViewButtonConfig(
                vm.fetchState.isError
                    ? .init(
                        actionButton: .init { Task { await vm.fetchOffer() } },
                        dismissButton: .init { navigationVm.router.dismiss() }
                    )
                    : .init(
                        actionButton: .init { vm.fetchingCostState = .success },
                        dismissButton: .init(buttonTitle: L10n.generalCloseButton) {
                            vm.fetchingCostState = .success
                            navigationVm.router.dismiss()
                        }
                    )
            )
    }

    @ViewBuilder
    private var successView: some View {
        if let offer = vm.removeOffer {
            hForm {}
                .hFormTitle(
                    title: .init(.small, .body2, offer.pageTitle, alignment: .leading),
                    subTitle: .init(.small, .body2, offer.pageDescription, alignment: .leading)
                )
                .hFormAttachToBottom {
                    hSection {
                        VStack(alignment: .leading, spacing: .padding8) {
                            ForEach(offer.removableAddons) { addon in
                                AddonOptionRow(
                                    title: addon.displayTitle,
                                    subtitle: addon.displayDescription ?? "",
                                    isSelected: vm.isAddonSelected(addon),
                                    trailingView: {
                                        hPill(
                                            text: addon.cost.premium.gross.formattedAmountPerMonth,
                                            color: .grey,
                                            colorLevel: .one
                                        )
                                        .hFieldSize(.small)
                                    },
                                    onTap: { [weak vm] in vm?.toggleAddon(addon) }
                                )
                            }
                        }
                    }
                    hSection {
                        hContinueButton {
                            Task { [weak vm, weak navigationVm] in
                                await vm?.getAddonRemoveOfferCost()
                                guard vm?.addonRemoveOfferCost != nil else { return }
                                navigationVm?.router.push(RemoveAddonRouterActions.summary)
                            }
                        }
                        .disabled(!vm.allowToContinue)
                        .hButtonIsLoading(vm.fetchingCostState == .loading)
                    }
                }
                .sectionContainerStyle(.transparent)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let contractInfo: AddonConfig = .init(contractId: "1", exposureName: "exposure", displayName: "title")
    return RemoveAddonScreen(.init(.init(contractId: "", exposureName: "", displayName: ""), []))
        .environmentObject(RemoveAddonNavigationViewModel(contractInfo, []))
}
