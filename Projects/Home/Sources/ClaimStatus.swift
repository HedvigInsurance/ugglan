import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimStatus: View {
    @State var claim: Claim

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ClaimPills(claim: claim)
                Spacer()
                //Image(uiImage: hCoreUIAssets.chevronRight.image).tint(hLabelColor.secondary)
            }
            .padding([.leading, .trailing], 10)
            Spacer().frame(height: 23)
            hText(L10n.Claim.Casetype.newInsuranceCase)
                .padding([.leading, .trailing], 10)
            Spacer().frame(height: 20)
            SwiftUI.Divider()
            Spacer().frame(height: 16)
            HStack {
                ForEach(claim.segments, id: \.text) { segment in
                    ClaimStatusBar(status: segment)
                }
            }
            .padding([.leading, .trailing], 10)
        }
        .padding([.top, .bottom], 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(hBackgroundColor.tertiary)
                .shadow(radius: 4)
        )
    }
}

struct ClaimPills: View {
    @State var claim: Claim

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
                backgroundColor: hBackgroundColor.primary
            )
            .invertColorScheme
        case .reopened:
            hPillFill(text: self.text, backgroundColor: hTintColor.orangeTwo)
        case .none:
            EmptyView()
        }
    }
}

extension Claim {
    public static var mock = Claim(id: "123", pills: [], segments: [], title: "Blah", subtitle: "Blah")
}

struct ClaimsPreview: PreviewProvider {
    static var previews: some View {
        ClaimStatus(claim: .mock).preferredColorScheme(.light).previewAsComponent()
    }
}
