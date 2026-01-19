import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UIKit
import hCore
import hCoreUI

struct NavigationBarProgressModifier: ViewModifier {
    @Binding var progress: Double
    @State private var progressView: UIProgressView?

    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { viewController in
                if let navigationController = viewController.navigationController, progressView == nil {
                    setupProgressView(for: navigationController)
                }
            }
            .onChange(of: progress) { newProgress in
                progressView?.setProgress(Float(newProgress), animated: true)
                progressView?.accessibilityValue = "\(Int(newProgress * 100))%"
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
        progress.progress = Float(self.progress)
        progress.isAccessibilityElement = true
        progress.accessibilityLabel = L10n.embarkLoading
        progress.accessibilityValue = "\(Int(self.progress * 100))%"
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

extension View {
    func navigationBarProgress(_ progress: Binding<Double>) -> some View {
        modifier(NavigationBarProgressModifier(progress: progress))
    }
}
