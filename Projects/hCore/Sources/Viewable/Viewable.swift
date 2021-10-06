import Flow
import Form
import Foundation
import UIKit

public protocol Viewable {
    associatedtype Matter
    associatedtype Result
    associatedtype Events

    func materialize(events: Events) -> (Matter, Result)
}

public struct ViewableEvents {
    public let wasAdded: Signal<Void>
    public let removeAfter = Delegate<Void, TimeInterval>()

    public init(wasAddedCallbacker: Callbacker<Void>) { wasAdded = wasAddedCallbacker.providedSignal }
}

public struct SelectableViewableEvents {
    public let wasAdded: Signal<Void>
    public let removeAfter = Delegate<Void, TimeInterval>()
    private let onSelectCallbacker: Callbacker<Void>

    public var onSelect: Signal<Void> { onSelectCallbacker.providedSignal }

    public init(
        wasAddedCallbacker: Callbacker<Void>,
        onSelectCallbacker: Callbacker<Void>
    ) {
        wasAdded = wasAddedCallbacker.providedSignal
        self.onSelectCallbacker = onSelectCallbacker
    }
}
