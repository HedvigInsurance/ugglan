import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    var claim: Claim

    public init(
        claim: Claim
    ) {
        self.claim = claim
    }
    
    private var statusParagraph: String {
        claim.claimDetailData.statusParagraph
    }
    
    private var submittedDate: String {
        guard let submitted = claim.claimDetailData.submittedAt else { return "-" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        guard let date = dateFormatter.date(from: submitted) else { return "-" }

        if !Calendar.current.isDateInWeek(from: date) {
            dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm"
            return dateFormatter.string(from: date)
        } else if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "EEEE HH:mm"
            return dateFormatter.string(from: date)
        }
    }

    public var body: some View {
        VStack {
            // Claim status header
            VStack(alignment: .center) {
                // TODO: Add Image as computed property
                hCoreUIAssets.infoShield.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 22)

                // TODO: Add title as a computed property
                hText("New insurance case", style: .headline)
                
                // TODO: Add subtitle as a computed property
                // TODO: Hide subtitle for new insurance cases
                hText("Contents insurance", style: .footnote)
                    .foregroundColor(hLabelColor.secondary)

                Spacer()
                    .frame(height: 16)

                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        hText(L10n.ClaimStatusDetail.submitted, style: .caption2)
                            .foregroundColor(hLabelColor.secondary)

                        hText(submittedDate, style: .caption1)
                    }

                    Spacer()
                    Divider()
                        .frame(maxHeight: 32)

                    Spacer()
                    VStack(spacing: 4) {
                        hText(L10n.ClaimStatusDetail.closed, style: .caption2)
                            .foregroundColor(hLabelColor.secondary)

                        // TODO: Show closed time from a computed property
                        hText("-", style: .caption1)
                    }
                    Spacer()
                }
            }
            .padding(.top, 25)

            Spacer()
                .frame(height: 24)

            // Status card section
            TappableCard(alignment: .leading) {
                HStack(spacing: 6) {
                    ForEach(claim.segments, id: \.text) { segment in
                        ClaimStatusBar(status: segment)
                    }
                }
                .padding(16)

                Spacer()
                    .frame(maxHeight: 8)

                hText(statusParagraph)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)

                Spacer()
                    .frame(maxHeight: 20)
                Divider()

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .caption1)
                            .foregroundColor(hLabelColor.secondary)
                        hText(L10n.ClaimStatus.Contact.Generic.title, style: .callout)
                    }
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                            .fill(hBackgroundColor.primary)
                            .frame(width: 40, height: 40)

                        hCoreUIAssets.chatSolid.view
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 23, height: 19)
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 16)

            Spacer()
                .frame(height: 52)

            // Audio files section
            VStack(alignment: .leading) {
                hText(L10n.ClaimStatus.files, style: .headline)

                Spacer()
                    .frame(height: 16)

                // TODO: Add audio player here

                Spacer()
                    .frame(height: 8)

                hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                    .foregroundColor(hLabelColor.secondary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(hBackgroundColor.primary)
        .navigationBarTitle(Text(L10n.ClaimStatus.title), displayMode: .inline)
    }
}

extension Calendar {
    /// returns a boolean indicating if provided date is in the same week as current week
    func isDateInWeek(from date: Date) -> Bool {
        let currentWeek = component(Calendar.Component.weekOfYear, from: Date())
        let otherWeek = component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == otherWeek)
    }
}
