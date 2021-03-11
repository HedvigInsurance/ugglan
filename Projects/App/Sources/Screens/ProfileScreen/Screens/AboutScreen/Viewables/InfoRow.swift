import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit
import Market

public struct AppInfoRow {
    let title: String
    let icon: UIImage?
    let isTappable: Bool
    let value: String
}

extension AppInfoRow: Viewable {
    public func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(
            title: title,
            subtitle: value,
            style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
                style.title = .brand(.headline(color: .primary))
                style.subtitle = .brand(.subHeadline(color: .secondary))
            }
        )

        let imageView = UIImageView()
        imageView.image = icon
        imageView.contentMode = .scaleAspectFit
        row.prepend(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(24)
        }

        row.setCustomSpacing(16, after: imageView)

        let chevronImageView = UIImageView()
        chevronImageView.tintColor = .white
        chevronImageView.image = hCoreUIAssets.chevronRight.image
        
        if isTappable {
            row.append(chevronImageView)
        }

        return (row, bag)
    }
}
