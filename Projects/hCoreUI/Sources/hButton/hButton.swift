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
        content
            .frame(maxHeight: 40)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(minHeight: 32)
    }
}

enum ButtonSize {
    case small
    case medium
    case large
}

extension View {
    @ViewBuilder func buttonSizeModifier(_ size: ButtonSize) -> some View {
        switch size {
        case .small:
            self.modifier(SmallButtonModifier()).environment(\.defaultHTextStyle, .subheadline)
        case .medium:
            self.modifier(MediumButtonModifier()).environment(\.defaultHTextStyle, .standard)
        case .large:
            self.modifier(LargeButtonModifier()).environment(\.defaultHTextStyle, .standard)
        }
    }
}

struct ButtonFilledStandardBackground: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        switch hButtonConfigurationType {
        case .primary:
            if configuration.isPressed {
                hButtonColor.primaryHover
            } else if isEnabled {
                hButtonColor.primaryDefault
            } else {
                hButtonColor.primaryDisabled
            }
        case .primaryAlt:
            if configuration.isPressed {
                hButtonColor.primaryAltHover
            } else if isEnabled {
                hButtonColor.primaryAltDefault
            } else {
                hButtonColor.primaryAltDisabled
            }
        case .secondary:
            if configuration.isPressed {
                hButtonColor.secondaryHover
            } else if isEnabled {
                hFillColor.translucentOne
            } else {
                hButtonColor.secondaryDisabled
            }
        case .secondaryAlt:
            if configuration.isPressed {
                hButtonColor.secondaryAltHover
            } else if isEnabled {
                hButtonColor.secondaryAltDefault
            } else {
                hButtonColor.secondaryAltDisabled
            }
        case .ghost:
            if configuration.isPressed {
                hFillColor.translucentOne
            } else if isEnabled {
                Color.clear
            }
        case .alert:
            hSignalColor.redElement
        }
    }
}

struct ButtonFilledOverImageBackground: View {
    @Environment(\.isEnabled) var isEnabled
    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        if isEnabled {
            hButtonColor.primaryDefault
        } else {
            hButtonColor.primaryDisabled
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
        if isLoading && enabled {
            if hButtonConfigurationType.useDarkVersion {
                DotsActivityIndicator(.standard)
                    .useDarkColor
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                DotsActivityIndicator(.standard)
                    .fixedSize(horizontal: false, vertical: true)
            }

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
                    switch hButtonFilledStyle {
                    case .standard:
                        hTextColor.negative
                    case .overImage:
                        hTextColor.negative
                    }
                } else {
                    hTextColor.disabled
                }
            case .primaryAlt:
                if isEnabled {
                    switch hButtonFilledStyle {
                    case .standard:
                        hTextColor.primary
                    case .overImage:
                        hTextColor.primary
                    }
                } else {
                    hTextColor.disabled
                }
            case .secondary, .ghost, .secondaryAlt:
                if isEnabled {
                    hTextColor.primary
                } else {
                    hTextColor.disabled
                }
            case .alert:
                hTextColor.negative
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
                .background(
                    ZStack {
                        //create shadow - this create shadows for whole shape
                        Squircle.default()
                            .fill(hTextColor.primary.inverted.opacity(0.01))
                            .hShadow()

                        //cut out shape from previously created shape - we only need shadows
                        Squircle.default()
                            .blendMode(.destinationOut)

                    }
                    .compositingGroup()
                )
        }
    }

    private func getView(configuration: Configuration) -> some View {
        VStack {
            Label(configuration: configuration)
        }
        .buttonSizeModifier(size)
        .background(ButtonFilledBackground(configuration: configuration))
        .clipShape(Squircle.default())
        .contentShape(Rectangle())
    }
}

/* TODO: REMOVE */
struct ButtonOutlinedStyle: SwiftUI.ButtonStyle {
    var size: ButtonSize

    struct Label: View {
        var configuration: Configuration

        var body: some View {
            LoaderOrContent(color: hTextColor.primary) {
                configuration.label
                    .foregroundColor(hTextColor.primary)
                    .environment(\.defaultHTextStyle, .standard)
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
                        .stroke(hTextColor.primary, lineWidth: configuration.isPressed ? 0 : 1)
                )
            } else {
                content.overlay(
                    Squircle.default(lineWidth: 1)
                        .stroke(hTextColor.primary, lineWidth: 1)
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
        //        .overlay(configuration.isPressed ? hOverlayColor.pressed : nil)
        .clipShape(Squircle.default())
        .modifier(OverlayModifier(configuration: configuration))
        .modifier(OpacityModifier())
        .contentShape(Rectangle())
    }
}

struct LargeButtonTextStyle: SwiftUI.ButtonStyle {
    struct Label: View {
        var configuration: Configuration

        var body: some View {
            LoaderOrContent(color: hTextColor.primary) {
                configuration.label
                    .foregroundColor(hTextColor.primary)
                    .environment(\.defaultHTextStyle, .standard)
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
        .overlay(configuration.isPressed ? getPressedColor : nil)
        .clipShape(Squircle.default())
        .modifier(OpacityModifier())
        .contentShape(Rectangle())
    }

    @hColorBuilder
    var getPressedColor: some hColor {
        hButtonColor.secondaryHover
    }
}

struct SmallButtonTextStyle: SwiftUI.ButtonStyle {

    struct Label: View {
        var configuration: Configuration

        var body: some View {
            LoaderOrContent(color: hTextColor.primary) {
                configuration.label
                    .foregroundColor(hTextColor.primary)
                    .environment(\.defaultHTextStyle, .standard)
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
        .modifier(SmallButtonModifier())
        .background(hGrayscaleColor.greyScale25)
        .overlay(configuration.isPressed ? getPressedColor : nil)
        .clipShape(Squircle.default())
        .modifier(OpacityModifier())
        .contentShape(Rectangle())
    }

    @hColorBuilder
    var getPressedColor: some hColor {
        hButtonColor.secondaryHover
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
