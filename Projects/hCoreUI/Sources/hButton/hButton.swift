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
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(minHeight: 40)
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
                hButtonColorNew.primaryHover
            } else if isEnabled {
                hButtonColorNew.primaryDefault
            } else {
                hButtonColorNew.primaryDisabled
            }
        case .primaryAlt:
            if configuration.isPressed {
                hButtonColorNew.primaryAltHover
            } else if isEnabled {
                hButtonColorNew.primaryAltDefault
            } else {
                hButtonColorNew.primaryAltDisabled
            }
        case .secondary:
            if configuration.isPressed {
                hButtonColorNew.secondaryHover
                    .hShadow()
            } else if isEnabled {
                hFillColorNew.translucentOne
                    .hShadow()
            } else {
                hButtonColorNew.secondaryDisabled
                    .hShadow()
            }
        case .secondaryAlt:
            if configuration.isPressed {
                hButtonColorNew.secondaryAltHover
                    .hShadow()
            } else if isEnabled {
                hButtonColorNew.secondaryAltDefault
                    .hShadow()
            } else {
                hButtonColorNew.secondaryAltDisabled
                    .hShadow()
            }
        case .ghost:
            if configuration.isPressed {
                hFillColorNew.translucentOne
            } else if isEnabled {
                Color.clear
            }
        case .alert:
            hSignalColorNew.redElement
        }
    }
}

struct ButtonFilledOverImageBackground: View {
    @Environment(\.isEnabled) var isEnabled
    var configuration: SwiftUI.ButtonStyle.Configuration

    var body: some View {
        if isEnabled {
            hButtonColorNew.primaryDefault
        } else {
            hButtonColorNew.primaryDisabled
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
        if isLoading {
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

        var configuration: Configuration

        @hColorBuilder var foregroundColor: some hColor {
            switch hButtonConfigurationType {
            case .primary:
                if isEnabled {
                    switch hButtonFilledStyle {
                    case .standard:
                        hTextColorNew.negative
                    case .overImage:
                        hTextColorNew.negative
                    }
                } else {
                    hTextColorNew.disabled
                }
            case .primaryAlt:
                if isEnabled {
                    switch hButtonFilledStyle {
                    case .standard:
                        hTextColorNew.primary
                    case .overImage:
                        hTextColorNew.primary
                    }
                } else {
                    hTextColorNew.disabled
                }
            case .secondary, .ghost, .secondaryAlt:
                if isEnabled {
                    hTextColorNew.primary
                } else {
                    hTextColorNew.disabled
                }
            case .alert:
                hTextColorNew.negative
            }
        }

        var body: some View {
            LoaderOrContent(color: foregroundColor) {
                configuration.label
                    .foregroundColor(
                        foregroundColor
                    )
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        switch hButtonConfigurationType {
        case .primary, .ghost, .alert:
            getView(configuration: configuration)
        case .primaryAlt, .secondary, .secondaryAlt:
            getView(configuration: configuration).hShadow()
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
            LoaderOrContent(color: hLabelColor.primary) {
                configuration.label
                    .foregroundColor(hLabelColor.primary)
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
                        .stroke(hLabelColor.primary, lineWidth: configuration.isPressed ? 0 : 1)
                )
            } else {
                content.overlay(
                    Squircle.default(lineWidth: 1)
                        .stroke(hLabelColor.primary, lineWidth: 1)
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
        .overlay(configuration.isPressed ? hOverlayColor.pressed : nil)
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
            LoaderOrContent(color: hTextColorNew.primary) {
                configuration.label
                    .foregroundColor(hTextColorNew.primary)
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
        hButtonColorNew.secondaryHover
    }
}

struct SmallButtonTextStyle: SwiftUI.ButtonStyle {

    struct Label: View {
        var configuration: Configuration

        var body: some View {
            LoaderOrContent(color: hTextColorNew.primary) {
                configuration.label
                    .foregroundColor(hTextColorNew.primary)
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
        .background(Color.clear)
        .overlay(configuration.isPressed ? getPressedColor : nil)
        .clipShape(Squircle.default())
        .modifier(OpacityModifier())
        .contentShape(Rectangle())
    }

    @hColorBuilder
    var getPressedColor: some hColor {
        hButtonColorNew.secondaryHover
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
    public struct LargeButtonPrimary<Content: View>: View {
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
            .hButtonConfigurationType(.primary)
        }
    }

    public struct LargeButtonPrimaryAlt<Content: View>: View {
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
            .hButtonConfigurationType(.primaryAlt)
        }
    }

    public struct LargeButtonPrimaryAlert<Content: View>: View {
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
            .hButtonConfigurationType(.alert)
        }
    }

    public struct LargeButtonAlt<Content: View>: View {
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
            .hButtonConfigurationType(.primaryAlt)
        }
    }

    public struct LargeButtonSecondary<Content: View>: View {
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
            .hButtonConfigurationType(.secondary)
        }
    }

    public struct LargeButtonSecondaryAlt<Content: View>: View {
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
            .hButtonConfigurationType(.secondaryAlt)
        }
    }

    public struct LargeButtonGhost<Content: View>: View {
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
            .hButtonConfigurationType(.ghost)
        }
    }

    public struct MediumButtonPrimary<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .medium))
            .hButtonConfigurationType(.primary)
        }
    }

    public struct MediumButtonPrimaryAlt<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .medium))
            .hButtonConfigurationType(.primaryAlt)
        }
    }

    public struct MediumButtonSecondary<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .medium))
            .hButtonConfigurationType(.secondary)
        }
    }

    public struct MediumButtonSecondaryAlt<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .medium))
            .hButtonConfigurationType(.secondaryAlt)
        }
    }

    public struct MediumButtonGhost<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .medium))
            .hButtonConfigurationType(.ghost)
        }
    }

    public struct SmallSButtonecondaryAlt<Content: View>: View {
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
            .hButtonConfigurationType(.secondaryAlt)
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

    public struct SmallButtonText<Content: View>: View {
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
            .buttonStyle(SmallButtonTextStyle())
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
