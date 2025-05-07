import Foundation
import SwiftUI

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

public enum hButtonSize: CaseIterable {
    case large
    case medium
    case small
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
    func buttonCornerModifier(_ size: hButtonSize) -> some View {
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
