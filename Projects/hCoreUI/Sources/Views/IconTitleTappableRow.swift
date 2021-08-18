import Flow
import Form
import Foundation
import UIKit
import hCore

public struct IconTitleTappableRow {
  public init(
    title: String,
    icon: UIImage?
  ) {
    self.title = title
    self.icon = icon
  }

  let title: String
  let icon: UIImage?
}

extension IconTitleTappableRow: Viewable {
  public func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
    let bag = DisposeBag()
    let row = RowView(
      title: title,
      subtitle: "",
      style: TitleSubtitleStyle.default.restyled { (style: inout TitleSubtitleStyle) in
        style.title = .brand(.headline(color: .primary))
        style.subtitle = .brand(.subHeadline(color: .secondary))
      }
    )

    row.backgroundColor = .brand(.secondaryBackground())
    row.layer.cornerRadius = 8

    let imageView = UIImageView()
    imageView.image = icon
    imageView.contentMode = .scaleAspectFit
    row.prepend(imageView)

    imageView.snp.makeConstraints { make in
      make.width.equalTo(24)
    }

    return (row, bag)
  }
}
