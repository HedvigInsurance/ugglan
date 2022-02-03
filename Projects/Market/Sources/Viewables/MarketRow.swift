import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct MarketRow {
    @PresentableStore var store: MarketStore

    public init() {}
}

extension MarketRow: Viewable {
    public func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(
            title: "",
            subtitle: "",
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary(state: .negative)))
                style.subtitle = .brand(.subHeadline(color: .secondary(state: .negative)))
            }
        )
        bag += store.stateSignal.atOnce().map { $0.market.title }.bindTo(row, \.subtitle)

        bag += Localization.Locale.$currentLocale.atOnce().delay(by: 0)
            .transition(style: .crossDissolve(duration: 0.25), with: row) { _ in
                row.title = L10n.MarketLanguageScreen.marketLabel
            }

        let flagImageView = UIImageView()
        flagImageView.contentMode = .scaleAspectFit
        row.prepend(flagImageView)

        bag += store.stateSignal.atOnce().map { $0.market.icon }.bindTo(flagImageView, \.image)

        flagImageView.snp.makeConstraints { make in make.width.equalTo(24) }

        row.setCustomSpacing(16, after: flagImageView)

        let chevronImageView = UIImageView()
        chevronImageView.tintColor = .white
        chevronImageView.image = hCoreUIAssets.chevronRight.image

        row.append(chevronImageView)

        bag += events.onSelect.compactMap { row.viewController }
            .onValue { viewController in
                viewController.present(
                    PickMarket(currentMarket: store.state.market).journey
                )
                .sink()
            }

        return (row, bag)
    }
}
