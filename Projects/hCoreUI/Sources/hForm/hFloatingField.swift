import Combine
import Foundation
import hCore
import SwiftUI

public struct hFloatingField: View {
    private var placeholder: String
    @State private var animate = false
    @Binding var error: String?
    private var value: String
    private let onTap: () -> Void
    @Environment(\.hFieldTrailingView) var fieldTrailingView
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hWithoutFixedHeight) var hWithoutFixedHeight
    @Environment(\.hFieldSize) var size
    @Environment(\.hBackgroundOption) var backgroundOption
    @Environment(\.hAnimateField) var animateField

    public var shouldMoveLabel: Binding<Bool> {
        Binding(
            get: { !value.isEmpty },
            set: { _ in }
        )
    }

    public init(
        value: String,
        placeholder: String? = nil,
        error: Binding<String?>? = nil,
        onTap: @escaping () -> Void
    ) {
        self.placeholder = placeholder ?? ""
        self.onTap = onTap
        self.value = value
        _error = error ?? Binding.constant(nil)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: -2) {
                    hFieldLabel(
                        placeholder: placeholder,
                        useScaleEffect: false,
                        animate: $animate,
                        error: $error,
                        shouldMoveLabel: shouldMoveLabel
                    )
                    if !value.isEmpty {
                        getTextLabel
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                fieldTrailingView
            }
            .padding(.top, !value.isEmpty ? size.topPaddingWithSubtitle : size.topPadding)
            .padding(.bottom, !value.isEmpty ? size.bottomPaddingWithSubtitle : size.bottomPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            if isEnabled {
                onTap()
                startAnimation()
            }
        }
        .onChange(of: value) { _ in
            if isEnabled {
                startAnimation()
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityElement(children: .combine)
    }

    private var getTextLabel: some View {
        HStack(spacing: 0) {
            hText(value, style: size == .large ? .body2 : .body1)
                .foregroundColor(foregroundColor)
                .fixedSize(horizontal: false, vertical: true)
            hText(" ")
        }
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if (isEnabled && !backgroundOption.contains(.locked)) || backgroundOption.contains(.withoutDisabled) {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Translucent.secondary
        }
    }

    private func startAnimation() {
        if animateField {
            withAnimation {
                animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        animate = false
                    }
                }
            }
        }
    }
}

struct hFloatingField_Previews: PreviewProvider {
    static var previews: some View {
        @State var value = "S"

        VStack {
            hFloatingField(value: value, placeholder: "ni", error: nil) {}
                .hFieldSize(.large)
                .hFieldTrailingView {
                    hCoreUIAssets.copy.view
                }
            hFloatingField(value: value, placeholder: "ni", error: nil) {}
                .hFieldTrailingView {
                    hCoreUIAssets.copy.view
                }
                .hFieldSize(.medium)

            hFloatingField(value: value, placeholder: "ni", error: nil) {}
                .hFieldTrailingView {
                    hCoreUIAssets.copy.view
                }
                .hFieldSize(.small)
        }
    }
}

private struct EnvironmentHCFieldTrailingView: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: AnyView? = nil
}

public extension EnvironmentValues {
    var hFieldTrailingView: AnyView? {
        get { self[EnvironmentHCFieldTrailingView.self] }
        set { self[EnvironmentHCFieldTrailingView.self] = newValue }
    }
}

public extension View {
    func hFieldTrailingView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        environment(\.hFieldTrailingView, AnyView(content()))
    }
}

private struct EnvironmentWithoutFixedHeight: EnvironmentKey {
    static let defaultValue: Bool? = false
}

public extension EnvironmentValues {
    var hWithoutFixedHeight: Bool? {
        get { self[EnvironmentWithoutFixedHeight.self] }
        set { self[EnvironmentWithoutFixedHeight.self] = newValue }
    }
}

public extension View {
    var hWithoutFixedHeight: some View {
        environment(\.hWithoutFixedHeight, true)
    }
}
