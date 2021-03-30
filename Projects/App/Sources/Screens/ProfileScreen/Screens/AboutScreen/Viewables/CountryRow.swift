import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit
import Market

public struct CountryRow {
    let market: Market
    
    public init(market: Market) {
        self.market = market
    }
}

extension CountryRow: Viewable {
    public func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(
            title: L10n.MarketLanguageScreen.marketLabel,
            subtitle: market.title,
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary))
                style.subtitle = .brand(.subHeadline(color: .secondary))
            }
        )

        let flagImageView = UIImageView()
        flagImageView.image = market.icon
        flagImageView.contentMode = .scaleAspectFit
        row.prepend(flagImageView)

        flagImageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        row.setCustomSpacing(16, after: flagImageView)

        let chevronImageView = UIImageView()
        chevronImageView.tintColor = .white
        chevronImageView.image = hCoreUIAssets.chevronRight.image

        row.append(chevronImageView)

        return (row, bag)
    }
}
