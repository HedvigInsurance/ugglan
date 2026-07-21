import SwiftUI
import UIKit
import hCore

public enum ThemeOption: String, CaseIterable, Identifiable, Sendable {
    case light
    case dark
    case system

    public var id: String { rawValue }

    public static let storageKey = "theme_option"

    public static var current: ThemeOption {
        get {
            UserDefaults.standard.string(forKey: storageKey)
                .flatMap(ThemeOption.init(rawValue:)) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }

    public var displayName: String {
        switch self {
        case .system: return L10n.settingsThemeSystemDefault
        case .light: return L10n.settingsThemeLight
        case .dark: return L10n.settingsThemeDark
        }
    }

    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }

    @MainActor
    public func apply(animated: Bool = true) {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
        for window in windows {
            guard window.overrideUserInterfaceStyle != userInterfaceStyle else { continue }
            // SwiftUI re-resolves colors a render pass after the trait change, so a plain
            // cross-dissolve fades between two identical frames. Fade out a snapshot of the
            // old appearance instead, letting SwiftUI re-render hidden behind it.
            if animated, let snapshot = window.snapshotView(afterScreenUpdates: false) {
                window.addSubview(snapshot)
                window.overrideUserInterfaceStyle = userInterfaceStyle
                UIView.animate(
                    withDuration: 0.3,
                    animations: { snapshot.alpha = 0 },
                    completion: { _ in snapshot.removeFromSuperview() }
                )
            } else {
                window.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
    }
}
