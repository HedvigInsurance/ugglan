import Apollo
import Flow
import Form
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SwiftUI
import UIKit
import Market

struct AppInfo {
    @Inject var client: ApolloClient
    let state: State

    enum State {
        case appSettings, appInformation
        
        enum InfoRows: CaseIterable {
           
            case language
            case locale
            case version
            case memberId
            
            var title: String {
                switch self {
                case .language:
                    return L10n.aboutLanguageRow
                case .locale:
                    return L10n.MarketLanguageScreen.marketLabel
                case .version:
                    return L10n.EmbarkOnboardingMoreOptions.versionLabel
                case .memberId:
                    return L10n.EmbarkOnboardingMoreOptions.userIdLabel
                }
            }
            
            var icon: UIImage? {
                switch self {
                case .language:
                    return hCoreUIAssets.language.image
                case .locale:
                    return nil
                case .version:
                    return hCoreUIAssets.infoLarge.image
                case .memberId:
                    return hCoreUIAssets.memberCard.image
                }
            }
            
            var isTappable: Bool {
                switch self {
                case .language, .locale:
                    return true
                case .version, .memberId:
                    return false
                    
                }
            }
        }
        
        enum ButtonRows: CaseIterable {
            case loginButton
            case changeButton
        }
        
        func infoRows() -> [InfoRows] {
            switch self {
            case .appInformation:
                return [.memberId, .version]
            case .appSettings:
                return [.language, .locale]
            }
        }
        
        func buttonRows() -> [ButtonRows] {
            if case .appSettings = self {
                return [.changeButton]
            } else {
                return []
            }
        }
    }

    init(state: State) {
        self.state = state
    }
}

extension AppInfo: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.settingsChangeMarket
        
        let bag = DisposeBag()
        
        let form = FormView()
        
        form.appendSpacing(.inbetween)
        
        let bodySection = form.appendSection()
        
        form.appendSpacing(.inbetween)
        
        let buttonsSection = form.appendSection() 
        
        func fetchAndDisplayMarket() {
            bag += client.fetch(query: GraphQL.GeoQuery())
                .valueSignal
                .compactMap { $0.geo.countryIsoCode }
                .onValue { countryISOCode in
                    if let market = Market(rawValue: countryISOCode) {
                        let row = CountryRow(market: market)
                        bag += bodySection.append(row)
                    }
                }
        }
        
        func addFooter() {
            let year = Calendar.current.component(.year, from: Date())
            
            let footerView = UILabel(
                value: "© Hedvig AB - \(year)",
                style: TextStyle.brand(.footnote(color: .primary)).centerAligned
            )
            footerView.textAlignment = .center
        }
        
        func value(row: State.InfoRows, completion: @escaping (String) -> Void) {
            switch row {
            case .language:
                completion(Localization.Locale.currentLocale.displayName)
            case .locale:
                completion(Localization.Locale.currentLocale.market.marketName)
            case .version:
                completion(Bundle.main.appVersion)
            case .memberId:
                bag += client.fetch(query: GraphQL.MemberIdQuery()).valueSignal.compactMap {
                    $0.member.id
                }.onValue({ (memberId) in
                    completion(memberId)
                })
            }
        }
        
        state.infoRows().forEach { row in
            value(row: row) { (valueString) in
                bag += bodySection.append(AppInfoRow(title: row.title, icon: row.icon, isTappable: row.isTappable, value: valueString))
            }
        }
        
        bag += viewController.install(form)
        
        return (viewController, bag)
    }
}
