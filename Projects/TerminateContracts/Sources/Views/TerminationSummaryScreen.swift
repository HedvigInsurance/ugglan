import SwiftUI
import hCore
import hCoreUI

struct TerminationSummaryScreen: View {
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init() {}

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
                            bottomComponent: {
                                bottomContent
                            }
                        )
                        .hCardWithoutSpacing
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
    private var bottomContent: some View {
        if Dependencies.featureFlags().isAddonsEnabled {
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.terminationAddonCoverageTitle)
                Group {
                    HStack {
                        hText("Travel Plus")
                        Spacer()
                        hText("45 days")
                    }
                    HStack {
                        hText("Bicycle Plus")
                        Spacer()
                        hText("Pinarello Dogma FG1...")
                    }
                }
                .foregroundColor(hTextColor.Opaque.secondary)
            }
            .padding(.top, .padding16)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    TerminationSummaryScreen()
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
