import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct HomeOngoingQuotesSection: View {
    let quotes: [OngoingQuote]
    let onDismiss: (String) -> Void
    @StateObject private var scrollVm = InfoCardScrollViewModel(spacing: .padding16)

    var body: some View {
        if !quotes.isEmpty {
            hSection { cards }
                .withHeader(title: L10n.homeQuotesSectionTitle)
                .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder private var cards: some View {
        if quotes.count == 1, let quote = quotes.first {
            card(for: quote)
        } else {
            InfoCardScrollView(items: .constant(quotes), vm: scrollVm) { quote in
                card(for: quote)
            }
        }
    }

    private func card(for quote: OngoingQuote) -> some View {
        OngoingQuoteCard(quote: quote) { onDismiss(quote.id) }
    }
}

private struct OngoingQuoteCard: View {
    let quote: OngoingQuote
    let onDismiss: () -> Void
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            HStack(alignment: .top, spacing: 0) {
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
                }
                Spacer(minLength: 0)
                dismissButton
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
        .hCardShadow()
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverPressTo + " " + L10n.generalContinueButton)
        .onTapGesture { resume() }
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) { resume() }
        .accessibilityAction(named: L10n.General.remove) { onDismiss() }
        .hButtonIsLoading(isLoading)
        .disabled(isLoading)
    }

    private var dismissButton: some View {
        Button(action: onDismiss) {
            hCoreUIAssets.closeSmall.view
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(hTextColor.Opaque.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .padding(.trailing, -.padding12)
        .padding(.top, -.padding12)
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.General.remove)
        .accessibilityHidden(true)
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
                type: .custom,
                name: "homeQuoteClicked",
                attributes: ["quoteId": quote.id]
            )
            await Dependencies.urlOpener.open(quote.resumeUrl)
            isLoading = false
        }
    }
}

#Preview("One quote") {
    hForm {
        HomeOngoingQuotesSection(quotes: [.previewQuote(id: "1")], onDismiss: { _ in })
    }
}

#Preview("Three quotes") {
    hForm {
        HomeOngoingQuotesSection(
            quotes: [
                .previewQuote(id: "1"),
                .previewQuote(id: "2", title: "Car Insurance + Accident Insurance"),
                .previewQuote(id: "3", title: "Accident Insurance"),
            ],
            onDismiss: { _ in }
        )
    }
}

#Preview("One quote - accessibility3") {
    hForm {
        HomeOngoingQuotesSection(quotes: [.previewQuote(id: "1")], onDismiss: { _ in })
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
