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
    @State private var refreshControl: Int = 1

    let timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()

    /// Converts date into a readable friendly string
    private func readableDateString(from string: String?) -> String {
        guard let str = string,
            let date = str.localDateToIso8601Date(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
        else {
            return "-"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Localization.Locale.currentLocale.foundation

        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateTimeStyle = .numeric
            return formatter.localizedString(for: date, relativeTo: Date())
        } else if Calendar.current.isDateInYesterday(date) {
            formatter.dateTimeStyle = .named

            dateFormatter.dateFormat = "HH:mm"
            return formatter.localizedString(for: date, relativeTo: Date()).capitalized + " "
                + dateFormatter.string(from: date)
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

            Spacer()
                .frame(height: 4)

            hText(subtitle, style: .footnote)
                .foregroundColor(hLabelColor.secondary)

            if let payout = payout {
                Spacer()
                    .frame(height: 12)

                HStack(alignment: .firstTextBaseline) {
                    hPillFill(
                        text: L10n.Claim.Decision.paid.uppercased(),
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

                    if self.refreshControl >= 1 {
                        hText(readableDateString(from: self.submitted), style: .caption1)
                            .onReceive(timer) { _ in
                                self.refreshControl += 1
                            }
                    }
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 32)

                VStack(spacing: 4) {
                    hText(L10n.ClaimStatusDetail.closed, style: .caption2)
                        .foregroundColor(hLabelColor.secondary)

                    if self.refreshControl >= 1 {
                        hText(readableDateString(from: self.closed), style: .caption1)
                            .onReceive(timer) { _ in
                                self.refreshControl += 1
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ClaimDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        ClaimDetailHeader(
            title: "Insurance case",
            subtitle: "Home Insurance Renter",
            submitted: "2021-12-21T09:09:35.331995Z",
            closed: nil,
            payout: MonetaryAmount(amount: "3400,00", currency: "SEK")
        )
    }
}
