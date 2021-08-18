import Flow
import Form
import Foundation
import UIKit
import hCore

public struct ButtonSection {
    public let text: ReadWriteSignal<String>
    public let isHiddenSignal = ReadWriteSignal<Bool>(false)
    public let style: Style

    public enum Style { case normal, danger }

    private let onSelectCallbacker = Callbacker<Void>()
    public let onSelect: Signal<Void>

    public init(
        text: String,
        style: Style
    ) {
        self.text = ReadWriteSignal(text)
        self.style = style
        onSelect = onSelectCallbacker.providedSignal
    }
}

extension ButtonSection: Viewable {
    public func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(headerView: nil, footerView: nil)

        bag += isHiddenSignal.bindTo(section, \.isHidden)

        let buttonRow = ButtonRow(
            text: "",
            style: style == .normal ? .brand(.body(color: .link)) : .brand(.body(color: .destructive))
        )

        bag += text.atOnce().bindTo(buttonRow.text)

        bag += buttonRow.onSelect.lazyBindTo(callbacker: onSelectCallbacker)

        bag += section.append(buttonRow)

        return (section, bag)
    }
}
