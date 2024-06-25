import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatusBar: View {
    let status: ClaimModel.ClaimStatus
    let outcome: ClaimModel.ClaimOutcome

    @hColorBuilder func barColor(segment: ClaimModel.ClaimStatus) -> some hColor {
        switch status {
        case .submitted:
            if segment == .submitted {
                hSignalColor.Green.element
            } else {
                hFillColor.Opaque.disabled
            }
        case .beingHandled:
            switch segment {
            case .submitted:
                hSignalColor.Green.element
            case .beingHandled:
                if outcome == .missingReceipt {
                    hSignalColor.Amber.element
                } else {
                    hSignalColor.Green.element
                }
            default:
                hFillColor.Opaque.disabled
            }
        case .closed:
            if outcome == .paid {
                hSignalColor.Green.element
            } else {
                hSignalColor.Green.element
            }
        case .reopened:
            switch segment {
            case .submitted:
                hSignalColor.Green.element
            case .beingHandled:
                if outcome == .missingReceipt {
                    hSignalColor.Amber.element
                } else {
                    hSignalColor.Green.element
                }
            default:
                hFillColor.Opaque.disabled
            }
        default:
            hFillColor.Opaque.disabled
        }
    }

    @hColorBuilder func textColor(segment: ClaimModel.ClaimStatus) -> some hColor {
        if outcome == .paid {
            hTextColor.Opaque.primary
        } else {
            switch status {
            case .submitted:
                if segment == .submitted {
                    hTextColor.Opaque.primary
                } else {
                    hTextColor.Opaque.tertiary
                }
            case .beingHandled:
                switch segment {
                case .submitted, .beingHandled:
                    hTextColor.Opaque.primary
                default:
                    hTextColor.Opaque.tertiary
                }
            case .reopened:
                switch segment {
                case .submitted, .beingHandled:
                    hTextColor.Opaque.primary
                default:
                    hTextColor.Opaque.tertiary
                }
            case .closed:
                hTextColor.Opaque.primary
            default:
                hTextColor.Opaque.tertiary
            }
        }
    }

    var body: some View {
        ForEach(ClaimModel.ClaimStatus.allCases, id: \.title) { segment in
            if !(segment == .none || segment == .reopened) {
                VStack {
                    Rectangle()
                        .fill(barColor(segment: segment))
                        .frame(height: 4)
                        .cornerRadius(.cornerRadiusXS)
                    hText(segment.title, style: .standardSmall)
                        .foregroundColor(textColor(segment: segment))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ClaimStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                ClaimStatusBar(status: .submitted, outcome: .none)
            }
            HStack {
                ClaimStatusBar(status: .beingHandled, outcome: .none)
            }
            HStack {
                ClaimStatusBar(status: .closed, outcome: .paid)
            }
            HStack {
                ClaimStatusBar(status: .closed, outcome: .notCovered)
            }
            HStack {
                ClaimStatusBar(status: .closed, outcome: .notCompensated)
            }
            HStack {
                ClaimStatusBar(status: .beingHandled, outcome: .missingReceipt)
            }
        }
    }
}
