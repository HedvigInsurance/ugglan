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

extension View {
    public func addStepProgressBar(with progress: Binding<StepProgressModel>) -> some View {
        self.modifier(StepProgressBarView(progress: progress))
    }
}

public struct StepProgressModel: Equatable {
    public let currentStep: Int
    public let totalSteps: Int
    public init(currentStep: Int, totalSteps: Int) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }
}

struct StepProgressBarView: ViewModifier {
    @Binding var progress: StepProgressModel
    @State private var stackView: UIStackView?

    init(
        progress: Binding<StepProgressModel>
    ) {
        _progress = progress
    }

    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { viewController in
                let navigationController =
                    (viewController as? UINavigationController)
                    ?? viewController.navigationController
                if let navigationController, stackView == nil {
                    setupProgressView(for: navigationController)
                    handleStackView(with: progress)
                }
            }
            .onChange(of: progress) { newProgress in
                handleStackView(with: newProgress)
            }
    }

    private func handleStackView(with progress: StepProgressModel) {
        if let stackView {
            if stackView.subviews.count < progress.totalSteps && progress.totalSteps > 1 {
                for i in 1...progress.totalSteps - stackView.subviews.count {
                    let viewToAdd = UIView()
                    viewToAdd.backgroundColor = .clear
                    viewToAdd.layer.cornerRadius = 2
                    stackView.addArrangedSubview(viewToAdd)
                    if #available(iOS 18.0, *) {
                        viewToAdd.anchorPoint = .init(x: 0.5, y: 0.5)
                        Task { @MainActor in
                            await delay(TimeInterval(i) * 0.2 + 0.1)
                            UIView.animate(.bouncy) {
                                viewToAdd.transform = .init(scaleX: 1.1, y: 1.8)
                            }
                            await delay(0.4)
                            UIView.animate(.bouncy) {
                                viewToAdd.transform = .identity
                            }
                        }
                    }
                }
            }
        }
        stackView?.arrangedSubviews.enumerated()
            .forEach { (index, element) in
                UIView.animate(withDuration: 0.2) {
                    if index + 1 == progress.currentStep {
                        element.backgroundColor = UIColor(
                            light: hFillColor.Opaque.primary.colorFor(.light, .base).color.uiColor(),
                            dark: hFillColor.Opaque.primary.colorFor(.dark, .base).color.uiColor()
                        )
                    } else {
                        element.backgroundColor = UIColor(
                            light: hSurfaceColor.Opaque.secondary.colorFor(.light, .base).color.uiColor(),
                            dark: hSurfaceColor.Opaque.secondary.colorFor(.dark, .base).color.uiColor()
                        )
                    }
                }
            }
    }

    private func setupProgressView(for navigationController: UINavigationController) {
        let navBar = navigationController.navigationBar

        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

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
        stackView.isAccessibilityElement = true
        stackView.accessibilityElementsHidden = true
        navBar.addSubview(stackView)
        let layoutGuide = navBar.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 80),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -80),
            stackView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 3),
        ])
        stackView.backgroundColor = .clear
        self.stackView = stackView
    }
}
