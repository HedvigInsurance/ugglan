import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension Referral {
    @hColorBuilder var statusColor: some hColor {
        switch self.status {
        case .active:
            hSignalColor.Green.element
        case .pending:
            hSignalColor.Amber.element
        case .terminated:
            hSignalColor.Red.element
        }
    }

    @hColorBuilder var discountLabelColor: some hColor {
        switch self.status {
        case .active:
            hTextColor.Opaque.secondary
        case .pending, .terminated:
            hTextColor.Opaque.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch self.status {
        case .active, .pending:
            hTextColor.Opaque.tertiary
        case .terminated:
            hTextColor.Opaque.tertiary
        }
    }

    var discountLabelText: String {
        switch self.status {
        case .active:
            return self.activeDiscount?.negative.formattedAmount ?? ""
        case .pending:
            return L10n.referralPendingStatusLabel
        case .terminated:
            return L10n.referralTerminatedStatusLabel
        }
    }
}

struct InvitationTable: View {
    @PresentableStore var store: ForeverStore

    var body: some View {
        PresentableStoreLens(
            ForeverStore.self,
            getter: { state in
                state.foreverData
            }
        ) { foreverData in
            if let foreverData,
                !foreverData.referrals.isEmpty || foreverData.referredBy != nil
                    || foreverData.otherDiscounts?.floatAmount ?? 0 > 0
                    || foreverData.grossAmount.amount != foreverData.netAmount.amount
            {
                hSection(getInvitationRows(for: foreverData), id: \.id) { row in
                    row.view
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
                .padding(.vertical, .padding16)
            }
        }
    }
    private func getInvitationRows(for foreverData: ForeverData) -> [(id: String, view: AnyView)] {
        var list: [(id: String, view: AnyView)] = []
        if !foreverData.referrals.isEmpty || foreverData.referredBy != nil {
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
        }
        return list
    }
}

struct InvitationRow: View {
    let row: Referral
    let invitedYou: Bool

    var body: some View {
        hRow {
            HStack(alignment: .top, spacing: 8) {
                Circle().fill(row.statusColor)
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
                .foregroundColor(row.discountLabelColor)
        }
    }
}

struct InvitationTable_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore

    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return InvitationTable()
            .onAppear {
                store.send(
                    .setForeverData(
                        data: .init(
                            grossAmount: .sek(200),
                            netAmount: .sek(160),
                            otherDiscounts: .sek(20),
                            discountCode: "CODE",
                            monthlyDiscount: .sek(20),
                            referrals: [
                                .init(name: "First", activeDiscount: .sek(10), status: .active),
                                .init(name: "Second", activeDiscount: .sek(10), status: .pending),
                                .init(name: "Third", activeDiscount: .sek(10), status: .terminated),
                            ],
                            referredBy: .init(name: "", activeDiscount: nil, status: .active),
                            monthlyDiscountPerReferral: .sek(10)
                        )
                    )
                )
            }
    }
}

struct InvitationRow_Previews: PreviewProvider {
    static var mockRow: Referral = .init(
        name: "Axel",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .active
    )
    static var mockRow2: Referral = .init(
        name: "Mock",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .active
    )

    static var mockRow3: Referral = .init(
        name: "Mock",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .pending
    )

    static var mockRow4: Referral = .init(
        name: "Mock withc long name that needs two rows",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .terminated
    )

    static var previews: some View {

        Localization.Locale.currentLocale.send(.en_SE)
        return hSection {
            InvitationRow(row: mockRow, invitedYou: false)
            InvitationRow(row: mockRow2, invitedYou: false)
            InvitationRow(row: mockRow3, invitedYou: false)
            InvitationRow(row: mockRow4, invitedYou: false)
        }
        .sectionContainerStyle(.transparent)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
