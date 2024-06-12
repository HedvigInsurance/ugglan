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
                hTextColor.Opaque.primary
            } else {
                hTextColor.Opaque.tertiary
            }
        case .beingHandled:
            switch segment {
            case .submitted:
                hTextColor.Opaque.secondary
            case .beingHandled:
                hTextColor.Opaque.primary
            default:
                hTextColor.Opaque.tertiary
            }
        case .closed:
            if outcome == .paid {
                hSignalColor.Blue.element
            } else {
                hTextColor.Opaque.primary
            }
        case .reopened:
            switch segment {
            case .submitted:
                hTextColor.Opaque.secondary
            case .beingHandled:
                hSignalColor.Amber.element
            default:
                hTextColor.Opaque.tertiary
            }
        default:
            hTextColor.Opaque.secondary
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
                case .submitted:
                    hTextColor.Opaque.secondary
                case .beingHandled:
                    hTextColor.Opaque.primary
                case .closed:
                    hTextColor.Opaque.tertiary
                default:
                    hTextColor.Opaque.tertiary
                }
            case .reopened:
                switch segment {
                case .submitted:
                    hTextColor.Opaque.secondary
                case .beingHandled:
                    hTextColor.Opaque.primary
                default:
                    hTextColor.Opaque.tertiary
                }
            case .closed:
                hTextColor.Opaque.primary
            default:
                hTextColor.Opaque.secondary
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
                        .cornerRadius(2)
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
        HStack {
            ClaimStatusBar(status: .beingHandled, outcome: .none)
            ClaimStatusBar(status: .closed, outcome: .notCompensated)
            ClaimStatusBar(status: .reopened, outcome: .none)
            ClaimStatusBar(status: .submitted, outcome: .none)
            ClaimStatusBar(status: .none, outcome: .none)
        }
    }
}
