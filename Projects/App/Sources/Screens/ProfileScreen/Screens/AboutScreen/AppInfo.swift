import Apollo
import Flow
import Form
import hCore
import hCoreUI
import hGraphQL
import Market
import Presentation
import SwiftUI
import UIKit

struct AppInfo {
    @Inject var client: ApolloClient
    let state: State

    enum State {
        case appSettings, appInformation

        var title: String {
            switch self {
            case .appInformation:
                return L10n.OnboardingContextualMenu.appInfoLabel
            case .appSettings:
                return L10n.EmbarkOnboardingMoreOptions.settingsLabel
            }
        }

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
                case .language:
                    return true
                case .version, .memberId, .locale:
                    return false
                }
            }
        }

        enum ButtonRow: CaseIterable {
            case changeButton

            var title: String {
                switch self {
                case .changeButton:
                    return L10n.settingsChangeMarket.displayValue
                }
            }
        }

        func button() -> ButtonRow? {
            if case .appSettings = self {
                return .changeButton
            } else {
                return nil
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
        viewController.title = state.title

        let bag = DisposeBag()

        let form = FormView()

        func footerView() -> UIView? {
            let year = Calendar.current.component(.year, from: Date())

            let footerView = UILabel(
                value: "© Hedvig AB - \(year)",
                style: TextStyle.brand(.footnote(color: .primary)).centerAligned
            )
            footerView.textAlignment = .center

            return state == .appInformation ? footerView : nil
        }

        form.appendSpacing(.inbetween)

        let bodySection = form.appendSection(headerView: nil, footerView: footerView())

        form.appendSpacing(.inbetween)

        let buttonsSection = form.appendSection()

        func value(row: State.InfoRows) -> Future<String> {
            let innerBag = DisposeBag()
            return Future<String> { completion in
                switch row {
                case .language:
                    completion(.success(Localization.Locale.currentLocale.displayName))
                case .locale:
                    completion(.success(Localization.Locale.currentLocale.market.marketName))
                case .version:
                    completion(.success(Bundle.main.appVersion))
                case .memberId:
                    innerBag += client.fetch(query: GraphQL.MemberIdQuery()).valueSignal.compactMap {
                        $0.member.id
                    }.onValue { memberId in
                        completion(.success(memberId))
                    }
                }

                return innerBag
            }
        }

        func presentAlert() {
            let alert = Alert(
                title: L10n.settingsAlertChangeMarketTitle,
                message: L10n.settingsAlertChangeMarketText,
                tintColor: nil,
                actions: [
                    Alert.Action(
                        title: L10n.alertOk,
                        style: UIAlertAction.Style.destructive
                    ) { true },
                    Alert.Action(
                        title: L10n.settingsAlertChangeMarketCancel,
                        style: UIAlertAction.Style.cancel
                    ) { false },
                ]
            )

            bag += viewController.present(alert).onValue { shouldLogout in
                if shouldLogout {
                    ApplicationState.preserveState(.marketPicker)
                    UIApplication.shared.appDelegate.logout()
                }
            }
        }

        func setupAppSettings() {
            let row = State.InfoRows.locale
            let market = Localization.Locale.currentLocale.market
            bag += bodySection.append(
                AppInfoRow(
                    title: row.title,
                    icon: market.icon,
                    isTappable: row.isTappable,
                    value: value(row: row)
                )
            )

            let language = State.InfoRows.language
            let languageRow = AppInfoRow(
                title: language.title,
                icon: language.icon,
                isTappable: language.isTappable,
                value: value(row: row)
            )

            bag += bodySection.append(languageRow)

            bag += languageRow.onSelect.onValue {
                presentAlert()
            }
        }

        func setupAppInfo() {
            [State.InfoRows.memberId, State.InfoRows.version].forEach { row in
                bag += bodySection.append(AppInfoRow(title: row.title, icon: row.icon, isTappable: row.isTappable, value: value(row: row)))
            }
        }

        switch state {
        case .appSettings:
            setupAppSettings()
        case .appInformation:
            setupAppInfo()
        }

        if let buttonRow = state.button() {
            let button = ButtonRowViewWrapper(title: buttonRow.title, type: .outline(borderColor: .black, textColor: .black))

            bag += buttonsSection.append(button)

            bag += button.onTapSignal.onValue {
                presentAlert()
            }
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}

private extension Localization.Locale.Market {
    var icon: UIImage {
        switch self {
        case .no:
            return hCoreUIAssets.flagNO.image
        case .se:
            return hCoreUIAssets.flagSE.image
        case .dk:
            return hCoreUIAssets.flagDK.image
        }
    }
}
