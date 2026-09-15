import SubmitClaimChat
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

private let tileWidth: CGFloat = 160

struct HomeQuickActionsSection: View {
    let quickActions: [HomeQuickAction]
    @EnvironmentObject private var navigationVm: HomeNavigationViewModel
    @State private var actionInFlight: HomeQuickAction?

    var body: some View {
        if !quickActions.isEmpty {
            VStack(spacing: 0) {
                hSection { EmptyView() }
                    .withHeader(title: L10n.hcQuickActionsTitle)
                    .sectionContainerStyle(.transparent)
                tiles
            }
            .disabled(actionInFlight != nil)
        }
    }

    private var tiles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .padding8) {
                ForEach(quickActions) { action in
                    HomeQuickActionTile(
                        action: action,
                        isLoading: actionInFlight == action
                    ) { await perform(action) }
                    .frame(width: tileWidth)
                }
            }
            .padding(.horizontal, .padding16)
            .fixedSize(horizontal: false, vertical: true)
        }
        .disableScrollClipCompat()
    }

    private func perform(_ action: HomeQuickAction) async {
        guard actionInFlight == nil else { return }
        actionInFlight = action
        defer { actionInFlight = nil }
        log.addUserAction(
            type: .click,
            name: "home quick action",
            attributes: ["action": action.id]
        )

        switch action {
        case let .editInsurance(actions): navigationVm.quickActionsVm.perform(.editInsurance(actions: actions))
        case .changeAddress: navigationVm.quickActionsVm.perform(.changeAddress)
        case .travelCertificate: navigationVm.quickActionsVm.perform(.travelInsurance)
        case let .sickAbroad(deflection): navigationVm.quickActionsVm.perform(.sickAbroad(deflection: deflection))
        case .upgradeCoverage: navigationVm.quickActionsVm.perform(.upgradeCoverage)
        case .inviteFriend: navigationVm.isForeverPresented = true
        case .upcomingPayment: await navigationVm.presentUpcomingPayment()
        }
    }
}

private struct HomeQuickActionTile: View {
    let action: HomeQuickAction
    let isLoading: Bool
    let onTap: () async -> Void

    var body: some View {
        Button {
            ImpactGenerator.light()
            Task { await onTap() }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                action.icon.view
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)
                Spacer(minLength: .padding6)
                hText(action.title, style: .finePrint)
            }
            .opacity(isLoading ? 0.75 : 1)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
            .padding(.padding14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusXL)
                    .fill(hFillColor.Opaque.negative)
            }
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusXL)
                    .stroke(hBorderColor.primary, lineWidth: 1)
            }
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
        }
        .buttonStyle(HomeQuickActionTileStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

private struct HomeQuickActionTileStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)

    let previewEditActions = EditInsuranceActionsWrapper(quickActions: [.editCoInsured, .upgradeCoverage])
    let previewDeflection = Deflection(
        title: nil,
        content: .init(title: "", description: ""),
        partners: [],
        infoText: nil,
        warningText: nil,
        questions: [],
        linkOnlyPartners: [],
        buttonTitle: ""
    )
    return HomeQuickActionsSection(
        quickActions: [
            .editInsurance(previewEditActions),
            .changeAddress,
            .travelCertificate,
            .sickAbroad(previewDeflection),
            .upgradeCoverage,
            .inviteFriend,
            .upcomingPayment,
        ]
    )
    .environmentObject(HomeNavigationViewModel())
}
