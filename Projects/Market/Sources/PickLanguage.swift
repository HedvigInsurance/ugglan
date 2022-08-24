import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct PickLanguage: View {
    let currentMarket: Market
    @PresentableStore var store: MarketStore

    @State var currentLocale: Localization.Locale = .currentLocale

    public init(
        currentMarket: Market
    ) {
        self.currentMarket = currentMarket
    }

    public var body: some View {
        hForm {
            hText(L10n.LanguagePickerModal.text, style: .body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            hSection(currentMarket.languages, id: \.lprojCode) { locale in
                hRow {
                    locale.displayName.hText()
                }
                .withSelectedAccessory(locale == currentLocale)
                .onTap {
                    Localization.Locale.currentLocale = locale
                    self.currentLocale = locale
                }
            }
        }
    }
}

extension PickLanguage {
    public var journey: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .prefersLargeTitles(true)]
        ) { action in
            if case .selectMarket = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.MarketLanguageScreen.languageLabel)
        .withDismissButton
    }
}
