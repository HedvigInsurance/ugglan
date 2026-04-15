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

extension EnvironmentValues {
    @Entry var hButtonConfigurationType: hButtonConfigurationType = .primary
}

// MARK: Environment Keys and Extensions

extension EnvironmentValues {
    @Entry public var hUseLightMode: Bool = false
}

extension View {
    public var hUseLightMode: some View {
        environment(\.hUseLightMode, true)
    }
}

extension EnvironmentValues {
    @Entry public var hButtonWithBorder: Bool = false
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

extension EnvironmentValues {
    @Entry var hButtonIsLoading: Bool = false
}

extension View {
    public func hButtonIsLoading(_ isLoading: Bool) -> some View {
        environment(\.hButtonIsLoading, isLoading)
    }
}

// MARK: EnvironmentHButtonDontShowLoadingWhenDisabled

extension EnvironmentValues {
    @Entry var hButtonDontShowLoadingWhenDisabled: Bool = false
}

extension View {
    public func hButtonDontShowLoadingWhenDisabled(_ show: Bool) -> some View {
        environment(\.hButtonDontShowLoadingWhenDisabled, show)
    }
}

extension EnvironmentValues {
    @Entry var hButtonTakeFullWidth: Bool = false
}

extension View {
    public func hButtonTakeFullWidth(_ takeFullWidth: Bool) -> some View {
        environment(\.hButtonTakeFullWidth, takeFullWidth)
    }
}

extension EnvironmentValues {
    @Entry public var hUseButtonTextColor: hButtonTextColor = .default
}

extension EnvironmentValues {
    @Entry var hWithTransition: AnyTransition? = nil
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

extension EnvironmentValues {
    @Entry public var hCustomButtonView: AnyView? = nil
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
