import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct MultilineLabelIcon {
    let styledTextSignal: ReadWriteSignal<StyledText>
    let iconAsset: ImageAsset
    let iconWidth: CGFloat

    init(
        styledText: StyledText,
        icon: ImageAsset,
        iconWidth: CGFloat
    ) {
        styledTextSignal = ReadWriteSignal(styledText)
        iconAsset = icon
        self.iconWidth = iconWidth
    }
}

extension MultilineLabelIcon: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading

        view.spacing = 10

        let iconContainer = UIView()
        view.addArrangedSubview(iconContainer)

        iconContainer.snp.makeConstraints { make in make.width.equalTo(iconWidth) }

        let icon = Icon(icon: iconAsset.image, iconWidth: iconWidth)
        iconContainer.addSubview(icon)

        icon.snp.makeConstraints { make in make.height.equalTo(iconWidth + 4) }

        let label = UILabel()

        bag += styledTextSignal.atOnce()
            .map { styledText -> StyledText in
                styledText.restyled { (textStyle: inout TextStyle) in textStyle.numberOfLines = 0
                    textStyle.lineBreakMode = .byWordWrapping
                    textStyle.lineHeight = 14
                }
            }
            .bindTo(label, \.styledText)

        view.addArrangedSubview(label)

        bag += label.didLayoutSignal.onValue {
            label.preferredMaxLayoutWidth = label.frame.size.width
            label.snp.makeConstraints { make in make.height.equalTo(label.intrinsicContentSize.height) }
        }

        return (view, bag)
    }
}
