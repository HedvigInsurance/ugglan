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
    @State private var isLoading = false

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
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) { resume() }
        .hButtonIsLoading(isLoading)
        .disabled(isLoading)
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
        Task {
            isLoading = true
            await delay(2)
            log.addUserAction(
                type: .click,
                name: "home ongoing quote",
                attributes: ["quoteId": quote.id]
            )
            await Dependencies.urlOpener.open(quote.resumeUrl)
            isLoading = false
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
                .previewQuote(id: "3", title: "Accident Insurance"),
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
    fileprivate static func previewQuote(id: String, title: String = "Home Insurance") -> OngoingQuote {
        .init(
            id: id,
            title: title,
            subtitle: "Studio apartment, Stockholm",
            monthlyNet: .init(amount: "199", currency: "SEK"),
            resumeUrl: URL(string: "https://www.hedvig.com/se")!,
            pillowImageUrl: nil
        )
    }
}
