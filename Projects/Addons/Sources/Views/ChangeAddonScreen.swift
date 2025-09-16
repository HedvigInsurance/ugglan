import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var changeAddonVm: ChangeAddonViewModel
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    init(
        changeAddonVm: ChangeAddonViewModel
    ) {
        self.changeAddonVm = changeAddonVm
    }

    var body: some View {
        successView.loading($changeAddonVm.fetchAddonsViewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            Task {
                                await changeAddonVm.getAddons()
                            }
                        }
                    ),
                    dismissButton:
                        .init(
                            buttonAction: {
                                changeAddonNavigationVm.router.dismiss()
                            }
                        )
                )
            )
    }

    private var successView: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .body2,
                    L10n.addonFlowTitle,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    L10n.addonFlowSubtitle
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding8) {
                    addOnSection
                    hSection {
                        InfoCard(
                            text: L10n.addonFlowTravelInformationCardText,
                            type: .neutral
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.addonFlowLearnMoreButton,
                                buttonAction: {
                                    changeAddonNavigationVm.isLearnMorePresented = .init(
                                        .init(
                                            title: L10n.addonFlowTravelInformationTitle,
                                            description: L10n.addonFlowTravelInformationDescription,
                                            perils: changeAddonNavigationVm.changeAddonVm?.selectedQuote?.addonVariant?
                                                .perils ?? []
                                        )
                                    )
                                }
                            )
                        ])

                        hContinueButton {
                            changeAddonNavigationVm.router.push(ChangeAddonRouterActions.summary)
                        }
                        .padding(.top, .padding16)
                        .padding(.bottom, .padding8)

                        hCancelButton {
                            changeAddonNavigationVm.router.dismiss()
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
    }

    @ViewBuilder
    private var addOnSection: some View {
        VStack(spacing: .padding4) {
            hSection {
                hRow {
                    if let addonOffer = changeAddonVm.addonOffer {
                        getAddonOptionView(for: addonOffer)
                    }
                }
            }
        }
    }

    private func getAddonOptionView(for addon: AddonOffer) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(addon.title)
                    .fixedSize()
                Spacer()
                hPill(
                    text: L10n.addonFlowPriceLabel(
                        changeAddonVm.addonOffer?.getTotalPrice(selectedQuote: changeAddonVm.selectedQuote)?
                            .formattedAmount ?? ""
                    ),
                    color: .grey,
                    colorLevel: .one
                )
                .hFieldSize(.small)
            }
            if let subTitle = addon.description {
                hText(subTitle, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.top, .padding8)
            }

            DropdownView(
                value: String(changeAddonVm.selectedQuote?.displayName ?? ""),
                placeHolder: L10n.addonFlowSelectDaysPlaceholder
            ) {
                changeAddonNavigationVm.isChangeCoverageDaysPresented = addon
            }
            .padding(.top, .padding16)
            .hBackgroundOption(option: (colorScheme == .light) ? [.negative] : [.secondary])
            .hWithoutHorizontalPadding([.section])
            .accessibilityHidden(false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSelectSuboptionTitle)
        .accessibilityAction {
            changeAddonNavigationVm.isChangeCoverageDaysPresented = addon
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ChangeAddonScreen(changeAddonVm: .init(contractId: "id", addonSource: .insurances))
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}
