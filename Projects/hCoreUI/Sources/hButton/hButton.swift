import Foundation
import SwiftUI

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

    public struct MiniButton<Content: View>: View {
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
            .buttonStyle(ButtonFilledStyle(size: .mini))
            .hButtonConfigurationType(type)
        }
    }
}

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
    fileprivate var size: ButtonSize
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
            //            .frame(minWidth: 300)
            .frame(maxWidth: .infinity)
    }
}

private struct MediumButtonModifier: ViewModifier {
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

private struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        hSection {
            content
                .padding(.vertical, .padding8)
                .frame(minHeight: 32)
        }
        .sectionContainerStyle(.transparent)
    }
}

private struct MiniButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        hSection {
            content
                .padding(.vertical, 3)
                .padding(.horizontal, .padding8)
                .frame(minHeight: 24)
        }
        .sectionContainerStyle(.transparent)
    }
}

//MARK: Button Size
private enum ButtonSize {
    case mini
    case small
    case medium
    case large
}

extension View {
    @ViewBuilder
    fileprivate func buttonSizeModifier(_ size: ButtonSize) -> some View {
        switch size {
        case .mini:
            self.modifier(MiniButtonModifier()).environment(\.defaultHTextStyle, .label)
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
    fileprivate func buttonCornerModifier(_ size: ButtonSize) -> some View {
        switch size {
        case .mini:
            self
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
                .contentShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
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
public enum hButtonConfigurationType {
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

struct hButtonLarge_Previews: PreviewProvider {
    @State static var isLoading = false
    @State static var disabled = false
    static var previews: some View {
        let buttons = VStack {
            Spacer()
            hButton.LargeButton(type: .primary) {

            } content: {
                hText("TEXT")
            }
            hButton.LargeButton(type: .primaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.LargeButton(type: .secondary) {

            } content: {
                hText("TEXT")
            }
            hButton.LargeButton(type: .secondaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.LargeButton(type: .ghost) {

            } content: {
                hText("TEXT")
            }
            hButton.LargeButton(type: .alert) {

            } content: {
                hText("TEXT")
            }
            Spacer()
        }
        .background(hBackgroundColor.primary)

        return VStack(alignment: .leading) {
            buttons
                .colorScheme(.dark)

            buttons
                .colorScheme(.light)
        }
        .hButtonIsLoading(hButtonLarge_Previews.isLoading)
        .disabled(hButtonLarge_Previews.disabled)
    }
}

struct hButtonMedium_Previews: PreviewProvider {
    static var previews: some View {
        let buttons = VStack {
            Spacer()
            hButton.MediumButton(type: .primary) {

            } content: {
                hText("TEXT")
            }
            hButton.MediumButton(type: .primaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.MediumButton(type: .secondary) {

            } content: {
                hText("TEXT")
            }
            hButton.MediumButton(type: .secondaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.MediumButton(type: .ghost) {

            } content: {
                hText("TEXT")
            }
            hButton.MediumButton(type: .alert) {

            } content: {
                hText("TEXT")
            }
            Spacer()
        }
        .background(hBackgroundColor.primary)

        return VStack(alignment: .leading) {
            buttons
                .colorScheme(.dark)

            buttons
                .colorScheme(.light)
        }
        .hButtonIsLoading(hButtonLarge_Previews.isLoading)
        .disabled(hButtonLarge_Previews.disabled)

    }
}

struct hButtonSmall_Previews: PreviewProvider {
    static var previews: some View {
        let buttons = VStack {
            Spacer()
            hButton.SmallButton(type: .primary) {

            } content: {
                hText("TEXT")
            }
            hButton.SmallButton(type: .primaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.SmallButton(type: .secondary) {

            } content: {
                hText("TEXT")
            }
            hButton.SmallButton(type: .secondaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.SmallButton(type: .ghost) {

            } content: {
                hText("TEXT")
            }
            hButton.SmallButton(type: .alert) {

            } content: {
                hText("TEXT")
            }
            Spacer()
        }
        .background(hBackgroundColor.primary)

        return VStack(alignment: .leading) {
            buttons
                .colorScheme(.dark)

            buttons
                .colorScheme(.light)
        }
        .hButtonIsLoading(hButtonLarge_Previews.isLoading)
        .disabled(hButtonLarge_Previews.disabled)

    }
}

struct hButtonMini_Previews: PreviewProvider {
    static var previews: some View {
        let buttons = VStack {
            Spacer()
            hButton.MiniButton(type: .primary) {

            } content: {
                hText("TEXT")
            }
            hButton.MiniButton(type: .primaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.MiniButton(type: .secondary) {

            } content: {
                hText("TEXT")
            }
            hButton.MiniButton(type: .secondaryAlt) {

            } content: {
                hText("TEXT")
            }
            hButton.MiniButton(type: .ghost) {

            } content: {
                hText("TEXT")
            }
            hButton.MiniButton(type: .alert) {

            } content: {
                hText("TEXT")
            }
            Spacer()
        }
        .background(hBackgroundColor.primary)

        return VStack(alignment: .leading) {
            buttons
                .colorScheme(.dark)

            buttons
                .colorScheme(.light)
        }
        .hButtonIsLoading(hButtonLarge_Previews.isLoading)
        .disabled(hButtonLarge_Previews.disabled)
    }
}
