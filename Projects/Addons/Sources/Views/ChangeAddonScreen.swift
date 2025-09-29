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
                CardView {
                    hRow {
                        addOnSection
                    }
                    hRow {
                        coverageButtonView
                    }
                    .verticalPadding(0)
                    .padding(.bottom, .padding16)
                }

                hSection {
                    buttonsView
                }
                .sectionContainerStyle(.transparent)
            }
    }

    @ViewBuilder
    private var addOnSection: some View {
        if let addonOffer = changeAddonVm.addonOffer {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(addonOffer.title)
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
                if let subTitle = addonOffer.description {
                    hText(subTitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .padding(.top, .padding8)
                }

                DropdownView(
                    value: String(changeAddonVm.selectedQuote?.displayName ?? ""),
                    placeHolder: L10n.addonFlowSelectDaysPlaceholder
                ) {
                    changeAddonNavigationVm.isChangeCoverageDaysPresented = addonOffer
                }
                .disabled(changeAddonVm.disableDropDown)
                .padding(.top, .padding16)
                .hBackgroundOption(option: [.locked])
                .hWithoutHorizontalPadding([.section])
                .accessibilityHidden(false)
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSelectSuboptionTitle)
            .accessibilityAction {
                changeAddonNavigationVm.isChangeCoverageDaysPresented = addonOffer
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var buttonsView: some View {
        VStack(spacing: .padding8) {
            hContinueButton {
                changeAddonNavigationVm.router.push(ChangeAddonRouterActions.summary)
            }

            hCancelButton {
                changeAddonNavigationVm.router.dismiss()
            }
        }
    }

    private var coverageButtonView: some View {
        hButton(
            .medium,
            .ghost,
            content: .init(title: L10n.addonFlowCoverButton)
        ) {
            changeAddonNavigationVm.isLearnMorePresented = .init(
                .init(
                    title: L10n.addonFlowTravelInformationTitle,
                    description: L10n.addonFlowTravelInformationDescription,
                    perils: changeAddonNavigationVm.changeAddonVm?.selectedQuote?.addonVariant?
                        .perils ?? []
                )
            )
        }
        .hButtonWithBorder
        .hButtonTakeFullWidth(true)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ChangeAddonScreen(changeAddonVm: .init(contractId: "id", addonSource: .insurances))
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}
