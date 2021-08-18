import Foundation
import SwiftUI

struct LargeButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 52)
            .frame(minWidth: 200)
            .frame(maxWidth: .infinity)
    }
}

struct LargeButtonFilledStyle: SwiftUI.ButtonStyle {
    struct Background: View {
        @Environment(\.isEnabled) var isEnabled
        var configuration: Configuration

        var body: some View {
            if isEnabled {
                hColorScheme(
                    light: hLabelColor.primary,
                    dark: hTintColor.lavenderOne
                )
            } else {
                hColorScheme(
                    light: hGrayscaleColor.three,
                    dark: hGrayscaleColor.four
                )
            }
        }
    }

    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        var configuration: Configuration

        var body: some View {
            if !isEnabled {
                configuration.label
                    .environment(\.defaultHTextStyle, .body)
                    .foregroundColor(
                        hColorScheme(
                            light: hLabelColor.primary.inverted,
                            dark: hLabelColor.quarternary
                        )
                    )
            } else {
                configuration.label
                    .environment(\.defaultHTextStyle, .body)
                    .foregroundColor(hLabelColor.primary.inverted)
            }
        }
    }

    var pressedColor: some hColor {
        hColorScheme(
            light: hOverlayColor.pressed,
            dark: hOverlayColor.pressedLavender
        )
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .modifier(LargeButtonModifier())
        .background(Background(configuration: configuration))
        .overlay(configuration.isPressed ? pressedColor : nil)
        .cornerRadius(.defaultCornerRadius)
    }
}

struct LargeButtonOutlinedStyle: SwiftUI.ButtonStyle {
    struct Label: View {
        var configuration: Configuration

        var body: some View {
            configuration.label
                .foregroundColor(hLabelColor.primary)
                .environment(\.defaultHTextStyle, .body)
        }
    }

    struct OpacityModifier: ViewModifier {
        @Environment(\.isEnabled) var isEnabled

        func body(content: Content) -> some View {
            content.opacity(isEnabled ? 1 : 0.2)
        }
    }

    struct OverlayModifier: ViewModifier {
        @Environment(\.colorScheme) var colorScheme
        var configuration: Configuration

        func body(content: Content) -> some View {
            if colorScheme == .light {
                content.overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .stroke(hLabelColor.primary, lineWidth: configuration.isPressed ? 0 : 1)
                )
            } else {
                content.overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .stroke(hLabelColor.primary, lineWidth: 1)
                )
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration).contentShape(Rectangle())
        }
        .modifier(LargeButtonModifier())
        .background(Color.clear)
        .overlay(configuration.isPressed ? hOverlayColor.pressed : nil)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .modifier(OverlayModifier(configuration: configuration))
        .modifier(OpacityModifier())
    }
}

struct LargeButtonTextStyle: SwiftUI.ButtonStyle {
    struct Label: View {
        var configuration: Configuration

        var body: some View {
            configuration.label
                .foregroundColor(hLabelColor.primary)
                .environment(\.defaultHTextStyle, .body)
        }
    }

    struct OpacityModifier: ViewModifier {
        @Environment(\.isEnabled) var isEnabled

        func body(content: Content) -> some View {
            content.opacity(isEnabled ? 1 : 0.2)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration).contentShape(Rectangle())
        }
        .modifier(LargeButtonModifier())
        .background(Color.clear)
        .overlay(configuration.isPressed ? hOverlayColor.pressed : nil)
        .cornerRadius(.defaultCornerRadius)
        .modifier(OpacityModifier())
    }
}

public enum hButton {
    public struct LargeButtonFilled<Content: View>: View {
        var content: () -> Content
        var action: () -> Void

        public init(
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.action = action
            self.content = content
        }

        public var body: some View {
            SwiftUI.Button(action: action) {
                content()
            }
            .buttonStyle(LargeButtonFilledStyle())
        }
    }

    public struct LargeButtonOutlined<Content: View>: View {
        var content: () -> Content
        var action: () -> Void

        public init(
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.action = action
            self.content = content
        }

        public var body: some View {
            SwiftUI.Button(action: action) {
                content()
            }
            .buttonStyle(LargeButtonOutlinedStyle())
        }
    }

    public struct LargeButtonText<Content: View>: View {
        var content: () -> Content
        var action: () -> Void

        public init(
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.action = action
            self.content = content
        }

        public var body: some View {
            SwiftUI.Button(action: action) {
                content()
            }
            .buttonStyle(LargeButtonTextStyle())
        }
    }
}
