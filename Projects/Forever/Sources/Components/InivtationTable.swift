import Foundation
import SwiftUI
import hCore
import hCoreUI

struct InvitationTable: View {
    @StateObject var vm: InvitationTableViewModel

    init(
        foreverData: ForeverData?
    ) {
        _vm = StateObject(wrappedValue: .init(foreverData: foreverData))
    }

    var body: some View {
        if let foreverData = vm.foreverData, vm.showInvitations {
            hSection(getInvitationRows(for: foreverData), id: \.id) { row in
                row.view
            }
            .hWithoutHorizontalPadding([.section])
            .sectionContainerStyle(.transparent)
            .padding(.vertical, .padding16)
        }
    }

    private func getInvitationRows(for foreverData: ForeverData) -> [(id: String, view: AnyView)] {
        var list: [(id: String, view: AnyView)] = []
        let headerView = AnyView(hRow { hText(L10n.foreverReferralListLabel) })
        list.append(("header", headerView))

        if let referredBy = foreverData.referredBy {
            let view = AnyView(InvitationRow(row: referredBy, invitedYou: true))
            list.append(("\(referredBy.name)", view))
        }

        for referral in foreverData.referrals {
            let view = AnyView(InvitationRow(row: referral, invitedYou: false))
            list.append(("\(referral.name)", view))
        }
        return list
    }
}

class InvitationTableViewModel: ObservableObject {
    let foreverData: ForeverData?
    @Published var showInvitations = false

    init(
        foreverData: ForeverData?
    ) {
        self.foreverData = foreverData
        setShowInvitations()
    }

    private func setShowInvitations() {
        if let foreverData = foreverData,
            !foreverData.referrals.isEmpty || foreverData.referredBy != nil
                || foreverData.otherDiscounts?.floatAmount ?? 0 > 0
                || foreverData.grossAmount.amount != foreverData.netAmount.amount
        {
            showInvitations = true
        }
    }
}

struct InvitationRow: View {
    let row: Referral
    let invitedYou: Bool

    var body: some View {
        hRow {
            HStack(alignment: .top, spacing: .padding8) {
                Circle().fill(row.status.statusColor)
                    .frame(width: 14, height: 14)
                    .padding(.top, 5)
                VStack(alignment: .leading) {
                    hText(row.name)
                        .foregroundColor(hTextColor.Opaque.primary)
                    if invitedYou {
                        hText(L10n.ReferallsInviteeStates.invitedYou)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                .frame(alignment: .top)
                Spacer()
            }
        }
        .withCustomAccessory {
            hText(row.discountLabelText)
                .foregroundColor(row.status.discountLabelColor)
        }
    }
}

#Preview("Invitation Table") {
    Localization.Locale.currentLocale.send(.en_SE)
    let navigationVm = ForeverNavigationViewModel()
    return InvitationTable(foreverData: navigationVm.foreverData).environmentObject(navigationVm)
}

#Preview("Invitation Row") {
    var mockRow: Referral = .init(
        name: "Axel",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .active
    )
    var mockRow2: Referral = .init(
        name: "Mock",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .active
    )

    var mockRow3: Referral = .init(
        name: "Mock",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .pending
    )

    var mockRow4: Referral = .init(
        name: "Mock withc long name that needs two rows",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .terminated
    )

    Localization.Locale.currentLocale.send(.en_SE)
    return hSection {
        InvitationRow(row: mockRow, invitedYou: false)
        InvitationRow(row: mockRow2, invitedYou: false)
        InvitationRow(row: mockRow3, invitedYou: false)
        InvitationRow(row: mockRow4, invitedYou: false)
    }
    .sectionContainerStyle(.transparent)
    .previewLayout(PreviewLayout.sizeThatFits)
    .environmentObject(ForeverNavigationViewModel())
}
