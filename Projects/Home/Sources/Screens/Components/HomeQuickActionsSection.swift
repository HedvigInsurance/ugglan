import Payment
import SubmitClaimChat
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

private let tileWidth: CGFloat = 160

struct HomeQuickActionsSection: View {
    let quickActions: [HomeQuickAction]
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

    private var tiles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .padding8) {
                ForEach(quickActions) { action in
                    HomeQuickActionTile(action: action) { perform(action) }
                        .frame(width: tileWidth)
                }
            }
            .padding(.horizontal, .padding16)
            .fixedSize(horizontal: false, vertical: true)
        }
        .disableScrollClipCompat()
    }

    private func perform(_ action: HomeQuickAction) {
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
        case let .upcomingPayment(upcomingPaymentData): navigationVm.isUpcomingPaymentPresented = upcomingPaymentData
        }
    }
}

private struct HomeQuickActionTile: View {
    let action: HomeQuickAction
    let onTap: () -> Void

    var body: some View {
        Button {
            ImpactGenerator.soft()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                action.icon.view
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hFillColor.Opaque.primary)
                    .accessibilityHidden(true)
                Spacer(minLength: .padding6)
                hText(action.title, style: .finePrint)
            }
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
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
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
    let previewPaymentData = PaymentData(
        id: "preview",
        payment: .init(
            gross: .sek(400),
            net: .sek(370),
            carriedAdjustment: nil,
            settlementAdjustment: nil,
            date: "2026-09-27"
        ),
        status: .upcoming,
        contracts: [],
        referralDiscount: nil,
        amountPerReferral: .sek(10),
        payinMethod: nil,
        addedToThePayment: nil
    )

    return HomeQuickActionsSection(
        quickActions: [
            .editInsurance(previewEditActions),
            .changeAddress,
            .travelCertificate,
            .sickAbroad(previewDeflection),
            .upgradeCoverage,
            .inviteFriend,
            .upcomingPayment(previewPaymentData),
        ]
    )
    .environmentObject(HomeNavigationViewModel())
}
