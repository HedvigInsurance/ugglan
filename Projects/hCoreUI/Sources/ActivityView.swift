import Flow
import Foundation
import Presentation
import UIKit

extension PresentationStyle {
    public static let activityView = PresentationStyle(name: "activityView") { viewController, from, _ in
        let future = Future<Void> { completion in
            from.present(viewController, animated: true) { completion(.success) }

            return NilDisposer()
        }

        return (future, { Future() })
    }
}

public struct ActivityView {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let sourceView: UIView?
    let sourceRect: CGRect?

    public let completionSignal: ReadWriteSignal<(UIActivity.ActivityType?, Bool)>

    public init(
        activityItems: [Any],
        applicationActivities: [UIActivity]?,
        sourceView: UIView?,
        sourceRect: CGRect?,
        completionSignal: ReadWriteSignal<(UIActivity.ActivityType?, Bool)> = ReadWriteSignal<
            (UIActivity.ActivityType?, Bool)
        >((nil, false))
    ) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.sourceView = sourceView
        self.sourceRect = sourceRect
        self.completionSignal = completionSignal
    }
}

extension ActivityView: Presentable {
    public func materialize() -> (UIActivityViewController, Disposable) {
        let viewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        viewController.preferredPresentationStyle = .activityView

        if let popover = viewController.popoverPresentationController, let sourceRect = sourceRect {
            popover.sourceView = sourceView
            popover.sourceRect = sourceRect
        }

        viewController.completionWithItemsHandler = { activity, success, _, _ in
            self.completionSignal.value = (activity, success)
        }

        return (viewController, NilDisposer())
    }
}
