import Apollo
import Flow
import Form
import Market
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct AppInfo {
    @Inject var giraffe: hGiraffe

    enum InfoRows: CaseIterable {
        case language
        case market
        case version
        case memberId
        case deviceId

        var title: String {
            switch self {
            case .language: return L10n.aboutLanguageRow
            case .market: return L10n.MarketLanguageScreen.marketLabel
            case .version: return L10n.EmbarkOnboardingMoreOptions.versionLabel
            case .memberId: return L10n.EmbarkOnboardingMoreOptions.userIdLabel
            case .deviceId: return L10n.AppInfo.deviceIdLabel
            }
        }

        var icon: UIImage? {
            switch self {
            case .language: return hCoreUIAssets.language.image
            case .market: return Localization.Locale.currentLocale.market.icon
            case .version: return hCoreUIAssets.infoIcon.image
            case .memberId: return hCoreUIAssets.memberCard.image
            case .deviceId: return hCoreUIAssets.profileCircleIcon.image
            }
        }

        var isTappable: Bool {
            switch self {
            case .language: return true
            case .version, .memberId, .market, .deviceId: return false
            }
        }
    }
}

extension AppInfo: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.OnboardingContextualMenu.appInfoLabel

        let bag = DisposeBag()

        let form = FormView()

        let debugGesture = UITapGestureRecognizer()
        debugGesture.numberOfTapsRequired = 3
        form.addGestureRecognizer(debugGesture)

        bag += debugGesture.signal(forState: .recognized)
            .onValue { _ in
                viewController.present(
                    UIHostingController(rootView: Debug()),
                    style: .detented(.large),
                    options: []
                )
            }

        func footerView() -> UIView? {
            let year = Calendar.current.component(.year, from: Date())

            let footerView = UILabel(
                value: "© Hedvig AB - \(year)",
                style: TextStyle.brand(.footnote(color: .primary)).centerAligned
            )
            footerView.textAlignment = .center

            return footerView
        }

        form.appendSpacing(.inbetween)

        let bodySection = form.appendSection(headerView: nil, footerView: footerView())

        form.appendSpacing(.inbetween)

        func value(row: InfoRows) -> Future<String> {
            let innerBag = DisposeBag()
            return Future<String> { completion in
                switch row {
                case .language: completion(.success(Localization.Locale.currentLocale.displayName))
                case .market: completion(.success(Localization.Locale.currentLocale.market.marketName))
                case .version: completion(.success(Bundle.main.appVersion))
                case .memberId:
                    innerBag += giraffe.client.fetch(query: GiraffeGraphQL.MemberIdQuery()).valueSignal
                        .compactMap { $0.member.id }
                        .onValue { memberId in completion(.success(memberId)) }
                case .deviceId:
                    completion(.success(ApolloClient.getDeviceIdentifier()))
                }

                return innerBag
            }
        }

        func presentChangeMarketAlert() {
            let alert = Alert(
                title: L10n.settingsAlertChangeMarketTitle,
                message: L10n.settingsAlertChangeMarketText,
                tintColor: nil,
                actions: [
                    Alert.Action(title: L10n.alertOk, style: UIAlertAction.Style.destructive) {
                        true
                    },
                    Alert.Action(
                        title: L10n.settingsAlertChangeMarketCancel,
                        style: UIAlertAction.Style.cancel
                    ) { false },
                ]
            )

            bag += viewController.present(alert)
                .onValue { shouldLogout in
                    if shouldLogout {
                        ApplicationState.preserveState(.marketPicker)
                        UIApplication.shared.appDelegate.logout()
                    }
                }
        }

        func setupAppSettings() {
            let market = InfoRows.market

            let marketRow = AppInfoRow(
                title: market.title,
                icon: market.icon,
                trailingIcon: hCoreUIAssets.arrowForward.image,
                value: value(row: market)
            )

            bag += bodySection.append(marketRow)

            bag += marketRow.onSelect.onValue { presentChangeMarketAlert() }

            let language = InfoRows.language
            let languageRow = AppInfoRow(
                title: language.title,
                icon: language.icon,
                trailingIcon: hCoreUIAssets.neArrowSmall.image,
                trailingIconTintColor: UIColor.typographyColor(.secondary),
                value: value(row: language)
            )

            bag += bodySection.append(languageRow)

            bag += languageRow.onSelect.onValue {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }

        func setupAppInfo() {
            [InfoRows.memberId, InfoRows.version, InfoRows.deviceId]
                .forEach { row in
                    bag += bodySection.append(
                        AppInfoRow(
                            title: row.title,
                            icon: row.icon,
                            trailingIcon: nil,
                            value: value(row: row)
                        )
                    )
                }
        }

        setupAppInfo()

        bag += viewController.install(form)

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .appInformation))

        return (viewController, bag)
    }
}

extension MenuChildAction {
    static var appInformation: MenuChildAction {
        MenuChildAction(identifier: "app-information")
    }
}

extension MenuChild {
    static var appInformation: MenuChild {
        MenuChild(
            title: L10n.aboutScreenTitle,
            style: .default,
            image: hCoreUIAssets.infoIcon.image,
            action: .appInformation
        )
    }
}
