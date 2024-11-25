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
            ForEach(changeAddonVm.addons ?? []) { addon in
                hSection {
                    hRadioField(
                        id: addon.id.uuidString,
                        leftView: {
                            getLeftView(for: addon).asAnyView
                        },
                        selected: $changeAddonVm.selectedAddonId,
                        error: nil,
                        useAnimation: true
                    )
                    .hFieldSize(.medium)
                    .hFieldLeftAttachedView
                }
            }
        }
    }

    private func getLeftView(for addon: AddonModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(addon.title)
                    .fixedSize()
                Spacer()
                hPill(text: addon.tag, color: .grey(translucent: true), colorLevel: .one)
                    .hFieldSize(.small)
            }
            if let subTitle = addon.subTitle {
                hText(subTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }

            if changeAddonVm.selectedAddonId == addon.id.uuidString && changeAddonVm.hasCoverageDays {

                let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
                DropdownView(
                    value: String(changeAddonVm.getSelectedCoverageDays?.nbOfDays ?? 0) + " dagar",
                    placeHolder: "Välj skydd"
                ) {
                    let id = changeAddonVm.selectedAddonId
                    changeAddonNavigationVm.isChangeCoverageDaysPresented = changeAddonVm.getAddonFor(id: id ?? "")
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
    @Published var selectedAddonId: String? {
        didSet {
            selectedCoverageDayId =
                selectedCoverageDayId ?? getAddonFor(id: selectedAddonId ?? "")?.coverageDays?.first?.id.uuidString
        }
    }
    @Published var selectedCoverageDayId: String?
    @Published var addons: [AddonModel]?

    var hasCoverageDays: Bool {
        let selectedAddOn = addons?.first(where: { $0.id.uuidString == selectedAddonId })
        return selectedAddOn?.coverageDays?.count ?? 0 > 0
    }

    init() {
        Task {
            await getAddons()

            self._selectedAddonId = Published(
                initialValue: addons?.first(where: { $0.coverageDays == nil })?.id.uuidString
            )
        }
    }

    func getAddonFor(id: String) -> AddonModel? {
        return addons?.first(where: { $0.id.uuidString == selectedAddonId })
    }

    var getSelectedCoverageDays: CoverageDays? {
        let selectedAddon = getAddonFor(id: selectedAddonId ?? "")
        let coverageDay = selectedAddon?.coverageDays?
            .first(where: {
                $0.id.uuidString == selectedCoverageDayId
            })
        return coverageDay
    }

    @MainActor
    func getAddons() async {
        do {
            let data = try await addonService.getAddons()

            withAnimation {
                self.addons = data
            }
        } catch {

        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonScreen(changeAddonVm: .init())
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(contractId: "contractId")))
}
