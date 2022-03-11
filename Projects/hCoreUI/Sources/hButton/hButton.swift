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
            .padding(.leading)
            .padding(.trailing)
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

struct ButtonFilledOverImageBackground: View {
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
    case overImage
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

struct ButtonFilledBackground: View {
    @Environment(\.hButtonFilledStyle) var hButtonFilledStyle
    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        switch hButtonFilledStyle {
        case .standard:
            ButtonFilledStandardBackground(configuration: configuration)
        case .overImage:
            ButtonFilledOverImageBackground(configuration: configuration)
        }
    }
}

struct LoaderOrContent<Content: View>: View {
    @Environment(\.hButtonIsLoading) var isLoading

    var content: () -> Content

    init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        if isLoading {
            ActivityIndicator(
                style: .medium
            )
        } else {
            content()
        }
    }
}

private struct EnvironmentHButtonIsLoading: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hButtonIsLoading: Bool {
        get { self[EnvironmentHButtonIsLoading.self] }
        set { self[EnvironmentHButtonIsLoading.self] = newValue }
    }
}

extension View {
    public func hButtonIsLoading(_ isLoading: Bool) -> some View {
        self.environment(\.hButtonIsLoading, isLoading)
    }
}

struct ButtonFilledStyle: SwiftUI.ButtonStyle {
    var size: ButtonSize

    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.hButtonFilledStyle) var hButtonFilledStyle
        var configuration: Configuration

        var body: some View {
            switch hButtonFilledStyle {
            case .standard:
                LoaderOrContent {
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
                }
            case .overImage:
                LoaderOrContent {
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
                .padding(.leading, 16)
                .padding(.trailing, 16)
        }
        .buttonSizeModifier(size)
        .background(ButtonFilledBackground(configuration: configuration))
        .overlay(configuration.isPressed ? pressedColor : nil)
        .cornerRadius(.defaultCornerRadius)
    }
}

struct ButtonOutlinedStyle: SwiftUI.ButtonStyle {
    var size: ButtonSize

    struct Label: View {
        var configuration: Configuration

        var body: some View {
            LoaderOrContent {
                configuration.label
                    .foregroundColor(hLabelColor.primary)
                    .environment(\.defaultHTextStyle, .body)
            }
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
        .buttonSizeModifier(size)
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
            LoaderOrContent {
                configuration.label
                    .foregroundColor(hLabelColor.primary)
                    .environment(\.defaultHTextStyle, .body)
            }
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

struct _hButton<Content: View>: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hButtonIsLoading) var isLoading
    var content: () -> Content
    var action: () -> Void

    public init(
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }

    var body: some View {
        SwiftUI.Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            content()
        }
        .allowsHitTesting(!isLoading)
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
            _hButton(action: {
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
            _hButton(action: action) {
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
            _hButton(action: action) {
                content()
            }
            .buttonStyle(ButtonOutlinedStyle(size: .large))
        }
    }

    public struct SmallButtonOutlined<Content: View>: View {
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
            _hButton(action: action) {
                content()
            }
            .buttonStyle(ButtonOutlinedStyle(size: .small))
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
            _hButton(action: action) {
                content()
            }
            .buttonStyle(LargeButtonTextStyle())
        }
    }
}
