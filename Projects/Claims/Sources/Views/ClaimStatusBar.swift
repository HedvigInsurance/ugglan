import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatusBar: View {
    let status: ClaimModel.ClaimStatusProgressSegment

    @hColorBuilder var barColor: some hColor {
        switch status.type {
        case .currentlyActive:
            hTextColorNew.primary
        case .pastInactive:
            hTextColorNew.secondary
        case .paid:
            hSignalColorNew.blueElement
        case .reopened:
            hSignalColorNew.amberElement
        case .futureInactive:
            hTextColorNew.tertiary
        case .none:
            hLabelColor.primary
        }
    }

    @hColorBuilder var textColor: some hColor {
        switch status.type {
        case .currentlyActive:
            hTextColorNew.primary
        case .pastInactive:
            hTextColorNew.secondary
        case .paid:
            hTextColorNew.primary
        case .reopened:
            hTextColorNew.primary
        case .futureInactive:
            hTextColorNew.tertiary
        case .none:
            hTextColorNew.primary
        }
    }

    var body: some View {
        VStack {
            Rectangle()
                .fill(barColor)
                .frame(height: 4)
                .cornerRadius(2)
            hText(status.text, style: .standardSmall)
                .foregroundColor(textColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
struct ClaimStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ClaimStatusBar(status: .init(text: "currently Active", type: .currentlyActive))
            ClaimStatusBar(status: .init(text: "future Inactive", type: .futureInactive))
            ClaimStatusBar(status: .init(text: "paid", type: .paid))
            ClaimStatusBar(status: .init(text: "past Inactive", type: .pastInactive))
            ClaimStatusBar(status: .init(text: "reopened", type: .reopened))
        }
    }
}
