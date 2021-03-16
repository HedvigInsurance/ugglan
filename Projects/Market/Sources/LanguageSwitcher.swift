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

public extension UIApplication {
    // reloads all text that is derived from translations in the app
    func reloadAllLabels() {
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

        func pickLanguage(locale: Localization.Locale) {
            Localization.Locale.currentLocale = locale
        }

        Market.fromLocalization(Localization.Locale.currentLocale.market).languages.forEach { language in
            let checkMarkImageView = UIImageView()
            checkMarkImageView.snp.makeConstraints { make in
                make.width.equalTo(20)
                make.height.equalTo(20)
            }

            bag += Localization.Locale.$currentLocale.atOnce().onValue { locale in
                if locale == language {
                    checkMarkImageView.image = Asset.checkmark.image
                } else {
                    checkMarkImageView.image = nil
                }
            }

            let row = RowView(title: language.displayName, style: .brand(.headline(color: .primary)), appendSpacer: false)
            row.append(checkMarkImageView)
            bag += section.append(row).onValue { _ in
                pickLanguage(locale: language)
            }
        }

        let marketSection = ButtonSection(text: L10n.settingsChangeMarket, style: .danger)

        bag += marketSection.onSelect.onValue { _ in
            let alert = Alert(
                title: L10n.settingsAlertChangeMarketTitle,
                message: L10n.settingsAlertChangeMarketText,
                actions: [
                    Alert.Action(title: L10n.alertOk) {
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
