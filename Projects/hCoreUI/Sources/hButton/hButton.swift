import Foundation
import SwiftUI

public enum hButtonSize: CaseIterable {
    case large
    case medium
    case small
}

public struct hButton: View {
    var size: hButtonSize
    var type: hButtonConfigurationType
    var title: String?
    var content: (() -> AnyView)?
    var action: () -> Void

    public init(
        _ size: hButtonSize,
        _ type: hButtonConfigurationType,
        title: String? = nil,
        _ action: @escaping () -> Void,
        content: (() -> AnyView)? = nil
    ) {
        self.type = type
        self.size = size
        self.title = title
        self.action = action
        self.content = content
    }

    public var body: some View {
        _hButton(action: {
            action()
        }) {
            if let title {
                hText(title, style: size == .small ? .label : .body1)
            } else {
                content?()
            }
        }
        .buttonStyle(ButtonFilledStyle(size: size))
        .hButtonConfigurationType(type)
    }
}

//@MainActor
//public enum hButton {
//    public struct LargeButton<Content: View>: View {
//        var type: hButtonConfigurationType
//        var content: () -> Content
//        var action: () -> Void
//
//        public init(
//            type: hButtonConfigurationType,
//            action: @escaping () -> Void,
//            @ViewBuilder content: @escaping () -> Content
//        ) {
//            self.type = type
//            self.action = action
//            self.content = content
//        }
//
//        public var body: some View {
//            _hButton(action: {
//                action()
//            }) {
//                content()
//            }
//            .buttonStyle(ButtonFilledStyle(size: .large))
//            .hButtonConfigurationType(type)
//        }
//    }
//
//    public struct MediumButton<Content: View>: View {
//        var type: hButtonConfigurationType
//        var content: () -> Content
//        var action: () -> Void
//
//        public init(
//            type: hButtonConfigurationType,
//            action: @escaping () -> Void,
//            @ViewBuilder content: @escaping () -> Content
//        ) {
//            self.type = type
//            self.action = action
//            self.content = content
//        }
//
//        public var body: some View {
//            _hButton(action: action) {
//                content()
//            }
//            .buttonStyle(ButtonFilledStyle(size: .medium))
//            .hButtonConfigurationType(type)
//        }
//    }
//
//    public struct SmallButton<Content: View>: View {
//        var type: hButtonConfigurationType
//        var content: () -> Content
//        var action: () -> Void
//        @Environment(\.hUseLightMode) var useLightMode
//
//        public init(
//            type: hButtonConfigurationType,
//            action: @escaping () -> Void,
//            @ViewBuilder content: @escaping () -> Content
//        ) {
//            self.type = type
//            self.action = action
//            self.content = content
//        }
//
//        public var body: some View {
//            _hButton(action: action) {
//                content()
//            }
//            .buttonStyle(ButtonFilledStyle(size: .small))
//            .hButtonConfigurationType(type)
//        }
//    }
//}

//extension hButton: View {
//    public var body: some View {
//        EmptyView()
//    }
//}

//@MainActor
//public enum hButton {
//    case large
//    case medium
//    case small
//
//    public func view(
//        type: hButtonConfigurationType,
//        buttonText: String? = nil,
//        action: @escaping () -> Void,
//        content: (() -> AnyView)? = nil
//    ) -> some View {
//        _hButton(action: {
//            action()
//        }) {
//            if let buttonText {
//                hText(buttonText)
//            } else if let content {
//                content()
//            }
//        }
//        .buttonStyle(ButtonFilledStyle(size: self))
//        .hButtonConfigurationType(type)
//    }
//}

struct ButtonFilledStandardBackground: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    var configuration: SwiftUI.ButtonStyle.Configuration
    @Environment(\.hUseLightMode) var hUseLightMode
    @Environment(\.hButtonIsLoading) var isLoading

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
            } else if isEnabled || isLoading {
                hButtonColor.Primary.resting
            } else {
                hButtonColor.Primary.disabled
            }
        case .primaryAlt:
            if configuration.isPressed {
                hButtonColor.PrimaryAlt.hover.background {
                    hButtonColor.PrimaryAlt.resting
                }
            } else if isEnabled || isLoading {
                hButtonColor.PrimaryAlt.resting
            } else {
                hButtonColor.PrimaryAlt.disabled
            }
        case .secondary:
            if configuration.isPressed {
                hButtonColor.Secondary.hover.background {
                    hButtonColor.Secondary.resting
                }
            } else if isEnabled || isLoading {
                hButtonColor.Secondary.resting
            } else {
                hButtonColor.Secondary.disabled
            }
        case .secondaryAlt:
            if configuration.isPressed {
                hButtonColor.SecondaryAlt.hover.background {
                    hButtonColor.SecondaryAlt.resting
                }
            } else if isEnabled || isLoading {
                hButtonColor.SecondaryAlt.resting
            } else {
                hButtonColor.SecondaryAlt.disabled
            }
        case .ghost:
            if configuration.isPressed {
                hButtonColor.Ghost.hover.background {
                    hButtonColor.Ghost.resting
                }
            } else if isEnabled || isLoading {
                hButtonColor.Ghost.resting
            } else {
                hButtonColor.Ghost.disabled
            }
        case .alert:
            if configuration.isPressed {
                hSignalColor.Red.element
            } else if isEnabled || isLoading {
                hSignalColor.Red.element
            } else {
                hSignalColor.Red.element.opacity(0.2)
            }
        }
    }
}

