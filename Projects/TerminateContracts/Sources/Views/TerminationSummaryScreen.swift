import SwiftUI
import hCore
import hCoreUI

struct TerminationSummaryScreen: View {
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init() {}

    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    L10n.terminationFlowCancellationTitle,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .heading2,
                    L10n.terminationFlowSummarySubtitle
                )
            )
            .hFormAttachToBottom {
                let withAddonView =
                    Dependencies.featureFlags().isAddonsEnabled && !terminationNavigationVm.extraCoverage.isEmpty

                VStack(spacing: .padding16) {
                    hSection {
                        StatusCard(
                            onSelected: {},
                            mainContent: mainContent,
                            bottomComponent: !withAddonView
                                ? nil
                                : {
                                    addonContent
                                }
                        )
                        .hCardWithoutSpacing
                        .hCardWithDivider
                    }

                    hSection {
                        VStack(spacing: .padding8) {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: L10n.terminationButton),
                                { [weak terminationNavigationVm] in
                                    terminationNavigationVm?.isConfirmTerminationPresented = true
                                }
                            )
                            hButton(
                                .large,
                                .ghost,
                                content: .init(title: L10n.terminationKeepInsuranceButton),
                                { [weak terminationNavigationVm] in
                                    terminationNavigationVm?.router.dismiss()
                                }
                            )
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        HStack(spacing: .padding12) {
            let image =
                terminationNavigationVm.config?.typeOfContract?.pillowType.bgImage ?? hCoreUIAssets.pillowHome.view

            image
                .resizable()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                hText(terminationNavigationVm.config?.contractDisplayName ?? "")
                hText(terminationNavigationVm.config?.contractExposureName ?? "")
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
    }

    private var addonContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.terminationAddonCoverageTitle)
            ForEach(terminationNavigationVm.extraCoverage, id: \.self) { item in
                getRow(for: item)
            }
        }
    }

    private func getRow(for item: ExtraCoverageItem) -> some View {
        HStack {
            hText(item.displayName)
            Spacer()
            if let displayValue = item.displayValue {
                hText(displayValue)
            }
        }
        .foregroundColor(hTextColor.Translucent.secondary)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
    return TerminationSummaryScreen()
        .environmentObject(
            TerminationFlowNavigationViewModel(
                configs: [
                    .init(
                        contractId: "",
                        contractDisplayName: "Homeowner",
                        contractExposureName: "Bellmansgsatan 19A",
                        activeFrom: "2024-12-15",
                        typeOfContract: .seApartmentBrf
                    )
                ],
                terminateInsuranceViewModel: .init()
            )
        )
}
