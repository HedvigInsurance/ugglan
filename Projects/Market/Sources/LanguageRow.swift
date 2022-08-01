import SwiftUI
import hCore
import hCoreUI

struct LanguageRow: View {
    @PresentableStore var store: MarketStore
    @State var locale: Localization.Locale = .currentLocale
    @State var languageLabel: String = L10n.MarketLanguageScreen.languageLabel

    var body: some View {
        Button {
            store.send(.presentLanguagePicker(currentMarket: store.state.market))
        } label: {

        }
        .buttonStyle(LanguageRowButtonStyle(locale: locale, languageLabel: languageLabel))
        .onReceive(
            Localization.Locale.$currentLocale
                .distinct()
                .plain()
                .publisher
        ) { newLocale in
            self.languageLabel = L10n.MarketLanguageScreen.languageLabel
            locale = newLocale
        }
    }
}

struct LanguageRowButtonStyle: ButtonStyle {
    let locale: Localization.Locale
    let languageLabel: String

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 16) {
            Image(uiImage: Asset.globe.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading) {
                hText(languageLabel, style: .headline)

                hText(locale.displayName, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            }

            Spacer()

            Image(uiImage: hCoreUIAssets.chevronRight.image)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
        }
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.25))
        .preferredColorScheme(.dark)
    }
}

struct LanguageRow_Previews: PreviewProvider {
    static var previews: some View {
        LanguageRow()
    }
}
