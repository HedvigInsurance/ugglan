import Foundation
import hCore
import hCoreUI
import SwiftUI

struct LanguageRowView: View {
    @PresentableStore var store: MarketStore
    @State var locale: Localization.Locale = .currentLocale
    
    var body: some View {
        Button {
            store.send(.presentLanguagePicker(currentMarket: store.state.market))
        } label: {

        }
        .buttonStyle(LanguageRowButtonStyle(locale: locale))
    }
}

struct LanguageRowButtonStyle: ButtonStyle {
    let locale: Localization.Locale

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 16) {
            Image(uiImage: Asset.globe.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                
            VStack(alignment: .leading) {
                hText(L10n.MarketLanguageScreen.languageLabel, style: .headline)
                    
                hText(locale.displayName, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            }
            
            Spacer()
            
            Image(uiImage: hCoreUIAssets.chevronRight.image)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
        }
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.25))
        .preferredColorScheme(.dark)
    }
}

struct LanguageRow_Previews: PreviewProvider {
    static var previews: some View {
        LanguageRowView()
    }
}
