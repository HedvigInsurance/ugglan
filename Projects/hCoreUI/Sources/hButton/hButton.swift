import Foundation
import SwiftUI

@MainActor
public struct hButtonContent {
    let title: String
    let buttonImage: hButtonImage?

    public init(
        title: String,
        buttonImage: hButtonImage? = nil
    ) {
        self.title = title
        self.buttonImage = buttonImage
    }

    public struct hButtonImage {
        let image: UIImage
        let alignment: HorizontalAlignment

        public init(
            image: UIImage,
            alignment: HorizontalAlignment = .center
        ) {
            self.image = image
            self.alignment = alignment
        }
    }
}

public struct hButton: View {
    var size: hButtonSize
    var type: hButtonConfigurationType
    let buttonContent: hButtonContent
    var action: () -> Void
    @Environment(\.hWithTransition) var withTransition
    @Environment(\.hCustomButtonView) var customButtonView

    public init(
        _ size: hButtonSize,
        _ type: hButtonConfigurationType,
        buttonContent: hButtonContent,
        _ action: @escaping () -> Void
    ) {
        self.type = type
        self.size = size
        self.buttonContent = buttonContent
        self.action = action
    }

    public var body: some View {
        _hButton(action: {
            action()
        }) {
            if customButtonView != nil {
                customButtonView
            } else {
                if let transition = withTransition {
                    content
                        .transition(transition)
                } else {
                    content
                }
            }
        }
        .buttonStyle(ButtonFilledStyle(size: size))
        .hButtonConfigurationType(type)
    }

    private var content: some View {
        HStack(spacing: .padding8) {
            imageView(for: .leading)
            textView
            imageView(for: .trailing)
        }
    }

    private var textView: some View {
        hText(buttonContent.title, style: size == .small ? .label : .body1)
    }

    @ViewBuilder
    private func imageView(for alignment: HorizontalAlignment) -> (some View)? {
        if let image = buttonContent.buttonImage, image.alignment == alignment {
            Image(uiImage: image.image)
                .resizable()
                .frame(width: .padding16, height: .padding16)
        }
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

private struct EnvironmentHUseButtonTextColor: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: hButtonTextColor = .default
}

extension EnvironmentValues {
    public var hUseButtonTextColor: hButtonTextColor {
        get { self[EnvironmentHUseButtonTextColor.self] }
        set { self[EnvironmentHUseButtonTextColor.self] = newValue }
    }
}

private struct EnvironmentHWithTransition: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: AnyTransition? = nil
}

extension EnvironmentValues {
    var hWithTransition: AnyTransition? {
        get { self[EnvironmentHWithTransition.self] }
        set { self[EnvironmentHWithTransition.self] = newValue }
    }
}

extension View {
    public func hWithTransition(_ transition: AnyTransition?) -> some View {
        self.environment(\.hWithTransition, transition)
    }
}

extension View {
    public func hUseButtonTextColor(_ color: hButtonTextColor) -> some View {
        self.environment(\.hUseButtonTextColor, color)
    }
}

@MainActor
private struct EnvironmentHCustomButtonView: @preconcurrency EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hCustomButtonView: AnyView? {
        get { self[EnvironmentHCustomButtonView.self] }
        set { self[EnvironmentHCustomButtonView.self] = newValue }
    }
}

extension View {
    public func hCustomButtonView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hCustomButtonView, AnyView(content()))
    }
}

public enum hButtonTextColor {
    case `default`
    case negative
    case red
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
                    buttonContent: .init(title: "TEXT"),
                    {}
                )
            }
        }
    }

    hSection {
        VStack(alignment: .leading) {
            buttons
                .colorScheme(.dark)

            buttons
                .colorScheme(.light)
        }
    }
    .background(hBackgroundColor.primary)
    .hButtonIsLoading(isLoading)
    .disabled(disabled)
    .sectionContainerStyle(.transparent)
}
