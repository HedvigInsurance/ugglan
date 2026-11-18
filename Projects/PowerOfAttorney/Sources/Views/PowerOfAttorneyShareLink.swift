import SwiftUI
import hCore
import hCoreUI

/// "Share" button for a power of attorney link. The system share sheet opens as a popover attached to the button
/// itself (also on iPhone), not as a sheet from the bottom of the screen.
///
/// SwiftUI's `ShareLink` can't do this: on iPhone it always presents the share sheet from the bottom. So the button
/// is an `hButton` with an invisible UIKit anchor view behind it, which the share sheet popover points at.
struct PowerOfAttorneyShareLink: View {
    let url: URL
    let size: hButtonSize
    let type: hButtonConfigurationType
    @State private var presenter = ShareSheetPopoverPresenter()

    var body: some View {
        hButton(
            size,
            type,
            // TODO: Localize via Lokalise
            content: .init(title: "Share")
        ) { [url, presenter] in
            presenter.present(url: url)
        }
        .background(ShareSheetAnchorView(presenter: presenter))
    }
}

@MainActor
private final class ShareSheetPopoverPresenter: NSObject, UIPopoverPresentationControllerDelegate {
    weak var anchorView: UIView?

    func present(url: URL) {
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
    nonisolated func adaptivePresentationStyle(
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
        PowerOfAttorneyShareLink(url: URL(string: "https://www.hedvig.com")!, size: .large, type: .primary)
        PowerOfAttorneyShareLink(url: URL(string: "https://www.hedvig.com")!, size: .small, type: .secondary)
            .fixedSize()
    }
    .padding()
}
