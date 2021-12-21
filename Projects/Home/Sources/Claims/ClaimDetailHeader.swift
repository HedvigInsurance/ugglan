import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimDetailHeader: View {
    init(
        title: String,
        subtitle: String,
        submitted: String?,
        closed: String?,
        payout: MonetaryAmount?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.submitted = submitted
        self.closed = closed
        self.payout = payout
    }

    let title: String
    let subtitle: String
    let submitted: String?
    let closed: String?
    let payout: MonetaryAmount?

    private var submittedDate: String {
        let dateFormatter = DateFormatter.withIso8601Format("yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
        guard let submitted = submitted,
            let date = dateFormatter.date(from: submitted)
        else { return "-" }
        return readableDateString(from: date)
    }

    private var closedDate: String {
        let dateFormatter = DateFormatter.withIso8601Format("yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
        guard let closed = closed,
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

    var body: some View {
        VStack {
            hCoreUIAssets.infoShield.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 22)

            hText(title, style: .headline)

            hText(subtitle, style: .footnote)
                .foregroundColor(hLabelColor.secondary)

            if let payout = payout {
                Spacer()
                    .frame(height: 12)

                HStack(alignment: .firstTextBaseline) {
                    hPillFill(
                        text: L10n.Claim.Decision.paid,
                        backgroundColor: hColorScheme(
                            light: hTintColor.lavenderTwo,
                            dark: hTintColor.lavenderOne
                        )
                    )

                    Spacer()
                        .frame(width: 8)
                    hText(payout.amount, style: .largeTitle)

                    Spacer()
                        .frame(width: 2)
                    hText(payout.currency)
                        .foregroundColor(hLabelColor.secondary)
                }
            }

            Spacer()
                .frame(height: 16)

            HStack {
                VStack(spacing: 4) {
                    hText(L10n.ClaimStatusDetail.submitted, style: .caption2)
                        .foregroundColor(hLabelColor.secondary)

                    hText(submittedDate, style: .caption1)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 32)

                VStack(spacing: 4) {
                    hText(L10n.ClaimStatusDetail.closed, style: .caption2)
                        .foregroundColor(hLabelColor.secondary)

                    hText(closedDate, style: .caption1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
