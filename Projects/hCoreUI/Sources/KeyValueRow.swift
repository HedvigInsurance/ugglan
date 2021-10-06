import Flow
import Form
import Foundation
import UIKit
import hCore

public struct KeyValueRow {
    public let isHiddenSignal = ReadWriteSignal<Bool>(false)
    public let keySignal = ReadWriteSignal<String>("")
    public let valueSignal = ReadWriteSignal<String>("")
    public let valueStyleSignal = ReadWriteSignal<TextStyle>(.brand(.headline(color: .primary)))

    public init() {}
}

extension KeyValueRow: Viewable {
    public func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView(title: "", style: .brand(.headline(color: .primary)))
        bag += isHiddenSignal.atOnce().bindTo(row, \.isHidden)

        bag += keySignal.atOnce().onValue { value in row.title = value }

        let valueLabel = UILabel()
        row.append(valueLabel)

        bag += valueSignal.atOnce().withLatestFrom(valueStyleSignal.atOnce())
            .map { StyledText(text: $0, style: $1) }.bindTo(valueLabel, \.styledText)

        return (row, bag)
    }
}
