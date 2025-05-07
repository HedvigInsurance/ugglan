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
