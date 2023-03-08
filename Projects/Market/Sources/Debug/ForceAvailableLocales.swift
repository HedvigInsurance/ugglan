import Apollo
import Foundation
import SwiftUI
import hCore
import hGraphQL

public struct ForceAvailableLocales: View {
    public init() {}
    @Inject var giraffe: hGiraffe

    @State private var availableLocales: [GiraffeGraphQL.Locale] = [] {
        didSet {

        }
    }

    func bindingFor(_ locale: GiraffeGraphQL.Locale) -> Binding<Bool> {
        Binding<Bool>(
            get: { availableLocales.contains(locale) },
            set: { newValue in
                if newValue {
                    availableLocales.append(locale)
                } else {
                    availableLocales.removeAll { localeToRemove in locale == localeToRemove }
                }
            }
        )
    }
    public var body: some View {
        ForEach(GiraffeGraphQL.Locale.allCases, id: \.self) { locale in
            Toggle(isOn: bindingFor(locale)) { Text(locale.rawValue) }.toggleStyle(CheckmarkToggleStyle())
        }
        .onAppear(perform: {
            self.availableLocales = Market.activatedMarkets.flatMap { market in
                market.languages.map { language in language.asGraphQLLocale() }
            }
        })
    }
}
