import Flow
import Foundation
import Presentation
import hCore

struct BusinessModelRow {}

extension BusinessModelRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (IconRow, Disposable) {
        let bag = DisposeBag()

        let row = IconRow(
            title: L10n.businessModelTitle,
            subtitle: "",
            iconAsset: Asset.charityPlain.image,
            options: [.withArrow]
        )

        let store: UgglanStore = globalPresentableStoreContainer.get()
        bag += events.onSelect.onValue { _ in
            store.send(.businessModelDetail)
        }

        return (row, bag)
    }
}
