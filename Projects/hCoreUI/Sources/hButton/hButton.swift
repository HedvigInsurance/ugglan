import Foundation
import SwiftUI

struct LargeButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minHeight: 56)
            .frame(minWidth: 300)
            .frame(maxWidth: .infinity)
    }
}

struct MediumButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        hSection {
            content
                .padding(.top, 7)
                .padding(.bottom, 9)
                .frame(maxWidth: .infinity)
        }
        .sectionContainerStyle(.transparent)
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        hSection {
            content
                .padding(.vertical, .padding8)
                .frame(minHeight: 32)
        }
        .sectionContainerStyle(.transparent)
    }
}

enum ButtonSize {
    case small
    case medium
    case large
}

extension View {
    @ViewBuilder
    func buttonSizeModifier(_ size: ButtonSize) -> some View {
        switch size {
        case .small:
            self.modifier(SmallButtonModifier()).environment(\.defaultHTextStyle, .subheadline)
        case .medium:
            self.modifier(MediumButtonModifier()).environment(\.defaultHTextStyle, .body1)
        case .large:
            self.modifier(LargeButtonModifier()).environment(\.defaultHTextStyle, .body1)
        }
    }
}

extension View {
    @ViewBuilder
    func buttonCornerModifier(_ size: ButtonSize) -> some View {
        switch size {
        case .small:
            self
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusS))
                .contentShape(RoundedRectangle(cornerRadius: .cornerRadiusS))
        case .medium:
            self
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
                .contentShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
        case .large:
            self
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .contentShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        }
    }
}

struct ButtonFilledStandardBackground: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    var configuration: SwiftUI.ButtonStyle.Configuration
    @Environment(\.hUseLightMode) var hUseLightMode

    var body: some View {
        if hUseLightMode {
            buttonBackgroundColor
                .colorScheme(.light)
        } else {
            buttonBackgroundColor
        }
    }

    @ViewBuilder
    var buttonBackgroundColor: some View {
        switch hButtonConfigurationType {
        case .primary:
            if configuration.isPressed {
                hButtonColor.Primary.hover.background {
                    hButtonColor.Primary.resting
                }
            } else if isEnabled {
                hButtonColor.Primary.resting
            } else {
                hButtonColor.Primary.disabled
            }
        case .primaryAlt:
            if configuration.isPressed {
                hButtonColor.PrimaryAlt.hover.background {
                    hButtonColor.PrimaryAlt.resting
                }
            } else if isEnabled {
                hButtonColor.PrimaryAlt.resting
            } else {
                hButtonColor.PrimaryAlt.disabled
            }
        case .secondary:
            if configuration.isPressed {
                hButtonColor.Secondary.hover.background {
                    hButtonColor.Secondary.resting
                }
            } else if isEnabled {
                hButtonColor.Secondary.resting
            } else {
                hButtonColor.Secondary.disabled
            }
        case .secondaryAlt:
            if configuration.isPressed {
                hButtonColor.SecondaryAlt.hover.background {
                    hButtonColor.SecondaryAlt.resting
                }
            } else if isEnabled {
                hButtonColor.SecondaryAlt.resting
            } else {
                hButtonColor.SecondaryAlt.disabled
            }
        case .ghost:
            if configuration.isPressed {
                hButtonColor.Ghost.hover.background {
                    hButtonColor.Ghost.resting
                }
            } else if isEnabled {
                hButtonColor.Ghost.resting
            } else {
                hButtonColor.Ghost.disabled
            }
        case .alert:
            if configuration.isPressed {
                hSignalColor.Red.element
            } else if isEnabled {
                hSignalColor.Red.element
            } else {
                hSignalColor.Red.element.opacity(0.2)
            }
        }
    }

}

