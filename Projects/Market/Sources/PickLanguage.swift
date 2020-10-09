import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct PickLanguage {
    let currentMarket: Market
}

extension PickLanguage: Presentable {
    func materialize() -> (UIViewController, Future<Localization.Locale>) {
        let viewController = UIViewController()
        viewController.title = L10n.LanguagePickerModal.title
        let bag = DisposeBag()

        let form = FormView()
        bag += viewController.install(form)

        let titleSection = form.appendSection()
        titleSection.append(L10n.LanguagePickerModal.text, style: .brand(.body(color: .secondary)))

        let section = form.appendSection()
        return (viewController, Future { completion in

            currentMarket.languages.forEach { language in
                let row = RowView(title: language.displayName)

                if language == Localization.Locale.currentLocale {
                    row.append(Asset.checkmark.image)
                }

                bag += section.append(row).onValue {
                    completion(.success(language))
                }
            }

            return bag
        })
    }
}
