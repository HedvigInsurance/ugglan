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

    /// Converts date into a readable friendly string
    private func readableDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Localization.Locale.currentLocale.foundation
        
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateTimeStyle = .numeric
            return formatter.localizedString(for: date, relativeTo: Date())
        } else if Calendar.current.isDateInYesterday(date) {
            formatter.dateTimeStyle = .named
            
            dateFormatter.dateFormat = "HH:mm"
            return formatter.localizedString(for: date, relativeTo: Date()) + dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm"
            return dateFormatter.string(from: date)
        }
    }

    public var body: some View {
        hForm {
            VStack {
                // Claim status header
                VStack(alignment: .center) {
                    hCoreUIAssets.infoShield.view
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 22)

                    hText(claim.title, style: .headline)

                    hText(claim.subtitle, style: .footnote)
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
                        .frame(height: 8)

                    hText(statusParagraph)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)

                    Spacer()
                        .frame(height: 20)
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

                    // TODO: Add waveform to trackplayer
                    if let url = URL(string: claim.claimDetailData.signedAudioURL) {
                        TrackPlayer(audioPlayer: .init(recording: .init(url: url, created: Date(), sample: [])))
                            .frame(height: 64)
                    }

                    Spacer()
                        .frame(height: 8)

                    hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                        .foregroundColor(hLabelColor.secondary)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
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
