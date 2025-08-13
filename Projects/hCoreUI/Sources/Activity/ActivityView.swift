import Foundation
import SwiftUI

public struct ModalPresentationSourceWrapper<Content: View>: UIViewRepresentable {
    @ViewBuilder var content: () -> Content
    @ObservedObject var vm: ModalPresentationSourceWrapperViewModel

    public init(content: @escaping () -> Content, vm: ModalPresentationSourceWrapperViewModel) {
        self.content = content
        self.vm = vm
    }

    public func makeUIView(context _: Context) -> UIView {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = .clear
        vc.view.layer.cornerRadius = 12
        vc.view.clipsToBounds = true
        vm.view = vc.view
        return vc.view
    }

    public func updateUIView(_ uiView: UIView, context _: Context) {
        vm.view = uiView
    }
}

@MainActor
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
