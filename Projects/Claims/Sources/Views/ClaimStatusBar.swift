import SwiftUI
import hCore
import hCoreUI

struct ClaimStatusBar: View {
    let status: ClaimModel.ClaimStatus
    let outcome: ClaimModel.ClaimOutcome?

    func accessibilityText(segment: ClaimModel.ClaimStatus) -> String? {
        let claimStatusText = L10n.ClaimStatus.title

        switch status {
        case .submitted:
            if segment == .submitted {
                return claimStatusText + " " + L10n.ClaimStatusDetail.submitted
            }
        case .beingHandled:
            switch segment {
            case .submitted:
                return claimStatusText + " " + L10n.Claim.StatusBar.beingHandled + " "
                    + L10n.ClaimStatusDetail.submitted
            case .beingHandled:
                return claimStatusText + " " + L10n.Claim.StatusBar.beingHandled
            default:
                return nil
            }
        case .closed:
            if outcome == .paid {
                return claimStatusText + " " + L10n.Claim.StatusBar.closed + " " + L10n.Claim.Decision.paid
            } else {
                return claimStatusText + " " + L10n.Claim.StatusBar.closed
            }
        case .reopened:
            switch segment {
            case .submitted:
                return claimStatusText + " " + L10n.Home.ClaimCard.Pill.reopened + ": "
                    + L10n.ClaimStatusDetail.submitted
            case .beingHandled:
                return claimStatusText + " " + L10n.Home.ClaimCard.Pill.reopened + L10n.Claim.StatusBar.beingHandled
            default:
                return nil
            }
        default:
            return nil
        }
        return nil
    }

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
                hSignalColor.Green.element
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
                hSignalColor.Green.element
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
        HStack(alignment: .top, spacing: .padding6) {
            ForEach(ClaimModel.ClaimStatus.allCases, id: \.title) { segment in
                if !(segment == .none || segment == .reopened) {
                    VStack {
                        Rectangle()
                            .fill(barColor(segment: segment))
                            .frame(height: 4)
                            .cornerRadius(.cornerRadiusXS)
                        hText(segment.title, style: .label)
                            .foregroundColor(textColor(segment: segment))
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(accessibilityText(segment: segment) ?? "")
                }
            }
        }
    }
}

struct ClaimStatusBar_Previews: PreviewProvider {
    static var previews: some View {
        hForm {
            hSection {
                VStack {
                    HStack {
                        ClaimStatusBar(status: .submitted, outcome: .none)
                    }
                    //                    HStack {
                    //                        ClaimStatusBar(status: .beingHandled, outcome: .none)
                    //                    }
                    //                    HStack {
                    //                        ClaimStatusBar(status: .closed, outcome: .paid)
                    //                    }
                    //                    HStack {
                    //                        ClaimStatusBar(status: .closed, outcome: .notCovered)
                    //                    }
                    //                    HStack {
                    //                        ClaimStatusBar(status: .closed, outcome: .notCompensated)
                    //                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
