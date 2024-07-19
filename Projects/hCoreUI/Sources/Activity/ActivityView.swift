import Flow
import Foundation
import Presentation
import SwiftUI

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

public struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    public init(
        activityItems: [Any],
        applicationActivities: [UIActivity]? = nil
    ) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }

    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    public func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) {}
}

public struct ModalPresentationSourceWrapper<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content
    @ObservedObject var vm: ModalPresentationSourceWrapperViewModel

    public init(content: @escaping () -> Content, vm: ModalPresentationSourceWrapperViewModel) {
        self.content = content
        self.vm = vm
    }

    public func makeUIView(context: Context) -> UIView {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.layer.cornerRadius = 12
        vc.view.clipsToBounds = true
        vm.view = vc.view
        return vc.view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        vm.view = uiView
    }
}

public class ModalPresentationSourceWrapperViewModel: ObservableObject {
    weak var view: UIView?

    public init() {}

    public func present(activity: UIActivityViewController) {
        if let view, let vc = view.viewController {
            activity.popoverPresentationController?.sourceView = view
            activity.popoverPresentationController?.sourceRect = view.bounds
            vc.present(activity, animated: true)
        }
    }
}
