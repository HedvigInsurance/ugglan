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

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 35)
    }
}

enum ButtonSize {
    case small
    case large
}

extension View {
    @ViewBuilder func buttonSizeModifier(_ size: ButtonSize) -> some View {
        switch size {
        case .small:
            self.modifier(SmallButtonModifier()).environment(\.defaultHTextStyle, .subheadline)
        case .large:
            self.modifier(LargeButtonModifier()).environment(\.defaultHTextStyle, .body)
        }
    }
}

struct ButtonFilledStandardBackground: View {
    @Environment(\.isEnabled) var isEnabled
    var configuration: SwiftUI.ButtonStyle.Configuration

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

struct ButtonFilledContrastedBackground: View {
    @Environment(\.isEnabled) var isEnabled
    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        if isEnabled {
            hLabelColor.primary.colorScheme(.dark)
        } else {
            hColorScheme(
                light: hGrayscaleColor.three,
                dark: hGrayscaleColor.four
            )
        }
    }
}

public enum hButtonFilledStyle {
    case standard
    case contrasted
}

private struct EnvironmentHButtonFilledStyleStyle: EnvironmentKey {
    static let defaultValue = hButtonFilledStyle.standard
}

extension EnvironmentValues {
    var hButtonFilledStyle: hButtonFilledStyle {
        get { self[EnvironmentHButtonFilledStyleStyle.self] }
        set { self[EnvironmentHButtonFilledStyleStyle.self] = newValue }
    }
}

extension View {
    /// set filled button style
    public func hButtonFilledStyle(_ style: hButtonFilledStyle) -> some View {
        self.environment(\.hButtonFilledStyle, style)
    }
}

struct ButtonFilledStyle: SwiftUI.ButtonStyle {
    var size: ButtonSize
    @Environment(\.hButtonFilledStyle) var hButtonFilledStyle

    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.hButtonFilledStyle) var hButtonFilledStyle
        var configuration: Configuration

        var body: some View {

            switch hButtonFilledStyle {
            case .standard:
                if !isEnabled {
                    configuration.label
                        .foregroundColor(
                            hColorScheme(
                                light: hLabelColor.primary.inverted,
                                dark: hLabelColor.quarternary
                            )
                        )
                } else {
                    configuration.label
                        .foregroundColor(hLabelColor.primary.inverted)
                }
            case .contrasted:
                if !isEnabled {
                    configuration.label
                        .foregroundColor(
                            hLabelColor.primary.colorFor(.light, .base)
                        )
                } else {
                    configuration.label
                        .foregroundColor(hLabelColor.primary.colorFor(.light, .base))
                }
            }

        }
    }

    var pressedColor: some hColor {
        hColorScheme(
            light: hOverlayColor.pressed,
            dark: hOverlayColor.pressedLavender
        )
    }

    @ViewBuilder func background(configuration: Configuration) -> some View {
        switch hButtonFilledStyle {
        case .standard:
            ButtonFilledStandardBackground(configuration: configuration)
        case .contrasted:
            ButtonFilledContrastedBackground(configuration: configuration)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
                .padding(.leading, 16)
                .padding(.trailing, 16)
        }
        .buttonSizeModifier(size)
        .background(background(configuration: configuration))
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
            SwiftUI.Button(action: {
                action()
            }) {
                content()
            }
            .buttonStyle(ButtonFilledStyle(size: .large))
        }
    }

    public struct SmallButtonFilled<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .small))
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
