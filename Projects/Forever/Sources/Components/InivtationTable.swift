import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension Referral {
    @hColorBuilder var statusColor: some hColor {
        switch self.status {
        case .active:
            hSignalColorNew.greenElement
        case .pending:
            hSignalColorNew.amberElement
        case .terminated:
            hSignalColorNew.redElement
        }
    }

    @hColorBuilder var discountLabelColor: some hColor {
        switch self.status {
        case .active:
            hTextColorNew.primary
        case .pending, .terminated:
            hTextColorNew.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch self.status {
        case .active, .pending:
            hTextColorNew.tertiary
        case .terminated:
            hTextColorNew.tertiary
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
            if let foreverData {
                hSection {
                    if !foreverData.referrals.isEmpty {
                        hRow {
                            hText(L10n.foreverReferralListLabel)
                        }
                        .noHorizontalPadding()
                        ForEach(foreverData.referrals, id: \.hashValue) { row in
                            InvitationRow(row: row)
                        }
                    }
                    getOtherDiscountsRow(foreverData)
                    getTotalRow(foreverData)
                }
                .sectionContainerStyle(.transparent)
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
                hText(L10n.foreverTabTotalDiscountLabel)
            }
            .withCustomAccessory {
                HStack {
                    Spacer()
                    getGrossField(foreverData.grossAmount.formattedAmount.addPerMonth)
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
    let row: Referral

    var body: some View {
        hRow {
            HStack(spacing: 8) {
                Circle().fill(row.statusColor).frame(width: 14, height: 14)
                VStack(alignment: .leading) {
                    hText(row.name).foregroundColor(hTextColorNew.primary)
                    // TODO
                    hText(L10n.ReferallsInviteeStates.invitedYou, style: .subheadline)
                        .foregroundColor(row.invitedByOtherLabelColor)
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
        Localization.Locale.currentLocale = .en_SE
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
        name: "Mock",
        activeDiscount: MonetaryAmount(amount: "10.0", currency: "SEK"),
        status: .terminated
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