struct LoaderOrContent<Content: View>: View {
    @Environment(\.hButtonIsLoading) var isLoading
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType
    @Environment(\.isEnabled) var enabled
    @Environment(\.hButtonDontShowLoadingWhenDisabled) var dontShowLoadingWhenDisabled
    @Environment(\.colorScheme) var colorScheme
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
                if hButtonConfigurationType.shouldUseDark(for: colorScheme) {
                    DotsActivityIndicator(.standard)
                        .useDarkColor
                        .colorScheme(.light)
                } else {
                    DotsActivityIndicator(.standard)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            content()
        }
    }
}

struct ButtonFilledStyle: SwiftUI.ButtonStyle {
    fileprivate var size: hButtonSize
    @Environment(\.hButtonConfigurationType) var hButtonConfigurationType

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
        .background(ButtonFilledStandardBackground(configuration: configuration))
        .buttonCornerModifier(size)
    }

    //content
    struct Label: View {
        @Environment(\.isEnabled) var isEnabled
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
                    hTextColor.Opaque.primary.colorFor(.light, .base)
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

//MARK: Button size modifiers
private struct LargeButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, 15)
            .padding(.bottom, 17)
            .frame(minHeight: .padding56)
            .frame(maxWidth: .infinity)
    }
}

private struct MediumButtonModifier: ViewModifier {
    @Environment(\.hButtonTakeFullWidth) var hButtonTakeFullWidth

    func body(content: Content) -> some View {
        content
            .padding(.top, 7)
            .padding(.bottom, 9)
            .padding(.horizontal, .padding16)
            .frame(maxWidth: hButtonTakeFullWidth ? .infinity : nil)
    }
}

private struct SmallButtonModifier: ViewModifier {
    @Environment(\.hButtonTakeFullWidth) var hButtonTakeFullWidth
    func body(content: Content) -> some View {
        content
            .padding(.top, 6.5)
            .padding(.bottom, 7.5)
            .frame(minHeight: 32)
            .padding(.horizontal, .padding16)
            .frame(maxWidth: hButtonTakeFullWidth ? .infinity : nil)
    }
}

private struct MiniButtonModifier: ViewModifier {
    @Environment(\.hButtonTakeFullWidth) var hButtonTakeFullWidth
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 3)
            .padding(.horizontal, .padding8)
            .frame(minHeight: 24)
            .padding(.horizontal, .padding16)
            .frame(maxWidth: hButtonTakeFullWidth ? .infinity : nil)

    }
}

////MARK: Button Size
//private enum ButtonSize {
//    case mini
//    case small
//    case medium
//    case large
//}

extension View {
    @ViewBuilder
    fileprivate func buttonSizeModifier(_ size: hButtonSize) -> some View {
        switch size {
        case .small:
            self.modifier(SmallButtonModifier()).environment(\.defaultHTextStyle, .label)
        case .medium:
            self.modifier(MediumButtonModifier()).environment(\.defaultHTextStyle, .body1)
        case .large:
            self.modifier(LargeButtonModifier()).environment(\.defaultHTextStyle, .body1)
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func buttonCornerModifier(_ size: hButtonSize) -> some View {
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

//MARK: hButtonStyle
public enum hButtonConfigurationType: Sendable, CaseIterable {
    case primary
    case primaryAlt
    case secondary
    case secondaryAlt
    case ghost
    case alert

    func shouldUseDark(for schema: ColorScheme) -> Bool {
        switch schema {
        case .dark:
            switch self {
            case .primary, .primaryAlt:
                return false
            case .secondary, .secondaryAlt, .ghost, .alert:
                return true
            }
        case .light:
            switch self {
            case .primary:
                return false
            default:
                return true
            }
        @unknown default:
            return false
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
    public func hButtonConfigurationType(_ type: hButtonConfigurationType) -> some View {
        self.environment(\.hButtonConfigurationType, type)
    }
}

//MARK: hButtonIsLoading
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

//MARK: EnvironmentHButtonDontShowLoadingWhenDisabled
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

private struct EnvironmentHButtonTakeFullWidth: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hButtonTakeFullWidth: Bool {
        get { self[EnvironmentHButtonTakeFullWidth.self] }
        set { self[EnvironmentHButtonTakeFullWidth.self] = newValue }
    }
}

extension View {
    public func hButtonTakeFullWidth(_ takeFullWidth: Bool) -> some View {
        self.environment(\.hButtonTakeFullWidth, takeFullWidth)
    }
}

#Preview {
    @State var isLoading = false
    @State var disabled = false

    let buttons = VStack(alignment: .leading) {
        ForEach(hButtonSize.allCases, id: \.self) { size in
            ForEach(hButtonConfigurationType.allCases, id: \.self) { type in
                hButton(
                    size,
                    type,
                    title: "TEXT",
                    {}
                )
            }
        }
    }

    VStack(alignment: .leading) {
        buttons
            .colorScheme(.dark)

        buttons
            .colorScheme(.light)
    }
    .background(hBackgroundColor.primary)
    .hButtonIsLoading(isLoading)
    .disabled(disabled)
}
