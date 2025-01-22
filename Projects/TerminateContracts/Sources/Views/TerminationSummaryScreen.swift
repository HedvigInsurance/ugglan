import SwiftUI
import hCore
import hCoreUI

struct TerminationSummaryScreen: View {
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init() {}

    var body: some View {
        hUpdatedForm {}
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
                            title: nil,
                            subTitle: nil,
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
                            hButton.LargeButton(type: .primary) { [weak terminationNavigationVm] in
                                terminationNavigationVm?.isConfirmTerminationPresented = true
                            } content: {
                                hText(L10n.terminationButton)
                            }

                            hButton.LargeButton(type: .ghost) { [weak terminationNavigationVm] in
                                terminationNavigationVm?.router.dismiss()
                            } content: {
                                hText(L10n.terminationKeepInsuranceButton)
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        HStack(spacing: .padding12) {
            Image(
                uiImage: terminationNavigationVm.config?.typeOfContract?.pillowType.bgImage
                    ?? hCoreUIAssets.pillowHome.image
            )
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
