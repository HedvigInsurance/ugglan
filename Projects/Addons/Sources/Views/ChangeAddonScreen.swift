import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var changeAddonVm: ChangeAddonViewModel

    public init(
        changeAddonVm: ChangeAddonViewModel
    ) {
        self.changeAddonVm = changeAddonVm
    }

    var body: some View {
        successView.loading($changeAddonVm.viewState)
            .hErrorViewButtonConfig(
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
                            buttonTitle: L10n.generalCloseButton,
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
                        if let informationText = changeAddonVm.informationText {
                            InfoCard(
                                text: informationText,
                                type: .neutral
                            )
                            .buttons([
                                .init(
                                    buttonTitle: L10n.addonFlowLearnMoreButton,
                                    buttonAction: {
                                        changeAddonNavigationVm.isLearnMorePresented = .init(
                                            title: "What is Reseskydd Plus?",
                                            description:
                                                "Med reseskyddet som ingår i din hemförsäkring får du hjälp vid olycksfall och akut sjukdom eller tandbesvär som kräver sjukvård under din resa.\n\nSkyddet gäller också om ni tvingas evakuera resmålet på grund av det utbryter krig, naturkatastrof eller epidemi. Du kan även få ersättning om du måste avbryta resan på grund av att något allvarligt har hänt med en närstående hemma."
                                        )
                                    }
                                )
                            ])
                        }

                        hButton.LargeButton(type: .primary) {
                            changeAddonNavigationVm.router.push(ChangeAddonRouterActions.summary)
                        } content: {
                            hText(L10n.addonFlowAddToInsuranceButton)
                        }
                        .padding(.top, .padding16)
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
            .hDisableScroll
    }

    @ViewBuilder
    private var addOnSection: some View {
        VStack(spacing: .padding4) {
            ForEach(changeAddonVm.addonOptions ?? []) { addonOption in
                hSection {
                    hRow {
                        getAddonOptionView(for: addonOption)
                    }
                }
                .hFieldSize(.medium)
            }

        }
    }

    private func getAddonOptionView(for addonOption: AddonOptionModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(addonOption.title ?? "")
                    .fixedSize()
                Spacer()

                hPill(
                    text: "+ " + (addonOption.price?.formattedAmountPerMonth ?? ""),
                    color: .grey(translucent: true),
                    colorLevel: .one
                )
                .hFieldSize(.small)
            }
            if let subTitle = addonOption.subtitle {
                hText(subTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .padding(.top, .padding8)
            }

            let colorScheme: ColorScheme =
                UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
            DropdownView(
                value: String(changeAddonVm.selectedSubOption?.title ?? ""),
                placeHolder: L10n.addonFlowSelectDaysPlaceholder
            ) {
                changeAddonNavigationVm.isChangeCoverageDaysPresented = addonOption
            }
            .padding(.top, .padding16)
            .hBackgroundOption(option: (colorScheme == .light) ? [.negative] : [.secondary])
            .hSectionWithoutHorizontalPadding
        }
    }
}

@MainActor
public class ChangeAddonViewModel: ObservableObject {
    @Inject private var addonService: AddonsClient
    @Published var viewState: ProcessingState = .loading
    @Published var selectedSubOption: AddonSubOptionModel?
    @Published var addonOptions: [AddonOptionModel]?
    @Published var contractInformation: AddonContract?
    @Published var informationText: String?

    init(contractId: String) {
        Task {
            await getAddons()
            await getContractInformation(contractId: contractId)

            self._selectedSubOption = Published(
                initialValue: addonOptions?.first?.subOptions.first
            )
        }
    }

    func getAddons() async {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let data = try await addonService.getAddon()

            withAnimation {
                self.addonOptions = data.options
                self.informationText = data.informationText
                self.viewState = .success
            }
        } catch let exception {
            self.viewState = .error(errorMessage: exception.localizedDescription)
        }
    }

    func getContractInformation(contractId: String) async {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let data = try await addonService.getContract(contractId: contractId)

            withAnimation {
                self.contractInformation = data
                self.viewState = .success
            }
        } catch let exception {
            self.viewState = .error(errorMessage: exception.localizedDescription)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonScreen(changeAddonVm: .init(contractId: ""))
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(contractId: "contractId")))
}