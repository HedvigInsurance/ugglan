import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var changeAddonVm: ChangeAddonViewModel

    public init(
        changeAddonVm: ChangeAddonViewModel
    ) {
        self.changeAddonVm = changeAddonVm
    }

    public var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .body2,
                    "Utöka ditt reseskydd",
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    "Lorem ipsum dolor sit amet our"
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding8) {
                    addOnSection
                    hSection {
                        InfoCard(
                            text: "Click to learn more about our extended travel coverage Reseskydd Plus",
                            type: .neutral
                        )
                        .buttons([
                            .init(
                                buttonTitle: "Learn more",
                                buttonAction: {
                                    changeAddonNavigationVm.isLearnMorePresented = true
                                }
                            )
                        ])

                        hButton.LargeButton(type: .primary) {
                            changeAddonNavigationVm.router.push(ChangeAddonRouterActions.summary)
                        } content: {
                            hText(L10n.generalContinueButton)
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
                    hRadioField(
                        id: addonOption.id.uuidString,
                        leftView: {
                            getLeftView(for: addonOption).asAnyView
                        },
                        selected: $changeAddonVm.selectedAddonOptionId,
                        error: nil,
                        useAnimation: true
                    )
                    .hFieldSize(.medium)
                    .hFieldLeftAttachedView
                }
            }
        }
    }

    private func getLeftView(for addonOption: AddonOptionModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(addonOption.title ?? "")
                    .fixedSize()
                Spacer()

                hPill(
                    text: addonOption.price?.formattedAmountPerMonth ?? "Ingår",
                    color: .grey(translucent: true),
                    colorLevel: .one
                )
                .hFieldSize(.small)
            }
            if let subTitle = addonOption.subtitle {
                hText(subTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }

            if changeAddonVm.selectedAddonOptionId == addonOption.id.uuidString && changeAddonVm.hasSubOptions {

                let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
                DropdownView(
                    value: String(changeAddonVm.getSelectedSubOption?.subtitle ?? "") + " dagar",
                    placeHolder: "Välj skydd"
                ) {
                    let id = changeAddonVm.selectedAddonOptionId
                    changeAddonNavigationVm.isChangeCoverageDaysPresented = changeAddonVm.getAddonOptionFor(
                        id: id ?? ""
                    )
                }
                .padding(.leading, -48)
                .padding(.trailing, -16)
                .padding(.top, .padding16)
                .hBackgroundOption(option: (colorScheme == .light) ? [.negative] : [.secondary])
            }
        }
    }
}

public class ChangeAddonViewModel: ObservableObject {
    @Inject var addonService: AddonsClient
    @Published var selectedAddonOptionId: String? {
        didSet {
            selectedSubOptionId =
                selectedSubOptionId
                ?? getAddonOptionFor(id: selectedAddonOptionId ?? "")?.subOptions.first?.id.uuidString
        }
    }
    @Published var selectedSubOptionId: String?
    @Published var addonOptions: [AddonOptionModel]?
    @Published var contractInformation: AddonContract?

    var hasSubOptions: Bool {
        let selectedAddonOption = addonOptions?.first(where: { $0.id.uuidString == selectedAddonOptionId })
        return selectedAddonOption?.subOptions.count ?? 0 > 0
    }

    init(contractId: String) {
        Task {
            await getAddons()
            await getContractInformation(contractId: contractId)

            self._selectedAddonOptionId = Published(
                initialValue: addonOptions?.first(where: { $0.subOptions.isEmpty })?.id.uuidString
            )
        }
    }

    func getAddonOptionFor(id: String) -> AddonOptionModel? {
        return addonOptions?.first(where: { $0.id.uuidString == selectedAddonOptionId })
    }

    var getSelectedSubOption: AddonSubOptionModel? {
        let selectedAddonOption = getAddonOptionFor(id: selectedAddonOptionId ?? "")
        let subOption = selectedAddonOption?.subOptions
            .first(where: {
                $0.id.uuidString == selectedSubOptionId
            })
        return subOption
    }

    @MainActor
    func getAddons() async {
        do {
            let data = try await addonService.getAddons()

            withAnimation {
                self.addonOptions = data.options
            }
        } catch {

        }
    }

    @MainActor
    func getContractInformation(contractId: String) async {
        do {
            let data = try await addonService.getContract(contractId: contractId)

            withAnimation {
                self.contractInformation = data
            }
        } catch {

        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonScreen(changeAddonVm: .init(contractId: ""))
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(contractId: "contractId")))
}
