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

public struct hRowDivider: View {
    @Environment(\.hRowDividerSettings) var settings
    @Environment(\.hWithoutHorizontalPadding) var hWithoutHorizontalPadding
    public init() {}

    public var body: some View {
        RoundedRectangle(cornerRadius: 1, style: .circular)
            .fill(hBorderColor.secondary)
            .frame(height: 1)
            .padding(hWithoutHorizontalPadding.contains(.divider) ? .init() : settings.insets)
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

#Preview {
    VStack {
        Text("TEXT")
        hRowDivider()
        Spacer()
    }
}
