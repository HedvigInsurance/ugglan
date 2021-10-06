import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct IconRow {
    enum Options { case defaults, withArrow, disabled, hidden }

    let iconAsset: UIImage
    let iconWidth: CGFloat
    let iconTint: UIColor?
    let title: ReadWriteSignal<DisplayableString>
    let titleTextStyle = ReadWriteSignal(TextStyle.brand(.headline(color: .primary)))
    let subtitle: ReadWriteSignal<DisplayableString>
    let subtitleTextStyle = ReadWriteSignal(TextStyle.brand(.subHeadline(color: .secondary)))

    let options: ReadWriteSignal<[IconRow.Options]>

    init(
        title: String,
        subtitle: String,
        iconAsset: UIImage,
        iconWidth: CGFloat = 40,
        iconTint: UIColor? = nil,
        options: [IconRow.Options] = [.defaults]
    ) {
        self.title = ReadWriteSignal(title)
        self.subtitle = ReadWriteSignal(subtitle)
        self.iconAsset = iconAsset
        self.iconWidth = iconWidth
        self.iconTint = iconTint
        self.options = ReadWriteSignal(options)
    }
}

extension IconRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let rowView = RowView()
        let icon = Icon(frame: .zero, icon: iconAsset, iconWidth: iconWidth)
        if let iconTint = iconTint { icon.image.tintColor = iconTint }
        let arrow = Icon(frame: .zero, icon: hCoreUIAssets.chevronRight.image, iconWidth: 20)

        let labelsContainer = UIStackView()
        labelsContainer.axis = .vertical
        labelsContainer.spacing = 4

        let titleLabel = UILabel(value: "", style: .default)
        bag += combineLatest(title.atOnce(), titleTextStyle.atOnce())
            .onValue { value, style in titleLabel.styledText = StyledText(text: value, style: style) }

        let subtitleLabel = UILabel(value: "", style: .default)
        bag += combineLatest(subtitle.atOnce(), subtitleTextStyle.atOnce())
            .onValue { value, style in subtitleLabel.isHidden = value.isEmpty
                subtitleLabel.styledText = StyledText(text: value, style: style)
            }

        labelsContainer.addArrangedSubview(titleLabel)
        labelsContainer.addArrangedSubview(subtitleLabel)

        let row = rowView.prepend(icon).append(labelsContainer)

        bag += options.atOnce()
            .onValue { newOptions in
                if newOptions.contains(.withArrow) {
                    row.append(arrow)
                } else {
                    arrow.removeFromSuperview()
                }

                if newOptions.contains(.disabled) { row.alpha = 0.5 } else { row.alpha = 1 }

                if newOptions.contains(.hidden) { row.isHidden = true } else { row.isHidden = false }
            }

        icon.snp.makeConstraints { make in make.width.equalTo(50) }

        arrow.snp.makeConstraints { make in make.width.equalTo(20) }

        return (row, bag)
    }
}
