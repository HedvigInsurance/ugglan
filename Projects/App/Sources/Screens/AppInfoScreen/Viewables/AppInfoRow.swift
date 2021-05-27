import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

public struct AppInfoRow {
	public init(
		title: String,
		icon: UIImage?,
		trailingIcon: UIImage?,
		value: Future<String>
	) {
		self.title = title
		self.icon = icon
		self.trailingIcon = trailingIcon
		self.value = value
		onSelect = onSelectCallbacker.providedSignal
	}

	let title: String
	let icon: UIImage?
	let trailingIcon: UIImage?
	let value: Future<String>

	private let onSelectCallbacker = Callbacker<Void>()
	public let onSelect: Signal<Void>
}

extension AppInfoRow: Viewable {
	public func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
		let bag = DisposeBag()
		let row = RowView(
			title: title,
			subtitle: "",
			style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
				style.title = .brand(.headline(color: .primary))
				style.subtitle = .brand(.subHeadline(color: .secondary))
			}
		)

		let imageView = UIImageView()
		imageView.image = icon
		imageView.contentMode = .scaleAspectFit
		row.prepend(imageView)

		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.hidesWhenStopped = true
		activityIndicator.color = .brand(.primaryTintColor)
		activityIndicator.startAnimating()

		row.append(activityIndicator)

		imageView.snp.makeConstraints { make in make.width.equalTo(24) }

		row.setCustomSpacing(16, after: imageView)

		if let trailingIcon = trailingIcon {
			let trailingImageView = UIImageView()
			trailingImageView.image = trailingIcon
			row.append(trailingImageView)
			bag += events.onSelect.lazyBindTo(callbacker: onSelectCallbacker)
		}

		bag += value.onValue { value in row.subtitle = value
			activityIndicator.stopAnimating()

			bag += row.subtitleLabel?.copySignal.onValue { _ in UIPasteboard.general.value = value }
		}

		return (row, bag)
	}
}
