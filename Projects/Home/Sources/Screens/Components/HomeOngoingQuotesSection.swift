import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct HomeOngoingQuotesSection: View {
    let quotes: [OngoingQuote]
    @StateObject private var scrollVm = InfoCardScrollViewModel(spacing: .padding16)

    var body: some View {
        if !quotes.isEmpty {
            VStack(spacing: 0) {
                hSection { EmptyView() }
                    .withHeader(title: L10n.homeQuotesSectionTitle)
                    .sectionContainerStyle(.transparent)
                cards
            }
        }
    }

    @ViewBuilder private var cards: some View {
        hSection {
            if quotes.count == 1, let quote = quotes.first {
                OngoingQuoteCard(quote: quote)
            } else {
                InfoCardScrollView(items: .constant(quotes), vm: scrollVm) { quote in
                    OngoingQuoteCard(quote: quote)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

private struct OngoingQuoteCard: View {
    let quote: OngoingQuote

    var body: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            HStack(spacing: .padding12) {
                pillow
                VStack(alignment: .leading, spacing: 0) {
                    hText(quote.title, style: .heading1)
                        .foregroundColor(hTextColor.Opaque.primary)
                    if let secondaryText = quote.secondaryText {
                        hText(secondaryText, style: .heading1)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            hButton(.medium, .secondary, content: .init(title: L10n.generalContinueButton)) { resume() }
                .hButtonTakeFullWidth(true)
        }
        .padding(.padding16)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(hFillColor.Opaque.negative)
        }
        .overlay {
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .stroke(hBorderColor.primary, lineWidth: 1)
        }
        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(L10n.voiceoverPressTo + " " + L10n.generalContinueButton)
        .onTapGesture { resume() }
        .accessibilityAction(.default) { resume() }
    }

    private var pillow: some View {
        KFImage(quote.pillowImageUrl)
            .placeholder { hCoreUIAssets.bigPillowHome.view.resizable() }
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipped()
            .accessibilityHidden(true)
    }

    private func resume() {
        log.addUserAction(
            type: .click,
            name: "home ongoing quote",
            attributes: ["quoteId": quote.id]
        )
        Task {
            await Dependencies.urlOpener.open(quote.resumeUrl)
        }
    }
}

#Preview("One quote") {
    hForm {
        HomeOngoingQuotesSection(quotes: [.previewQuote(id: "1")])
    }
}

#Preview("Three quotes") {
    hForm {
        HomeOngoingQuotesSection(
            quotes: [
                .previewQuote(id: "1"),
                .previewQuote(id: "2", title: "Car Insurance + Accident Insurance"),
                .previewQuote(id: "3", title: "Accident Insurance", monthlyNet: nil),
            ]
        )
    }
}

#Preview("One quote - accessibility3") {
    hForm {
        HomeOngoingQuotesSection(quotes: [.previewQuote(id: "1")])
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

extension OngoingQuote {
    fileprivate static func previewQuote(
        id: String,
        title: String = "Home Insurance",
        monthlyNet: MonetaryAmount? = .init(amount: "199", currency: "SEK")
    ) -> OngoingQuote {
        .init(
            id: id,
            title: title,
            subtitle: "Studio apartment, Stockholm",
            monthlyNet: monthlyNet,
            resumeUrl: URL(string: "https://www.hedvig.com/se")!,
            pillowImageUrl: nil
        )
    }
}
