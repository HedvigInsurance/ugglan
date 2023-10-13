import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatusBar: View {
    let status: ClaimModel.ClaimStatus
    let outcome: ClaimModel.ClaimOutcome

    @hColorBuilder func barColor(segment: ClaimModel.ClaimStatus) -> some hColor {
        
        if outcome == .paid {
            hSignalColor.blueElement
        } else {
            switch status {
            case .submitted:
                if segment == .submitted {
                    hTextColor.primary
                } else {
                    hTextColor.tertiary
                }
            case .beingHandled:
                switch segment {
                case .submitted:
                    hTextColor.secondary
                case .beingHandled:
                    hTextColor.primary
                default:
                    hTextColor.tertiary
                }
            case .closed:
                hTextColor.primary
            case .reopened:
                switch segment {
                case .submitted:
                    hTextColor.secondary
                case .beingHandled:
                    hSignalColor.amberElement
                default:
                    hTextColor.tertiary
                }
            default:
                hTextColor.secondary
            }
        }
    }

    @hColorBuilder func textColor(segment: ClaimModel.ClaimStatus) -> some hColor {
        if outcome == .paid {
            hTextColor.primary
        } else {
            switch status {
            case .submitted:
                if segment == .submitted {
                    hTextColor.primary
                } else {
                    hTextColor.tertiary
                }
            case .beingHandled:
                switch segment {
                case .submitted:
                    hTextColor.secondary
                case .beingHandled:
                    hTextColor.primary
                case .closed:
                    hTextColor.tertiary
                default:
                    hTextColor.tertiary
                }
            case .reopened:
                switch segment {
                case .submitted:
                    hTextColor.secondary
                case .beingHandled:
                    hTextColor.primary
                default:
                    hTextColor.tertiary
                }
            case .closed:
                hTextColor.primary
            default:
                hTextColor.secondary
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
