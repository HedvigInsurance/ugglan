import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    var claim: Claim

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ClaimPills(claim: claim)
                Spacer()
            }
            .padding([.leading, .trailing], 16)
            Spacer().frame(height: 20)
            hText(claim.title)
                .padding([.leading, .trailing], 16)
            Spacer().frame(height: 2)
            hText(claim.subtitle, style: .caption1 )
                .padding([.leading, .trailing], 16)
            Spacer().frame(height: 38)
            SwiftUI.Divider()
            Spacer().frame(height: 16)
            HStack {
                ForEach(claim.segments, id: \.text) { segment in
                    ClaimStatusBar(status: segment)
                }
            }
            .padding([.leading, .trailing], 16)
        }
        .padding([.top, .bottom], 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(hBackgroundColor.tertiary)
                .hShadow()
        )
    }
}

struct ClaimPills: View {
    var claim: Claim

    var body: some View {
        HStack {
            ForEach(claim.pills, id: \.text) { claimPill in
                claimPill.pill
            }
        }
    }
}

extension Claim.ClaimPill {
    @ViewBuilder
    var pill: some View {
        switch self.type {
        case .open:
            hPillOutline(text: self.text)
        case .closed:
            hPillFill(
                text: text,
                backgroundColor: hBackgroundColor.primary.inverted
            )
            .invertColorScheme
        case .payment:
            hPillFill(
                text: self.text,
                backgroundColor: hColorScheme(light: hTintColor.lavenderTwo, dark: hTintColor.lavenderOne)
            )
        case .reopened:
            hPillFill(text: self.text, backgroundColor: hTintColor.orangeTwo)
        case .none:
            EmptyView()
        }
    }
}

extension Claim {
    public static var mock = Claim(
        id: "123",
        pills: [.init(text: "abc", type: .payment)],
        segments: [],
        title: "Blah",
        subtitle: "Blah"
    )
}

struct ClaimsPreview: PreviewProvider {
    static var previews: some View {
        ClaimStatus(claim: .mock).preferredColorScheme(.light).previewAsComponent()
    }
}
