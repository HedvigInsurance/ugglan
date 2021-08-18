import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct UpdatingMessage {}

extension UpdatingMessage: Viewable {
  func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
    let bag = DisposeBag()
    let row = RowView()

    let label = MultilineLabel(
      styledText: StyledText(
        text: L10n.myPaymentUpdatingMessage,
        style: .brand(.body(color: .primary))
      )
    )
    bag += row.addArranged(label)

    return (row, bag)
  }
}
