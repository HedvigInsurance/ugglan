import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore

extension View {
    public func addProgressBar(with progress: Binding<Float?>) -> some View {
        self.modifier(ProgressBarView(progress: progress))
    }
}

struct ProgressBarView: ViewModifier {
    @Binding var progress: Float?
    @State private var progressView: UIProgressView?

    init(
        progress: Binding<Float?>
    ) {
        _progress = progress
    }

    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { viewController in
                let navigationController =
                    (viewController as? UINavigationController)
                    ?? viewController.navigationController
                if let navigationController, progressView == nil {
                    setupProgressView(for: navigationController)
                }
            }
            .onChange(of: progress) { newProgress in
                progressView?.isHidden = newProgress == nil
                if let newProgress {
                    progressView?.setProgress(newProgress, animated: true)
                    progressView?.accessibilityValue = "\(Int(newProgress * 100))%"
                }
            }
    }

    private func setupProgressView(for navigationController: UINavigationController) {
        let navBar = navigationController.navigationBar

        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = UIColor(
            light: hFillColor.Opaque.primary.colorFor(.light, .base).color.uiColor(),
            dark: hFillColor.Opaque.primary.colorFor(.dark, .base).color.uiColor()
        )
        progress.trackTintColor = .clear

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .regular)
        DefaultStyling.applyCommonNavigationBarStyling(appearance)
        appearance.shadowColor = UIColor(
            light: hBorderColor.primary.colorFor(.light, .base).color.uiColor(),
            dark: hBorderColor.primary.colorFor(.dark, .base).color.uiColor()
        )

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        progress.progress = Float(self.progress ?? 0)
        progress.isAccessibilityElement = true
        progress.accessibilityLabel = L10n.embarkLoading
        progress.accessibilityValue = "\(Int((self.progress ?? 0) * 100))%"
        progress.accessibilityTraits = .updatesFrequently
        progress.accessibilityElementsHidden = true
        navBar.addSubview(progress)
        // Added additional 2 points to avoid rounding progress bar on edges
        NSLayoutConstraint.activate([
            progress.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: -2),
            progress.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: 2),
            progress.centerYAnchor.constraint(equalTo: navBar.bottomAnchor),
            progress.heightAnchor.constraint(equalToConstant: 3),
        ])

        self.progressView = progress
    }
}
