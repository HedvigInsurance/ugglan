import Foundation
import SwiftUI

public struct hButton: View {
    private let size: hButtonSize
    private let type: hButtonConfigurationType
    private let content: hButtonContent
    private let action: () -> Void
    @Environment(\.hWithTransition) private var withTransition
    @Environment(\.hCustomButtonView) private var customButtonView

    public init(
        _ size: hButtonSize,
        _ type: hButtonConfigurationType,
        content: hButtonContent,
        _ action: @escaping () -> Void
    ) {
        self.type = type
        self.size = size
        self.content = content
        self.action = action
    }

    public var body: some View {
        _hButton(action: {
            action()
        }) {
            customButtonView
                ?? AnyView(
                    mainContent
                        .withOptionalTransition(withTransition)
                )
        }
        .accessibilityLabel(content.title)
        .buttonStyle(ButtonFilledStyle(size: size))
        .hButtonConfigurationType(type)
    }

    private var mainContent: some View {
        HStack(spacing: .padding8) {
            imageView(for: .leading)
            textView
            imageView(for: .trailing)
        }
    }

    private var textView: some View {
        hText(content.title, style: size == .small ? .label : .body1)
    }

    @ViewBuilder
    private func imageView(for alignment: HorizontalAlignment) -> some View {
        if let image = content.buttonImage, image.alignment == alignment {
            image.image
                .resizable()
                .frame(width: .padding16, height: .padding16)
        }
    }
}

@MainActor
public struct hButtonContent: Equatable {
    let title: String
    let buttonImage: hButtonImage?

    public init(
        title: String,
        buttonImage: hButtonImage? = nil
    ) {
        self.title = title
        self.buttonImage = buttonImage
    }

    @MainActor
    public struct hButtonImage: Equatable {
        let image: Image
        let alignment: HorizontalAlignment

        public init(
            image: Image,
            alignment: HorizontalAlignment = .center
        ) {
            self.image = image
            self.alignment = alignment
        }
    }
}

public enum hButtonSize: CaseIterable {
    case large
    case medium
    case small
}

struct _hButton<Content: View>: View {
    @Environment(\.hButtonIsLoading) var isLoading
    var content: () -> Content
    var action: () -> Void

    init(
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
    func buttonCornerModifier(_ size: hButtonSize, withBorder: Bool) -> some View {
        var cornerRadius: CGFloat {
            switch size {
            case .small: .cornerRadiusS
            case .medium: .cornerRadiusM
            case .large: .cornerRadiusL
            }
        }

        self.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                Group {
                    if withBorder {
                        RoundedRectangle(cornerRadius: cornerRadius).stroke(hBorderColor.primary, lineWidth: 1)
                    }
                }
            )
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

// MARK: Environment Keys and Extensions

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
        environment(\.hUseLightMode, true)
    }
}

private struct EnvironmentHButtonWithBorder: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hButtonWithBorder: Bool {
        get { self[EnvironmentHButtonWithBorder.self] }
        set { self[EnvironmentHButtonWithBorder.self] = newValue }
    }
}

extension View {
    public var hButtonWithBorder: some View {
        environment(\.hButtonWithBorder, true)
    }
}

extension View {
    public func hButtonConfigurationType(_ type: hButtonConfigurationType) -> some View {
        environment(\.hButtonConfigurationType, type)
    }
}

// MARK: hButtonIsLoading

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
        environment(\.hButtonIsLoading, isLoading)
    }
}

// MARK: EnvironmentHButtonDontShowLoadingWhenDisabled

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
        environment(\.hButtonDontShowLoadingWhenDisabled, show)
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
        environment(\.hButtonTakeFullWidth, takeFullWidth)
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
        environment(\.hWithTransition, transition)
    }
}

extension View {
    public func hUseButtonTextColor(_ color: hButtonTextColor) -> some View {
        environment(\.hUseButtonTextColor, color)
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
        environment(\.hCustomButtonView, AnyView(content()))
    }
}

extension View {
    func withOptionalTransition(_ transition: AnyTransition?) -> some View {
        if let transition = transition {
            return AnyView(self.transition(transition))
        } else {
            return AnyView(self)
        }
    }
}

public enum hButtonTextColor {
    case `default`
    case negative
    case red
}

struct hButton_Previews: PreviewProvider {
    static var previews: some View {
        @State var isLoading = false
        @State var disabled = false
        let buttons = VStack(alignment: .leading) {
            ForEach(hButtonSize.allCases, id: \.self) { size in
                ForEach(hButtonConfigurationType.allCases, id: \.self) { type in
                    hButton(
                        size,
                        type,
                        content: .init(title: "TEXT"),
                        {}
                    )
                }
            }
        }

        return hSection {
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
}
