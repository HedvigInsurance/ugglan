import SwiftUI
import hCore

/// Button that shares a URL. The system share sheet opens as a popover attached to the button itself (also on
/// iPhone), not as a sheet from the bottom of the screen.
///
/// SwiftUI's `ShareLink` can't do this: on iPhone it always presents the share sheet from the bottom. So the button
/// is an `hButton` with an invisible UIKit anchor view behind it, which the share sheet popover points at.
///
/// Pass your own `ShareSheetPopoverPresenter` to open the same popover from somewhere else too, e.g. when tapping the
/// row the button sits in: `presenter.present(url:)` still anchors the popover to the button.
public struct PopoverShareButton: View {
    let url: URL
    let title: String
    let size: hButtonSize
    let type: hButtonConfigurationType
    let externalPresenter: ShareSheetPopoverPresenter?
    @State private var ownPresenter = ShareSheetPopoverPresenter()

    private var presenter: ShareSheetPopoverPresenter { externalPresenter ?? ownPresenter }

    public init(
        url: URL,
        title: String,
        size: hButtonSize,
        type: hButtonConfigurationType,
        presenter: ShareSheetPopoverPresenter? = nil
    ) {
        self.url = url
        self.title = title
        self.size = size
        self.type = type
        self.externalPresenter = presenter
    }

    public var body: some View {
        hButton(
            size,
            type,
            content: .init(title: title)
        ) { [url, presenter] in
            presenter.present(url: url)
        }
        .background(ShareSheetAnchorView(presenter: presenter))
    }
}

@MainActor
public final class ShareSheetPopoverPresenter: NSObject, UIPopoverPresentationControllerDelegate {
    weak var anchorView: UIView?

    override public init() {
        super.init()
    }

    public func present(url: URL) {
        guard let anchorView, anchorView.window != nil,
            let presentingViewController = UIApplication.shared.getTopViewController()
        else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = anchorView
            popover.sourceRect = anchorView.bounds
            popover.permittedArrowDirections = [.up, .down]
            popover.delegate = self
        }
        presentingViewController.present(activityViewController, animated: true)
    }

    // Keep the popover on iPhone instead of letting it adapt into a sheet from the bottom
    nonisolated public func adaptivePresentationStyle(
        for _: UIPresentationController,
        traitCollection _: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }
}

private struct ShareSheetAnchorView: UIViewRepresentable {
    let presenter: ShareSheetPopoverPresenter

    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        presenter.anchorView = view
        return view
    }

    func updateUIView(_ uiView: UIView, context _: Context) {
        presenter.anchorView = uiView
    }
}

#Preview {
    VStack {
        PopoverShareButton(url: URL(string: "https://www.hedvig.com")!, title: "Share", size: .large, type: .primary)
        PopoverShareButton(url: URL(string: "https://www.hedvig.com")!, title: "Share", size: .small, type: .secondary)
            .fixedSize()
    }
    .padding()
}
