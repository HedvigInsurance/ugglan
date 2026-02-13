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
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init { Task { await removeAddonVm.fetchOffer() } },
                    dismissButton: .init { removeAddonNavigationVm.router.dismiss() }
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
                                addonToggleRow(
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
                                    onTap: { withAnimation { removeAddonVm.toggleAddon(addon) } }
                                )
                            }
                        }
                    }
                    hSection {
                        hContinueButton {
                            removeAddonNavigationVm.router.push(RemoveAddonRouterActions.summary)
                        }
                        .disabled(!removeAddonVm.allowToContinue)
                    }
                }
                .sectionContainerStyle(.transparent)
        }
    }

    @hColorBuilder
    private func checkmarkColor(isSelected: Bool) -> some hColor {
        if isSelected { hColorBase(.green) } else { hGrayscaleTranslucent.greyScaleTranslucent300 }
    }

    @ViewBuilder
    private func addonToggleRow<Trailing: View>(
        title: String,
        subtitle: String,
        isSelected: Bool,
        @ViewBuilder trailingView: () -> Trailing,
        onTap: @escaping () -> Void
    ) -> some View {
        let checkmarkColor = checkmarkColor(isSelected: isSelected)
        ZStack {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(checkmarkColor)
                    .font(.title2)

                VStack(alignment: .leading, spacing: .padding4) {
                    HStack {
                        hText(title)
                        Spacer()
                        trailingView()
                    }
                    hText(subtitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .padding(.init(top: .padding18, leading: .padding16, bottom: .padding24, trailing: .padding16))
        }
        .onTapGesture { withAnimation { onTap() } }
        .accessibilityAction { onTap() }
        .background(hSurfaceColor.Opaque.primary)
        .cornerRadius(.cornerRadiusL)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let contractInfo: AddonConfig = .init(contractId: "1", exposureName: "exposure", displayName: "title")
    return RemoveAddonScreen(.init(contractInfo))
        .environmentObject(RemoveAddonNavigationViewModel(contractInfo))
}
