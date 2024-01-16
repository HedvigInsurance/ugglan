import Foundation
import SwiftUI

struct hRowDividerSettings {
    let insets: EdgeInsets
}

private struct EnvironmentHRowDividerSettings: EnvironmentKey {
    static let defaultValue = hRowDividerSettings(insets: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
}

extension EnvironmentValues {
    var hRowDividerSettings: hRowDividerSettings {
        get { self[EnvironmentHRowDividerSettings.self] }
        set { self[EnvironmentHRowDividerSettings.self] = newValue }
    }
}

private struct EnvironmentHWithoutPadding: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hWithoutDividerPadding: Bool {
        get { self[EnvironmentHWithoutPadding.self] }
        set { self[EnvironmentHWithoutPadding.self] = newValue }
    }
}

extension View {
    public var hWithoutDividerPadding: some View {
        self.environment(\.hWithoutDividerPadding, true)
    }
}

public struct hRowDivider: View {
    @Environment(\.hRowDividerSettings) var settings
    @Environment(\.hWithoutDividerPadding) var withoutPadding: Bool

    public init() {}

    public var body: some View {
        let noPaddingInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        SwiftUI.Divider().padding(withoutPadding ? noPaddingInsets : settings.insets)
    }
}

struct hRowDividerModifier: ViewModifier {
    let insets: EdgeInsets

    func body(content: Content) -> some View {
        content
            .environment(\.hRowDividerSettings, hRowDividerSettings(insets: insets))
    }
}

extension View {
    public func dividerInsets(_ insets: EdgeInsets) -> some View {
        self.modifier(hRowDividerModifier(insets: insets))
    }

    public func dividerInsets(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        self.modifier(
            hRowDividerModifier(
                insets: EdgeInsets(
                    top: edges.contains(.top) ? length : 0,
                    leading: edges.contains(.leading) ? length : 0,
                    bottom: edges.contains(.bottom) ? length : 0,
                    trailing: edges.contains(.trailing) ? length : 0
                )
            )
        )
    }
}
