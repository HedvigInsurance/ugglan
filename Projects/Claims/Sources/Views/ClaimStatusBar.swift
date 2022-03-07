import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatusBar: View {
    let status: Claim.ClaimStatusProgressSegment

    @hColorBuilder var barColor: some hColor {
        switch status.type {
        case .currentlyActive:
            hLabelColor.primary
        case .pastInactive:
            hLabelColor.secondary
        case .paid:
            hTintColor.lavenderOne
        case .reopened:
            hTintColor.orangeOne
        case .futureInactive:
            hLabelColor.tertiary
        case .none:
            hLabelColor.primary
        }
    }

    @hColorBuilder var textColor: some hColor {
        switch status.type {
        case .paid, .reopened, .currentlyActive, .none:
            hLabelColor.primary
        case .futureInactive:
            hLabelColor.tertiary
        case .pastInactive:
            hLabelColor.secondary
        }
    }

    var body: some View {
        VStack {
            Rectangle()
                .fill(barColor)
                .frame(height: 4)
            hText(status.text, style: .caption1)
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
    }
}
