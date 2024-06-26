import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingField: View {
    private var placeholder: String
    @State private var animate = false
    @Binding var error: String?
    private var value: String
    private let onTap: () -> Void
    @Environment(\.hFieldTrailingView) var fieldTrailingView
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hWithoutFixedHeight) var hWithoutFixedHeight
    @Environment(\.hFieldLockedState) var isLocked
    @Environment(\.hFieldSize) var size
    @Environment(\.hFontSize) var fontSize
    @Environment(\.hWithoutDisabledColor) var withoutDisabledColor

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
        self._error = error ?? Binding.constant(nil)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    hFieldLabel(
                        placeholder: placeholder,
                        animate: $animate,
                        error: $error,
                        shouldMoveLabel: shouldMoveLabel
                    )
                    if !value.isEmpty {
                        getTextLabel
                            .frame(height: hWithoutFixedHeight ?? false ? .infinity : HFontTextStyle.title3.fontSize)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, value.isEmpty ? 0 : 10)

                Spacer()
                fieldTrailingView

            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .addFieldError(animate: $animate, error: $error)
        .onTapGesture {
            if isEnabled {
                onTap()
                self.startAnimation()
            }
        }
        .onChange(of: value) { newValue in
            if isEnabled {
                self.startAnimation()
            }
        }
    }
    private var getTextLabel: some View {
        hText(value, style: fontSize)
            .foregroundColor(foregroundColor)
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if (isEnabled && !isLocked) || withoutDisabledColor {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }

    private func startAnimation() {
        withAnimation {
            self.animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    self.animate = false
                }
            }
        }
    }

}

struct hFloatingField_Previews: PreviewProvider {
    static var previews: some View {

        @State var value: String = ""

        VStack {
            hFloatingField(value: value, placeholder: "ni", error: nil) {

            }
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.copy.image)
            }
        }
    }
}

private struct EnvironmentHCFieldTrailingView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hFieldTrailingView: (AnyView)? {
        get { self[EnvironmentHCFieldTrailingView.self] }
        set { self[EnvironmentHCFieldTrailingView.self] = newValue }
    }
}

extension View {
    public func hFieldTrailingView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hFieldTrailingView, AnyView(content()))
    }
}

private struct EnvironmentWithoutFixedHeight: EnvironmentKey {
    static let defaultValue: Bool? = false
}

extension EnvironmentValues {
    public var hWithoutFixedHeight: (Bool)? {
        get { self[EnvironmentWithoutFixedHeight.self] }
        set { self[EnvironmentWithoutFixedHeight.self] = newValue }
    }
}

extension View {
    public var hWithoutFixedHeight: some View {
        self.environment(\.hWithoutFixedHeight, true)
    }
}

private struct EnvironmentHFieldLockedState: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hFieldLockedState: Bool {
        get { self[EnvironmentHFieldLockedState.self] }
        set { self[EnvironmentHFieldLockedState.self] = newValue }
    }
}

extension View {
    public var hFieldLockedState: some View {
        self.environment(\.hFieldLockedState, true)
    }

    public func hFieldSetLockedState(to value: Bool) -> some View {
        self.environment(\.hFieldLockedState, value)
    }
}

private struct EnvironmentHFontSize: EnvironmentKey {
    static let defaultValue: HFontTextStyle = .title3
}

extension EnvironmentValues {
    public var hFontSize: HFontTextStyle {
        get { self[EnvironmentHFontSize.self] }
        set { self[EnvironmentHFontSize.self] = newValue }
    }
}

extension View {
    public func hFontSize(_ size: HFontTextStyle) -> some View {
        self.environment(\.hFontSize, size)
    }
}
