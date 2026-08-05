import SubmitClaimChat
import SwiftUI
import hCore
import hCoreUI

struct HomeQuickActionsSection: View {
    let quickActions: [QuickAction]
    @EnvironmentObject private var navigationVm: HomeNavigationViewModel
    @State private var rowWidth: CGFloat = 0

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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .padding8) {
                ForEach(quickActions, id: \.displayTitle) { action in
                    tile(action)
                        // Before the first measurement a fixed width would collapse the row to nothing.
                        .frame(width: rowWidth > 0 ? tileWidth : nil)
                }
            }
            // The scroll view clips at its bounds, which the tile shadows fall outside of.
            .padding(.vertical, .padding8)
            .padding(.horizontal, .padding16)
        }
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { rowWidth = $0 }
    }

    /// Exactly three tiles per viewport: the row width less the two gaps between them.
    /// Only meaningful once `rowWidth` is measured -- call sites guard on `rowWidth > 0`.
    private var tileWidth: CGFloat {
        let gaps: CGFloat = .padding8 * 2
        let horizontalPadding: CGFloat = .padding16 * 2
        return (rowWidth - gaps - horizontalPadding) / 3
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

#Preview("Six actions") {
    Localization.Locale.currentLocale.send(.en_SE)

    return HomeQuickActionsSection(
        quickActions: [
            .editInsurance(actions: .init(quickActions: [.editCoInsured, .upgradeCoverage])),
            .changeAddress,
            .travelInsurance,
            .connectPayments,
            .firstVet(partners: []),
            .sickAbroad(
                deflection: .init(
                    title: "Sick abroad",
                    content: .init(title: "Sick abroad", description: "Contact our partner"),
                    partners: [],
                    infoText: nil,
                    warningText: nil,
                    questions: [],
                    linkOnlyPartners: [],
                    buttonTitle: "Continue"
                )
            ),
        ]
    )
    .environmentObject(HomeNavigationViewModel())
}
