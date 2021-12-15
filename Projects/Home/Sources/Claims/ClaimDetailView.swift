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
        let dateFormatter = DateFormatter.withIso8601Format("yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
        guard let submitted = claim.claimDetailData.submittedAt,
            let date = dateFormatter.date(from: submitted)
        else { return "-" }
        return readableDateString(from: date)
    }

    private var closedDate: String {
        let dateFormatter = DateFormatter.withIso8601Format("yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
        guard let closed = claim.claimDetailData.closedAt,
            let date = dateFormatter.date(from: closed)
        else { return "-" }
        return readableDateString(from: date)
    }

    private func readableDateString(from date: Date) -> String {
        // TODO: Localize strings used for yesterday and hours/minutes ago
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            guard let hours = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, hours >= 1 else {
                // Show minutes ago
                guard let minutes = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute else {
                    dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm"
                    return dateFormatter.string(from: date)
                }

                return minutes > 1 ? "\(minutes) minutes ago" : "1 minute ago"
            }

            return hours > 1 ? "\(hours) hours ago" : "1 hour ago"
        } else if Calendar.current.isDateInYesterday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return "Yesterday " + dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm"
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

                        hText(closedDate, style: .caption1)
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

extension DateFormatter {
    static func withIso8601Format(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = format
        return formatter
    }
}
