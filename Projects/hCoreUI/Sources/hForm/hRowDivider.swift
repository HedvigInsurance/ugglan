import Foundation
import SwiftUI

struct hRowDividerSettings {
    let insets: EdgeInsets
}

private struct EnvironmentHRowDividerSettings: EnvironmentKey {
    static let defaultValue = hRowDividerSettings(insets: .init(top: 0, leading: 15, bottom: 0, trailing: 0))
}

extension EnvironmentValues {
    var hRowDividerSettings: hRowDividerSettings {
        get { self[EnvironmentHRowDividerSettings.self] }
        set { self[EnvironmentHRowDividerSettings.self] = newValue }
    }
}

struct hRowDivider: View {
    @SwiftUI.Environment(\.hRowDividerSettings) var settings: hRowDividerSettings

    var body: some View {
        SwiftUI.Divider().padding(settings.insets)
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
