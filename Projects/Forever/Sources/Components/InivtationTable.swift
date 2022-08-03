import Foundation
import SwiftUI
import hCore
import hCoreUI

extension ForeverInvitation {
    var imageAsset: ImageAsset {
        switch self.state {
        case .active:
            return Asset.activeInvite
        case .pending:
            return Asset.pendingInvite
        case .terminated:
            return Asset.terminatedInvite
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
                    hRow {
                        HStack {
                            Image(uiImage: row.imageAsset.image).resizable().frame(width: 18, height: 18)
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
                }
                .withHeader {
                    hText(L10n.ReferralsActive.Invited.title, style: .title3)
                }
                .sectionContainerStyle(.transparent)
            }
        }

    }
}
