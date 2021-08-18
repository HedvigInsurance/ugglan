import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct LanguageRow { @ReadWriteState var currentMarket: Market }

extension LanguageRow: Viewable {
	func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
		let bag = DisposeBag()

		let row = RowView(
			title: "",
			subtitle: "",
			style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
				style.title = .brand(.headline(color: .primary(state: .negative)))
				style.subtitle = .brand(.subHeadline(color: .secondary(state: .negative)))
			}
		)
		bag += Localization.Locale.$currentLocale.atOnce().map { $0.displayName }.bindTo(row, \.subtitle)

		bag += Localization.Locale.$currentLocale.atOnce().delay(by: 0)
			.transition(style: .crossDissolve(duration: 0.25), with: row) { _ in
				row.title = L10n.MarketLanguageScreen.languageLabel
			}

		let iconImageView = UIImageView()
		iconImageView.image = Asset.globe.image
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.tintColor = .white

		row.prepend(iconImageView)

		iconImageView.snp.makeConstraints { make in make.width.equalTo(24) }

		row.setCustomSpacing(16, after: iconImageView)

		let chevronImageView = UIImageView()
		chevronImageView.tintColor = .white
		chevronImageView.image = hCoreUIAssets.chevronRight.image

		row.append(chevronImageView)

		bag += events.onSelect.compactMap { row.viewController }
			.onValue { viewController in
				viewController.present(
					PickLanguage(currentMarket: currentMarket).wrappedInCloseButton(),
					style: .detented(.scrollViewContentSize)
				)
				.onValue { locale in Localization.Locale.currentLocale = locale }
			}

		return (row, bag)
	}
}
