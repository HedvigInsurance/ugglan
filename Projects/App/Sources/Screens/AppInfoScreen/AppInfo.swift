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
    @Inject var client: ApolloClient
    let type: AppInfoType

    enum AppInfoType {
        case appSettings, appInformation

        var title: String {
            switch self {
            case .appInformation: return L10n.OnboardingContextualMenu.appInfoLabel
            case .appSettings: return L10n.EmbarkOnboardingMoreOptions.settingsLabel
            }
        }

        var icon: UIImage {
            switch self {
            case .appInformation: return Asset.infoIcon.image
            case .appSettings: return Asset.settingsIcon.image
            }
        }

        var trackingParcel: hAnalyticsParcel {
            switch self {
            case .appInformation:
                return hAnalyticsEvent.screenView(screen: .appInformation)
            case .appSettings:
                return hAnalyticsEvent.screenView(screen: .appSettings)
            }
        }

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
                case .version: return hCoreUIAssets.infoLarge.image
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

    init(type: AppInfoType) { self.type = type }
}

extension AppInfo: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = type.title

        let bag = DisposeBag()

        let form = FormView()

        if type == .appInformation {
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
        }

        func footerView() -> UIView? {
            let year = Calendar.current.component(.year, from: Date())

            let footerView = UILabel(
                value: "© Hedvig AB - \(year)",
                style: TextStyle.brand(.footnote(color: .primary)).centerAligned
            )
            footerView.textAlignment = .center

            return type == .appInformation ? footerView : nil
        }

        form.appendSpacing(.inbetween)

        let bodySection = form.appendSection(headerView: nil, footerView: footerView())

        form.appendSpacing(.inbetween)

        func value(row: AppInfoType.InfoRows) -> Future<String> {
            let innerBag = DisposeBag()
            return Future<String> { completion in
                switch row {
                case .language: completion(.success(Localization.Locale.currentLocale.displayName))
                case .market: completion(.success(Localization.Locale.currentLocale.market.marketName))
                case .version: completion(.success(Bundle.main.appVersion))
                case .memberId:
                    innerBag += client.fetch(query: GraphQL.MemberIdQuery()).valueSignal
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
                        UIApplication.shared.appDelegate.logout(token: nil)
                    }
                }
        }

        func setupAppSettings() {
            let market = AppInfoType.InfoRows.market

            let marketRow = AppInfoRow(
                title: market.title,
                icon: market.icon,
                trailingIcon: hCoreUIAssets.chevronRight.image,
                value: value(row: market)
            )

            bag += bodySection.append(marketRow)

            bag += marketRow.onSelect.onValue { presentChangeMarketAlert() }

            let language = AppInfoType.InfoRows.language
            let languageRow = AppInfoRow(
                title: language.title,
                icon: language.icon,
                trailingIcon: hCoreUIAssets.external.image,
                trailingIconTintColor: UIColor.typographyColor(.secondary),
                value: value(row: language)
            )

            bag += bodySection.append(languageRow)

            bag += languageRow.onSelect.onValue {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }

            bag +=
                client.fetch(
                    query: GraphQL.MemberDetailsQuery(),
                    cachePolicy: .returnCacheDataElseFetch,
                    queue: .global(qos: .background)
                )
                .valueSignal
                .compactMap(on: .background) { MemberDetails(memberData: $0.member) }
                .compactMap(on: .main) { details in
                    /// Checks for application state as this screen can also be opened from other places
                    if ApplicationState.currentState?.isOneOf([.loggedIn]) == true {
                        bag += bodySection.append(DeleteAccountButton(memberDetails: details))
                    }
                }
        }

        func setupAppInfo() {
            [AppInfoType.InfoRows.memberId, AppInfoType.InfoRows.version, AppInfoType.InfoRows.deviceId]
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

        switch type {
        case .appSettings: setupAppSettings()
        case .appInformation: setupAppInfo()
        }

        bag += viewController.install(form)

        viewController.trackOnAppear(type.trackingParcel)

        return (viewController, bag)
    }
}

extension MenuChildAction {
    static var appInformation: MenuChildAction {
        MenuChildAction(identifier: "app-information")
    }

    static var appSettings: MenuChildAction {
        MenuChildAction(identifier: "app-settings")
    }
}

extension MenuChild {
    static var appInformation: MenuChild {
        MenuChild(
            title: L10n.aboutScreenTitle,
            style: .default,
            image: hCoreUIAssets.infoLarge.image,
            action: .appInformation
        )
    }

    static var appSettings: MenuChild {
        MenuChild(
            title: L10n.Profile.AppSettingsSection.title,
            style: .default,
            image: hCoreUIAssets.settingsIcon.image,
            action: .appSettings
        )
    }
}
