import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension ForeverInvitation {
    var image: UIImage {
        switch self.state {
        case .active:
            return hCoreUIAssets.basketball.image
        case .pending:
            return hCoreUIAssets.circularClock.image
        case .terminated:
            return hCoreUIAssets.circularCross.image
        }
    }

    @hColorBuilder var nameLabelColor: some hColor {
        switch self.state {
        case .active, .pending:
            hLabelColor.primary
        case .terminated:
            hLabelColor.tertiary
        }
    }

    @hColorBuilder var discountLabelColor: some hColor {
        switch self.state {
        case .active:
            hLabelColor.primary
        case .pending, .terminated:
            hLabelColor.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch self.state {
        case .active, .pending:
            hLabelColor.secondary
        case .terminated:
            hLabelColor.tertiary
        }
    }

    var discountLabelText: String {
        switch self.state {
        case .active:
            return self.discount?.formattedAmount ?? ""
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
                state.foreverData?.invitations ?? []
            }
        ) { invitations in
            if !invitations.isEmpty {
                hSection(invitations, id: \.name) { row in
                    InvitationRow(row: row)
                }
                .withHeader {
                    hText(L10n.ReferralsActive.Invited.title, style: .title3)
                }
                .sectionContainerStyle(.transparent)
            }
        }

    }
}

struct InvitationRow: View {
    let row: ForeverInvitation

    var body: some View {
        hRow {
            HStack {
                Image(uiImage: row.image).resizable().frame(width: 18, height: 18)
                VStack(alignment: .leading) {
                    hText(row.name).foregroundColor(row.nameLabelColor)
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
        .verticalPadding(row.invitedByOther ? 14 : 21)
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

    static var previews: some View {
        hSection {
            InvitationRow(row: mockRow2)
            InvitationRow(row: mockRow)
            InvitationRow(row: mockRow2)
            InvitationRow(row: mockRow2)
        }
        .sectionContainerStyle(.transparent)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
