import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonScreen: View {
    @EnvironmentObject var removeAddonNavigationVm: RemoveAddonNavigationViewModel
    @ObservedObject var removeAddonVm: RemoveAddonViewModel

    init(_ removeAddonVm: RemoveAddonViewModel) {
        self.removeAddonVm = removeAddonVm
    }

    var body: some View {
        successView
            .loading($removeAddonVm.fetchState)
            .disabled(removeAddonVm.fetchingCostState == .loading)
            .trackErrorState(for: $removeAddonVm.fetchingCostState)
            .hStateViewButtonConfig(
                removeAddonVm.fetchState.isError
                    ? .init(
                        actionButton: .init { Task { await removeAddonVm.fetchOffer() } },
                        dismissButton: .init { removeAddonNavigationVm.router.dismiss() }
                    )
                    : .init(
                        actionButton: .init { removeAddonVm.fetchingCostState = .success },
                        dismissButton: .init(buttonTitle: L10n.generalCloseButton) {
                            removeAddonVm.fetchingCostState = .success
                            removeAddonNavigationVm.router.dismiss()
                        }
                    )
            )
    }

    @ViewBuilder
    private var successView: some View {
        if let offer = removeAddonVm.removeOffer {
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
                                    isSelected: removeAddonVm.isAddonSelected(addon),
                                    trailingView: {
                                        hPill(
                                            text: addon.cost.premium.gross.formattedAmountPerMonth,
                                            color: .grey,
                                            colorLevel: .one
                                        )
                                        .hFieldSize(.small)
                                    },
                                    onTap: { removeAddonVm.toggleAddon(addon) }
                                )
                            }
                        }
                    }
                    hSection {
                        hContinueButton {
                            Task {
                                await removeAddonVm.getAddonRemoveOfferCost()
                                guard removeAddonVm.addonRemoveOfferCost != nil else { return }
                                removeAddonNavigationVm.router.push(RemoveAddonRouterActions.summary)
                            }
                        }
                        .disabled(!removeAddonVm.allowToContinue)
                        .hButtonIsLoading(removeAddonVm.fetchingCostState == .loading)
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
    return RemoveAddonScreen(.init(contractInfo))
        .environmentObject(RemoveAddonNavigationViewModel(contractInfo))
}
