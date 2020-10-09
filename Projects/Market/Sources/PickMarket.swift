import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct PickMarket {
    let currentMarket: Market
}

extension PickMarket: Presentable {
    func materialize() -> (UIViewController, Future<Market>) {
        let viewController = UIViewController()
        viewController.title = L10n.MarketLanguageScreen.marketLabel
        let bag = DisposeBag()

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection()

        return (viewController, Future { completion in
            Market.allCases.forEach { market in
                let row = RowView(title: market.title)

                let iconImageView = UIImageView()
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.image = market.icon
                row.prepend(iconImageView)

                row.setCustomSpacing(16, after: iconImageView)

                if market == currentMarket {
                    row.append(Asset.checkmark.image)
                }

                bag += section.append(row).onValue {
                    completion(.success(market))
                }
            }

            return bag
        })
    }
}
