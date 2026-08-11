import SubmitClaimChat
import SwiftUI
import hCore
import hCoreUI

struct HomeQuickActionsSection: View {
    let quickActions: [QuickAction]
    @EnvironmentObject private var navigationVm: HomeNavigationViewModel

    var body: some View {
        if !quickActions.isEmpty {
            VStack(spacing: 0) {
                hSection { EmptyView() }
                    .withHeader(title: L10n.hcQuickActionsTitle)
                    .sectionContainerStyle(.transparent)
                tiles
            }
        }
    }

    @ViewBuilder private var tiles: some View {
        HStack(spacing: .padding8) {
            ForEach(quickActions.prefix(3), id: \.displayTitle) { action in
                tile(action)
                    .frame(maxWidth: .infinity)
            }
            ForEach(0..<max(0, 3 - quickActions.count), id: \.self) { _ in
                Color.clear
                    .frame(maxWidth: .infinity)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, .padding16)
    }

    private func tile(_ action: QuickAction) -> some View {
        QuickActionTile(action: action) { perform(action) }
    }

    private func perform(_ action: QuickAction) {
        log.addUserAction(
            type: .click,
            name: "home quick action",
            attributes: ["action": action.id]
        )
        navigationVm.quickActionsVm.perform(action)
    }
}

private struct QuickActionTile: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button {
            ImpactGenerator.soft()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: .padding6) {
                action.icon.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(hFillColor.Opaque.primary)
                    .accessibilityHidden(true)

                hText(action.displayTitle, style: .label)
            }
            .padding(.vertical, .padding14)
            .padding(.horizontal, .padding12)
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
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(action.displaySubtitle)
    }
}

@MainActor
extension QuickAction {
    fileprivate var icon: ImageAsset {
        switch self {
        case .editInsurance: hCoreUIAssets.settings
        case .changeAddress: hCoreUIAssets.reload
        case .travelInsurance: hCoreUIAssets.travel
        case .connectPayments: hCoreUIAssets.payments
        case .firstVet: hCoreUIAssets.firstVet
        case .sickAbroad: hCoreUIAssets.infoOutlined
        case .editCoInsured: hCoreUIAssets.id
        case .editCoOwners: hCoreUIAssets.id
        case .upgradeCoverage: hCoreUIAssets.shieldOutlined
        case .cancellation: hCoreUIAssets.close
        case .removeAddons: hCoreUIAssets.minus
        }
    }
}

#Preview("Three actions") {
    Localization.Locale.currentLocale.send(.en_SE)

    return HomeQuickActionsSection(
        quickActions: [
            .editInsurance(actions: .init(quickActions: [.editCoInsured, .upgradeCoverage])),
            .changeAddress,
            .travelInsurance,
        ]
    )
    .environmentObject(HomeNavigationViewModel())
}

#Preview("Two actions") {
    Localization.Locale.currentLocale.send(.en_SE)

    return HomeQuickActionsSection(
        quickActions: [
            .changeAddress,
            .travelInsurance,
        ]
    )
    .environmentObject(HomeNavigationViewModel())
}

#Preview("Three actions - accessibility3") {
    Localization.Locale.currentLocale.send(.en_SE)

    return HomeQuickActionsSection(
        quickActions: [
            .editInsurance(actions: .init(quickActions: [.editCoInsured, .upgradeCoverage])),
            .changeAddress,
            .travelInsurance,
        ]
    )
    .environmentObject(HomeNavigationViewModel())
    .environment(\.dynamicTypeSize, .accessibility3)
}
