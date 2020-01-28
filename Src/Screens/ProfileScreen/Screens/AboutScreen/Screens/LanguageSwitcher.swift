//
//  LanguageSwitcher.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-17.
//

import Foundation
import Flow
import Form
import Presentation
import Apollo

extension Notification.Name {
    static let localeSwitched = Notification.Name("localeSwitched")
}

extension UIApplication {
    // reloads all text that is derived from translations in the app
    func reloadAllLabels() {
        func reloadLabels(in base: UIView) {
            for view in base.subviews {
                if let label = view as? UILabel {
                    if let key = label.text?.localizationKey {
                        label.text = String(key: key)
                        label.layoutIfNeeded()
                        label.sizeToFit()
                    } else if let key = label.value.displayValue.localizationKey {
                        label.value = String(key: key)
                        label.layoutIfNeeded()
                        label.sizeToFit()
                    }
                } else if let button = view as? UIButton {
                    let title = button.title(for: .normal)
                    if let key = title?.localizationKey {
                        button.setTitle(String(key: key), for: .normal)
                    }
                }

                reloadLabels(in: view)
            }
        }
        
        func reloadViewControllers(in base: UIViewController) {
            if let key = base.title?.localizationKey {
                base.title = String(key: key)
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

struct LanguageSwitcher {
    @Inject var client: ApolloClient
}

extension LanguageSwitcher: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Språk/Language"
        let bag = DisposeBag()
        
        let form = FormView(sections: [], style: .defaultGrouped)
        bag += viewController.install(form)
        
        let section = form.appendSection(header: nil, footer: nil, style: .sectionPlain)
        
        func reloadAllLabels() {
            UIApplication.shared.reloadAllLabels()
        }
        
        let englishRowImageView = UIImageView()
        englishRowImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        if Localization.Locale.currentLocale == .en_SE {
            englishRowImageView.image = Asset.greenCircularCheckmark.image
        }
        
        let swedishRowImageView = UIImageView()
        swedishRowImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        if Localization.Locale.currentLocale == .sv_SE {
            swedishRowImageView.image = Asset.greenCircularCheckmark.image
        }
        
        func pickLanguage(locale: Localization.Locale) {
            ApplicationState.setPreferredLocale(locale)
            Localization.Locale.currentLocale = locale
            ApolloClient.initClient().always {
                TranslationsRepo.clear().onValue { _ in
                    reloadAllLabels()
                    NotificationCenter.default.post(Notification(name: .localeSwitched))
                }
            }
            bag += self.client.perform(mutation: UpdateLanguageMutation(language: locale.code)).onValue { _ in }
        }
        
        let englishRow = RowView(title: "English", style: .rowTitle, appendSpacer: false)
        bag += section.append(englishRow).onValue { _ in
            pickLanguage(locale: .en_SE)
                        
            UIView.transition(with: englishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                englishRowImageView.image = Asset.greenCircularCheckmark.image
            }, completion: nil)
            
            UIView.transition(with: swedishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                swedishRowImageView.image = nil
            }, completion: nil)
        }
        
        englishRow.prepend(Asset.flagGB.image)
        englishRow.append(englishRowImageView)
        
        let swedishRow = RowView(title: "Svenska", style: .rowTitle, appendSpacer: false)
        bag += section.append(swedishRow).onValue { _ in
            pickLanguage(locale: .sv_SE)

            UIView.transition(with: englishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                englishRowImageView.image = nil
            }, completion: nil)
            
            UIView.transition(with: swedishRowImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                swedishRowImageView.image = Asset.greenCircularCheckmark.image
            }, completion: nil)
        }
        
        swedishRow.prepend(Asset.flagSE.image)
        swedishRow.append(swedishRowImageView)
        
        return (viewController, bag)
    }
}
