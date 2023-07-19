import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension ForeverInvitation {
    @hColorBuilder var statusColor: some hColor {
        switch self.state {
        case .active:
            hSignalColorNew.greenElement
        case .pending:
            hSignalColorNew.amberElement
        case .terminated:
            hSignalColorNew.redElement
        }
    }

    @hColorBuilder var discountLabelColor: some hColor {
        switch self.state {
        case .active:
            hTextColorNew.primary
        case .pending, .terminated:
            hTextColorNew.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch self.state {
        case .active, .pending:
            hTextColorNew.tertiary
        case .terminated:
            hTextColorNew.tertiary
        }
    }

    var discountLabelText: String {
        switch self.state {
        case .active:
            return self.discount?.negative.formattedAmount ?? ""
        case .pending:
            return L10n.ReferallsInviteeStates.awaiting
        case .terminated:
            return L10n.ReferallsInviteeStates.terminated
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
            if let foreverData {
                if !foreverData.invitations.isEmpty {
                    hSection {
                        hRow {
                            hText(L10n.ReferralsActive.Invited.title)
                        }
                        ForEach(foreverData.invitations, id: \.hashValue) { row in
                            InvitationRow(row: row)
                        }
                        getOtherDiscountsRow(foreverData)
                        getTotalRow(foreverData)
                    }
                    .sectionContainerStyle(.transparent)
                    .padding(.horizontal, -16)
                }
            }
        }
    }

    @ViewBuilder
    private func getOtherDiscountsRow(_ foreverData: ForeverData) -> some View {
        if let otherDiscounts = foreverData.otherDiscounts {
            hRow {
                hText(L10n.Referrals.yourOtherDiscounts)
            }
            .withCustomAccessory {
                HStack {
                    Spacer()
                    hText("\(otherDiscounts.negative.formattedAmount)")
                }
            }
        }
    }

    @ViewBuilder
    private func getTotalRow(_ foreverData: ForeverData) -> some View {
        if foreverData.grossAmount.amount != foreverData.netAmount.amount {
            hRow {
                hText(L10n.PaymentDetails.ReceiptCard.total)
            }
            .withCustomAccessory {
                HStack {
                    Spacer()
                    getGrossField(foreverData.grossAmount.formattedAmount)
                    hText("\(foreverData.netAmount.formattedAmount)/\(L10n.monthAbbreviationLabel)")
                }
            }
            .hWithoutDivider
        }
    }

    @ViewBuilder
    private func getGrossField(_ text: String) -> some View {
        if #available(iOS 15.0, *) {
            Text(attributedString(text))
                .foregroundColor(hTextColorNew.secondary)
                .modifier(hFontModifier(style: .standard))
        } else {
            hText(text).foregroundColor(hTextColorNew.secondary)
        }
    }

    @available(iOS 15, *)
    private func attributedString(_ text: String) -> AttributedString {
        let attributes = AttributeContainer([NSAttributedString.Key.strikethroughStyle: 1])
        let result = AttributedString(text, attributes: attributes)
        return result
    }
}

struct InvitationRow: View {
    let row: ForeverInvitation

    var body: some View {
        hRow {
            HStack(spacing: 8) {
                Circle().fill(row.statusColor).frame(width: 14, height: 14)
                VStack(alignment: .leading) {
                    hText(row.name).foregroundColor(hTextColorNew.primary)
                    if row.invitedByOther {
                        hText(L10n.ReferallsInviteeStates.invitedYou, style: .subheadline)
                            .foregroundColor(row.invitedByOtherLabelColor)
                    }
                }
            }
        }
        .withCustomAccessory({
            Spacer()
            hText(row.discountLabelText).foregroundColor(row.discountLabelColor)
        })
    }
}

struct InvitationTable_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore

    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        return InvitationTable()
            .onAppear {
                store.send(
                    .setForeverData(
                        data: .init(
                            grossAmount: .sek(200),
                            netAmount: .sek(160),
                            potentialDiscountAmount: .sek(50),
                            otherDiscounts: .sek(20),
                            discountCode: "CODE",
                            invitations: [
                                .init(name: "First", state: .active, discount: .sek(20), invitedByOther: true),
                                .init(name: "Second", state: .active, invitedByOther: false),
                                .init(name: "Third", state: .terminated, invitedByOther: false),
                            ]
                        )
                    )
                )
            }
    }
}

struct InvitationRow_Previews: PreviewProvider {
    static var mockRow: ForeverInvitation = .init(
        name: "Axel",
        state: .active,
        discount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        invitedByOther: true
    )
    static var mockRow2: ForeverInvitation = .init(
        name: "Mock",
        state: .active,
        discount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        invitedByOther: false
    )

    static var mockRow3: ForeverInvitation = .init(
        name: "Mock",
        state: .pending,
        discount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        invitedByOther: false
    )

    static var mockRow4: ForeverInvitation = .init(
        name: "Mock",
        state: .terminated,
        discount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        invitedByOther: false
    )

    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return hSection {
            InvitationRow(row: mockRow)
            InvitationRow(row: mockRow2)
            InvitationRow(row: mockRow3)
            InvitationRow(row: mockRow4)
        }
        .sectionContainerStyle(.transparent)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
