import Form
import UIKit

extension SectionStyle {
    public static let defaultStyle = SectionStyle(
        insets: .zero,
        rowInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15),
        itemSpacing: 0,
        minRowHeight: 10,
        background: .init(all: UIColor.clear.asImage()),
        selectedBackground: .init(all: UIColor.clear.asImage()),
        shadow: .none,
        header: .none,
        footer: .none
    )
}