struct ButtonFilledOverImageBackground: View {
    @Environment(\.isEnabled) var isEnabled
    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        if isEnabled {
            hButtonColor.Primary.resting
        } else {
            hButtonColor.Primary.disabled
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

public enum hButtonConfigurationType {
    case primary
    case primaryAlt
    case secondary
    case secondaryAlt
    case ghost
    case alert

    var useDarkVersion: Bool {
        switch self {
        case .primary:
            return false
        case .primaryAlt, .secondary, .secondaryAlt, .ghost, .alert:
            return true
        }
    }
}

private struct EnvironmentHButtonConfigurationType: EnvironmentKey {
    static let defaultValue = hButtonConfigurationType.primary
}

extension EnvironmentValues {
    var hButtonConfigurationType: hButtonConfigurationType {
        get { self[EnvironmentHButtonConfigurationType.self] }
        set { self[EnvironmentHButtonConfigurationType.self] = newValue }
    }
}

private struct EnvironmentHUseLightMode: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hUseLightMode: Bool {
        get { self[EnvironmentHUseLightMode.self] }
        set { self[EnvironmentHUseLightMode.self] = newValue }
    }
}

extension View {
    public var hUseLightMode: some View {
        self.environment(\.hUseLightMode, true)
    }
}

extension View {
    /// set filled button style
    public func hButtonFilledStyle(_ style: hButtonFilledStyle) -> some View {
        self.environment(\.hButtonFilledStyle, style)
    }
}

extension View {
    /// set filled button style
    public func hButtonConfigurationType(_ type: hButtonConfigurationType) -> some View {
        self.environment(\.hButtonConfigurationType, type)
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
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    @Environment(\.isEnabled) var enabled
    @Environment(\.hButtonDontShowLoadingWhenDisabled) var dontShowLoadingWhenDisabled

    var content: () -> Content
    var color: any hColor

    init(
        color: any hColor,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.color = color
        self.content = content
    }

    var body: some View {
        if isLoading && !dontShowLoadingWhenDisabled {
            Group {
                if hButtonConfigurationType.useDarkVersion {
                    if enabled {
                        DotsActivityIndicator(.standard)
                            .useDarkColor
                    } else {
                        DotsActivityIndicator(.standard)
                    }
                } else {
                    if enabled {
                        DotsActivityIndicator(.standard)
                    } else {
                        DotsActivityIndicator(.standard)
                            .useDarkColor
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)

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

private struct EnvironmentHButtonDontShowLoadingWhenDisabled: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hButtonDontShowLoadingWhenDisabled: Bool {
        get { self[EnvironmentHButtonDontShowLoadingWhenDisabled.self] }
        set { self[EnvironmentHButtonDontShowLoadingWhenDisabled.self] = newValue }
    }
}

extension View {
    public func hButtonDontShowLoadingWhenDisabled(_ show: Bool) -> some View {
        self.environment(\.hButtonDontShowLoadingWhenDisabled, show)
    }
}

struct ButtonFilledStyle: SwiftUI.ButtonStyle {
    var size: ButtonSize
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType

    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
        @Environment(\.hButtonFilledStyle) var hButtonFilledStyle
        @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
        @Environment(\.hUseLightMode) var hUseLightMode

        var configuration: Configuration

        @hColorBuilder var foregroundColor: some hColor {
            switch hButtonConfigurationType {
            case .primary:
                if isEnabled {
                    hTextColor.Opaque.primary.inverted
                } else {
                    hTextColor.Opaque.disabled
                }
            case .primaryAlt:
                if isEnabled {
                    hTextColor.Opaque.primary
                } else {
                    hTextColor.Opaque.disabled
                }
            case .secondary, .ghost:
                if isEnabled {
                    hTextColor.Opaque.primary
                } else {
                    hTextColor.Opaque.disabled
                }
            case .secondaryAlt:
                if isEnabled {
                    hTextColor.Opaque.primary
                } else {
                    hTextColor.Opaque.disabled
                }
            case .alert:
                if isEnabled {
                    hTextColor.Opaque.primary
                } else {
                    hTextColor.Opaque.secondary
                }
            }
        }

        var body: some View {
            LoaderOrContent(color: foregroundColor) {
                if hUseLightMode {
                    configuration.label
                        .foregroundColor(
                            foregroundColor
                        )
                        .colorScheme(.light)
                } else {
                    configuration.label
                        .foregroundColor(
                            foregroundColor
                        )
                }
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        switch hButtonConfigurationType {
        case .primary, .ghost, .alert:
            getView(configuration: configuration)
        case .primaryAlt, .secondary, .secondaryAlt:
            getView(configuration: configuration)
        }
    }

    @ViewBuilder
    private func getView(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .buttonSizeModifier(size)
        .background(ButtonFilledBackground(configuration: configuration))
        .buttonCornerModifier(size)
    }
}

extension View {

}

/* TODO: REMOVE */
struct ButtonOutlinedStyle: SwiftUI.ButtonStyle {
    var size: ButtonSize

    struct Label: View {
        var configuration: Configuration

        var body: some View {
            LoaderOrContent(color: hTextColor.Opaque.primary) {
                configuration.label
                    .foregroundColor(hTextColor.Opaque.primary)
                    .environment(\.defaultHTextStyle, .body1)
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
                    Squircle.default(lineWidth: configuration.isPressed ? 0 : 1)
                        .stroke(hTextColor.Opaque.primary, lineWidth: configuration.isPressed ? 0 : 1)
                )
            } else {
                content.overlay(
                    Squircle.default(lineWidth: 1)
                        .stroke(hTextColor.Opaque.primary, lineWidth: 1)
                )
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .buttonSizeModifier(size)
        .background(Color.clear)
        .clipShape(Squircle.default())
        .modifier(OverlayModifier(configuration: configuration))
        .modifier(OpacityModifier())
        .contentShape(Rectangle())
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

    public struct LargeButton<Content: View>: View {
        var type: hButtonConfigurationType
        var content: () -> Content
        var action: () -> Void

        public init(
            type: hButtonConfigurationType,
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.type = type
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
            .hButtonConfigurationType(type)
        }
    }

    public struct MediumButton<Content: View>: View {
        var type: hButtonConfigurationType
        var content: () -> Content
        var action: () -> Void

        public init(
            type: hButtonConfigurationType,
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.type = type
            self.action = action
            self.content = content
        }

        public var body: some View {
            _hButton(action: action) {
                content()
            }
            .buttonStyle(ButtonFilledStyle(size: .medium))
            .hButtonConfigurationType(type)
        }
    }

    public struct SmallButton<Content: View>: View {
        var type: hButtonConfigurationType
        var content: () -> Content
        var action: () -> Void
        @Environment(\.hUseLightMode) var useLightMode

        public init(
            type: hButtonConfigurationType,
            action: @escaping () -> Void,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.type = type
            self.action = action
            self.content = content
        }

        public var body: some View {
            _hButton(action: action) {
                content()
            }
            .buttonStyle(ButtonFilledStyle(size: .small))
            .hButtonConfigurationType(type)
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
}
