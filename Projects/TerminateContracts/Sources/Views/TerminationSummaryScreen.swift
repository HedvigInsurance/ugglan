import SwiftUI
import hCore
import hCoreUI

struct TerminationSummaryScreen: View {
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel
    let extraCoverageItems: [ExtraCoverageItem]?
    let withAddonView: Bool

    init(
        terminationNavigationVm: TerminationFlowNavigationViewModel
    ) {
        self.terminationNavigationVm = terminationNavigationVm

        self.extraCoverageItems = {
            let dateExtraCoverageItems = terminationNavigationVm.terminationDateStepModel?.extraCoverageItem
            let deletionExtraCoverageItems = terminationNavigationVm.terminationDeleteStepModel?.extraCoverageItem

            if let dateExtraCoverageItems, !dateExtraCoverageItems.isEmpty {
                return dateExtraCoverageItems
            } else if let deletionExtraCoverageItems, !deletionExtraCoverageItems.isEmpty {
                return deletionExtraCoverageItems
            }
            return nil
        }()

        withAddonView = Dependencies.featureFlags().isAddonsEnabled && extraCoverageItems != nil
    }

    var body: some View {
        hForm {}
            .hDisableScroll
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
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }

    @ViewBuilder
    private var addonContent: (some View)? {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.terminationAddonCoverageTitle)
            ForEach(extraCoverageItems ?? [], id: \.self) { item in
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
        .foregroundColor(hTextColor.Opaque.secondary)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
    return TerminationSummaryScreen(
        terminationNavigationVm: TerminationFlowNavigationViewModel(
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
