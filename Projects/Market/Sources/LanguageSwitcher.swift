import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

extension Notification.Name {
    static let localeSwitched = Notification.Name("localeSwitched")
}

extension UIApplication {
    // reloads all text that is derived from translations in the app
    public func reloadAllLabels() {
        func reloadLabels(in base: UIView) {
            for view in base.subviews {
                if let label = view as? UILabel {
                    if let derivedFromL10n = label.text?.derivedFromL10n {
                        if label.text != "" {
                            label.text = derivedFromL10n.render()
                        }
                        label.layoutIfNeeded()
                        label.sizeToFit()
                    } else if let derivedFromL10n = label.value.displayValue.derivedFromL10n {
                        label.value = derivedFromL10n.render()
                        label.layoutIfNeeded()
                        label.sizeToFit()
                    }
                } else if let button = view as? UIButton {
                    let title = button.title(for: .normal)
                    if let derivedFromL10n = title?.derivedFromL10n {
                        button.setTitle(derivedFromL10n.render(), for: .normal)
                    }
                }

                reloadLabels(in: view)
            }
        }

        func reloadViewControllers(in base: UIViewController) {
            if let derivedFromL10n = base.title?.derivedFromL10n {
                base.title = derivedFromL10n.render()
            }

            if let presentedViewController = base.presentedViewController {
                reloadViewControllers(in: presentedViewController)
            }

            if let inputAccessoryView = base.inputAccessoryView {
                reloadLabels(in: inputAccessoryView)
            }

            if let tabBarController = base as? UITabBarController {
                tabBarController.viewControllers?.forEach { viewController in
                    reloadViewControllers(in: viewController)
                }
            } else if let navigationController = base as? UINavigationController {
                navigationController.viewControllers.forEach { viewController in
                    reloadViewControllers(in: viewController)
                }
            } else {
                reloadLabels(in: base.view)
            }
        }

        windows.forEach { window in
            guard let rootViewController = window.rootViewController else {
                return
            }

            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                reloadViewControllers(in: rootViewController)
            }, completion: nil)
        }
    }
}

public struct LanguageSwitcher {
    @Inject var client: ApolloClient

    public init() {}
}

extension LanguageSwitcher: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.aboutLanguageRow
        let bag = DisposeBag()

        let form = FormView(sections: [], style: .defaultGrouped)
        bag += viewController.install(form)

        let section = form.appendSection(header: nil, footer: nil)

        func reloadAllLabels() {
            UIApplication.shared.reloadAllLabels()
        }

        func pickLanguage(locale: Localization.Locale) {
            ApplicationState.setPreferredLocale(locale)
            Localization.Locale.currentLocale = locale
            CrossFramework.reinitApolloClient().always {
                reloadAllLabels()
                NotificationCenter.default.post(Notification(name: .localeSwitched))
            }
            bag += client.perform(mutation: GraphQL.UpdateLanguageMutation(language: locale.code, pickedLocale: locale.asGraphQLLocale())).onValue { _ in }
        }

        switch Localization.Locale.currentLocale.market {
        case .se:
            let englishRowImageView = UIImageView()
            englishRowImageView.snp.makeConstraints { make in
                make.width.equalTo(20)
                make.height.equalTo(20)
            }

            if Localization.Locale.currentLocale == .en_SE {
                englishRowImageView.image = Asset.circularCheckmark.image
            }

            let swedishRowImageView = UIImageView()
            swedishRowImageView.snp.makeConstraints { make in
                make.width.equalTo(20)
                make.height.equalTo(20)
            }

            if Localization.Locale.currentLocale == .sv_SE {
                swedishRowImageView.image = Asset.circularCheckmark.image
            }

            let englishRow = RowView(title: "English", style: .brand(.headline(color: .primary)), appendSpacer: false)
            bag += section.append(englishRow).onValue { _ in
                pickLanguage(locale: .en_SE)

                UIView.transition(with: englishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    englishRowImageView.image = Asset.circularCheckmark.image
                       }, completion: nil)

                UIView.transition(with: swedishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    swedishRowImageView.image = nil
                       }, completion: nil)
            }

            englishRow.prepend(Asset.flagGB.image)
            englishRow.append(englishRowImageView)

            let swedishRow = RowView(title: "Svenska", style: .brand(.headline(color: .primary)), appendSpacer: false)
            bag += section.append(swedishRow).onValue { _ in
                pickLanguage(locale: .sv_SE)

                UIView.transition(with: englishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    englishRowImageView.image = nil
                       }, completion: nil)

                UIView.transition(with: swedishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    swedishRowImageView.image = Asset.circularCheckmark.image
                       }, completion: nil)
            }

            swedishRow.prepend(Asset.flagSE.image)
            swedishRow.append(swedishRowImageView)
        case .no:

            let englishRowImageView = UIImageView()
            englishRowImageView.snp.makeConstraints { make in
                make.width.equalTo(20)
                make.height.equalTo(20)
            }

            if Localization.Locale.currentLocale == .en_NO {
                englishRowImageView.image = Asset.circularCheckmark.image
            }

            let norwegianRowImageView = UIImageView()
            norwegianRowImageView.snp.makeConstraints { make in
                make.width.equalTo(20)
                make.height.equalTo(20)
            }

            if Localization.Locale.currentLocale == .nb_NO {
                norwegianRowImageView.image = Asset.circularCheckmark.image
            }

            let englishRow = RowView(title: "English", style: .brand(.headline(color: .primary)), appendSpacer: false)
            bag += section.append(englishRow).onValue { _ in
                pickLanguage(locale: .en_NO)

                UIView.transition(with: englishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    englishRowImageView.image = Asset.circularCheckmark.image
                       }, completion: nil)

                UIView.transition(with: norwegianRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    norwegianRowImageView.image = nil
                       }, completion: nil)
            }

            englishRow.prepend(Asset.flagGB.image)
            englishRow.append(englishRowImageView)

            let norwegianRow = RowView(title: "Norsk (Bokmål)", style: .brand(.headline(color: .primary)), appendSpacer: false)
            bag += section.append(norwegianRow).onValue { _ in
                pickLanguage(locale: .nb_NO)

                UIView.transition(with: englishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    englishRowImageView.image = nil
                       }, completion: nil)

                UIView.transition(with: norwegianRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    norwegianRowImageView.image = Asset.circularCheckmark.image
                       }, completion: nil)
            }

            norwegianRow.prepend(Asset.flagNO.image)
            norwegianRow.append(norwegianRowImageView)
        }

        let marketSection = ButtonSection(text: L10n.settingsChangeMarket, style: .danger)

        bag += marketSection.onSelect.onValue { _ in
            let alert = Alert(
                title: L10n.settingsAlertChangeMarketTitle,
                message: L10n.settingsAlertChangeMarketText,
                actions: [
                    Alert.Action(title: L10n.settingsAlertChangeMarketOk) {
                        ApolloClient.cache = InMemoryNormalizedCache()
                        ApplicationState.preserveState(.marketPicker)
                        CrossFramework.onRequestLogout()
                    },
                    Alert.Action(title: L10n.settingsAlertChangeMarketCancel) {},
                ]
            )

            viewController.present(alert)
        }

        bag += form.append(Spacing(height: 20))
        bag += form.append(marketSection)

        return (viewController, bag)
    }
}
