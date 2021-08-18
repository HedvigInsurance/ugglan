import Flow
import Form
import Foundation
import hCore
import hCoreUI

struct KeyGearCoverage {
  let type: CoverageType
  let title: String

  enum CoverageType { case included, excluded }
}

extension KeyGearCoverage: Viewable {
  func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
    let row = RowView()
    let bag = DisposeBag()

    let icon = Icon(
      icon: type == .included ? Asset.circularCheckmark.image : Asset.pinkCircularCross.image,
      iconWidth: 15
    )
    icon.snp.makeConstraints { make in make.width.equalTo(30) }
    row.prepend(icon)

    bag += row.append(MultilineLabel(value: title, style: .brand(.body(color: .primary))))

    return (row, bag)
  }
}
