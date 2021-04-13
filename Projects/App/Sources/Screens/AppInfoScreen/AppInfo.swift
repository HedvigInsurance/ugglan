//
//  AppInfo.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-04-09.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

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
    let type: AppInfoType

    enum AppInfoType {
        case appSettings, appInformation

        var title: String {
            switch self {
            case .appInformation:
                return L10n.OnboardingContextualMenu.appInfoLabel
            case .appSettings:
                return L10n.EmbarkOnboardingMoreOptions.settingsLabel
            }
        }
        
        var icon: UIImage {
            switch self {
            case .appInformation:
                return Asset.infoIcon.image
            case .appSettings:
                return Asset.settingsIcon.image
            }
        }

        enum InfoRows: CaseIterable {
            case language
            case market
            case version
            case memberId

            var title: String {
                switch self {
                case .language:
                    return L10n.aboutLanguageRow
                case .market:
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
                case .market:
                    return Localization.Locale.currentLocale.market.icon
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
                case .version, .memberId, .market:
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

    init(type: AppInfoType) {
        self.type = type
    }
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

            bag += debugGesture.signal(forState: .recognized).onValue { _ in
                if #available(iOS 13, *) {
                    viewController.present(
                        UIHostingController(rootView: Debug()),
                        style: .detented(.medium, .large),
                        options: []
                    )
                }
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

        let buttonsSection = form.appendSection()

        func value(row: AppInfoType.InfoRows) -> Future<String> {
            let innerBag = DisposeBag()
            return Future<String> { completion in
                switch row {
                case .language:
                    completion(.success(Localization.Locale.currentLocale.displayName))
                case .market:
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

        func presentChangeMarketAlert() {
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
            let row = AppInfoType.InfoRows.market
            bag += bodySection.append(
                AppInfoRow(
                    title: row.title,
                    icon: row.icon,
                    isTappable: row.isTappable,
                    value: value(row: row)
                )
            )

            let language = AppInfoType.InfoRows.language
            let languageRow = AppInfoRow(
                title: language.title,
                icon: language.icon,
                isTappable: language.isTappable,
                value: value(row: language)
            )

            bag += bodySection.append(languageRow)

            bag += languageRow.onSelect.onValue {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }

        func setupAppInfo() {
            [AppInfoType.InfoRows.memberId, AppInfoType.InfoRows.version].forEach { row in
                bag += bodySection.append(AppInfoRow(title: row.title, icon: row.icon, isTappable: row.isTappable, value: value(row: row)))
            }
        }

        switch type {
        case .appSettings:
            setupAppSettings()
        case .appInformation:
            setupAppInfo()
        }

        if let buttonRow = type.button() {
            let button = ButtonRowViewWrapper(
                title: buttonRow.title,
                type: .standardOutline(
                    borderColor: .brand(.primaryText()),
                    textColor: .brand(.primaryText())
                )
            )

            bag += buttonsSection.append(button)

            bag += button.onTapSignal.onValue {
                presentChangeMarketAlert()
            }
        }

        bag += viewController.install(form)

        return (viewController, bag)
    }
}

extension MenuChild {
    static var appInformation: MenuChild {
        MenuChild(
            title: L10n.aboutScreenTitle,
            style: .default,
            image: hCoreUIAssets.infoLarge.image
        ) { viewController in
            viewController.present(
                AppInfo(type: .appInformation).withCloseButton,
                style: .detented(.large)
            )
        }
    }
    
    static var appSettings: MenuChild {
        MenuChild(
            title: L10n.Profile.AppSettingsSection.title,
            style: .default,
            image: hCoreUIAssets.settingsIcon.image
        ) { viewController in
            viewController.present(
                AppInfo(type: .appSettings).withCloseButton,
                style: .detented(.large)
            )
        }
    }
}
