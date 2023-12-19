import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ReferralsView: View {
    let referrals: [Referral]
    var body: some View {
        hForm {
            hSection(referrals) { referral in
                hRow {
                    ReferralView(referral: referral)
                }
                .withChevronAccessory
                .hWithoutHorizontalPadding
                .dividerInsets(.all, 0)
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension ReferralsView {
    static var journey: some JourneyPresentation {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        let referrals = store.state.paymentDiscountsData?.referralsData.referrals ?? []
        return HostingJourney(
            rootView: ReferralsView(referrals: referrals)
        )
        .configureTitle(L10n.foreverReferralListLabel)
    }
}

struct ReferralsView_Previews: PreviewProvider {
    static var previews: some View {
        ReferralsView(
            referrals: [
                .init(id: "id1", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id2", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id3", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id4", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id5", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id6", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id7", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id8", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id9", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id10", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id11", name: "Name pending", status: .pending),
                .init(id: "id12", name: "Name terminated", status: .terminated),
                .init(id: "id13", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id14", name: "Name", activeDiscount: .sek(10), status: .active),
                .init(id: "id15", name: "Name", activeDiscount: .sek(10), status: .active),

            ]
        )
    }
}
