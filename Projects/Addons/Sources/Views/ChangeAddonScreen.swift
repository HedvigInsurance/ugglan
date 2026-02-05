import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var changeAddonVm: ChangeAddonViewModel

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
                    changeAddonVm.addonOffer?.pageTitle ?? "",
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    changeAddonVm.addonOffer?.pageDescription ?? ""
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
        switch changeAddonVm.addonType {
        case .travel:
            ForEach(changeAddonVm.selectableAddons, id: \.fieldTitle) { selectable in
                addonRow(for: selectable)
            }
        case .car: EmptyView()
        case .none: EmptyView()
        }
    }

    @ViewBuilder
    private func addonRow(for selectable: AddonOfferSelectable) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(selectable.fieldTitle)
                    .fixedSize()
                Spacer()
                hPill(
                    text: L10n.addonFlowPriceLabel(
                        changeAddonVm.getPriceForQuote(
                            changeAddonVm.selectedQuote(for: selectable),
                            in: selectable
                        )?
                        .formattedAmount ?? ""
                    ),
                    color: .grey,
                    colorLevel: .one
                )
                .hFieldSize(.small)
            }

            hText(selectable.selectionDescription, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .padding(.top, .padding8)

            DropdownView(
                value: changeAddonVm.selectedQuote(for: selectable)?.displayTitle ?? "",
                placeHolder: L10n.addonFlowSelectDaysPlaceholder
            ) {
                changeAddonNavigationVm.isSelectableAddonPresented = selectable
            }
            .disabled(changeAddonVm.disableDropDown(for: selectable))
            .padding(.top, .padding16)
            .hBackgroundOption(option: changeAddonVm.disableDropDown(for: selectable) ? [.locked] : [])
            .hWithoutHorizontalPadding([.section])
            .accessibilityHidden(false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSelectSuboptionTitle)
        .accessibilityAction {
            changeAddonNavigationVm.isSelectableAddonPresented = selectable
        }
        .fixedSize(horizontal: false, vertical: true)
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
                    perils: changeAddonVm.selectableAddons.first.flatMap {
                        changeAddonVm.selectedQuote(for: $0)?.addonVariant.perils
                    } ?? []
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
