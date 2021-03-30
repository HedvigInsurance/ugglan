import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

public struct AppInfoRow {
    public init(title: String, icon: UIImage?, isTappable: Bool, value: Future<String>) {
        self.title = title
        self.icon = icon
        self.isTappable = isTappable
        self.value = value
        onSelect = onSelectCallbacker.providedSignal
    }

    let title: String
    let icon: UIImage?
    let isTappable: Bool
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

        imageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        row.setCustomSpacing(16, after: imageView)

        let chevronImageView = UIImageView()
        chevronImageView.image = hCoreUIAssets.chevronRight.image

        if isTappable {
            row.append(chevronImageView)
            bag += events.onSelect.lazyBindTo(callbacker: onSelectCallbacker)
        }

        bag += value.onValue { string in
            row.subtitle = string
            activityIndicator.stopAnimating()
        }

        return (row, bag)
    }
}
