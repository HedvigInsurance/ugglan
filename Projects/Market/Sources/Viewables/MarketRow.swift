import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct MarketRow {
    @ReadWriteState var market: Market
}

extension MarketRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(
            title: L10n.MarketLanguageScreen.marketLabel,
            subtitle: market.title,
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary(state: .negative)))
                style.subtitle = .brand(.subHeadline(color: .secondary(state: .negative)))
            }
        )
        bag += $market.map { $0.title }.bindTo(row, \.subtitle)

        let flagImageView = UIImageView()
        flagImageView.image = market.icon
        flagImageView.contentMode = .scaleAspectFit
        row.prepend(flagImageView)

        bag += $market.map { $0.icon }.bindTo(flagImageView, \.image)

        flagImageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        row.setCustomSpacing(16, after: flagImageView)

        let chevronImageView = UIImageView()
        chevronImageView.tintColor = .white
        chevronImageView.image = hCoreUIAssets.chevronRight.image

        row.append(chevronImageView)

        bag += events.onSelect.compactMap { row.viewController }.onValue { viewController in
            viewController.present(PickMarket(currentMarket: market).wrappedInCloseButton(), style: .detented(.scrollViewContentSize(20))).onValue { newMarket in
                $market.value = newMarket
            }
        }

        return (row, bag)
    }
}
