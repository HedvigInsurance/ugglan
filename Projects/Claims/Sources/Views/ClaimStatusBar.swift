import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatusBar: View {
    let status: ClaimModel.ClaimStatus

    @hColorBuilder var barColor: some hColor {
        switch status {
        case .none:
            hSignalColor.redElement
        case .submitted:
            hTextColor.secondary
        case .beingHandled:
            hTextColor.primary
        case .closed:
            hTextColor.tertiary
        case .reopened:
            hTextColor.secondary
        }
    }

    @hColorBuilder var textColor: some hColor {
//        switch status.type {
//        case .currentlyActive:
//            hTextColor.primary
//        case .pastInactive:
            hTextColor.secondary
//        case .paid:
//            hTextColor.primary
//        case .reopened:
//            hTextColor.primary
//        case .futureInactive:
//            hTextColor.tertiary
//        case .none:
//            hTextColor.primary
//        }
    }

    var body: some View {
        VStack {
            Rectangle()
                .fill(barColor)
                .frame(height: 4)
                .cornerRadius(2)
            hText(status.title, style: .standardSmall)
                .foregroundColor(textColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
struct ClaimStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
//            ClaimStatusBar(status: .init(text: "currently Active", type: .currentlyActive))
//            ClaimStatusBar(status: .init(text: "future Inactive", type: .futureInactive))
//            ClaimStatusBar(status: .init(text: "paid", type: ClaimModel.ClaimOutcome.paid))
//            ClaimStatusBar(status: .init(text: "past Inactive", type: .pastInactive))
//            ClaimStatusBar(status: .init(text: "reopened", type: .reopened))
        }
    }
}
