import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct LanguageRow {
    @ReadWriteState var currentMarket: Market
}

extension LanguageRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView(
            title: L10n.MarketLanguageScreen.languageLabel,
            subtitle: Localization.Locale.currentLocale.displayName,
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary(state: .negative)))
                style.subtitle = .brand(.subHeadline(color: .secondary(state: .negative)))
            }
        )
        bag += Localization.Locale.$currentLocale.map { $0.displayName }.bindTo(row, \.subtitle)

        let iconImageView = UIImageView()
        iconImageView.image = Asset.globe.image
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white

        row.prepend(iconImageView)

        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        row.setCustomSpacing(16, after: iconImageView)

        row.append(hCoreUIAssets.chevronRight.image)

        bag += events.onSelect.compactMap { row.viewController }.onValue { viewController in
            viewController.present(PickLanguage(currentMarket: currentMarket).wrappedInCloseButton(), style: .detented(.scrollViewContentSize(20))).onValue { locale in
                Localization.Locale.currentLocale = locale
                UIApplication.shared.reloadAllLabels()
            }
        }

        return (row, bag)
    }
}
