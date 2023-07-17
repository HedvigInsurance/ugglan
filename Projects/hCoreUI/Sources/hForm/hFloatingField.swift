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
    @Environment(\.isEnabled) var isEnabled

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
            VStack(alignment: .leading, spacing: 0) {
                hFieldLabel(
                    placeholder: placeholder,
                    animate: $animate,
                    error: $error,
                    shouldMoveLabel: shouldMoveLabel
                )
                if !value.isEmpty {
                    getTextLabel.frame(height: HFontTextStyle.title3.fontSize)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, value.isEmpty ? 0 : 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .onTapGesture {
            if isEnabled {
                onTap()
                self.startAnimation()
            }
        }
    }
    private var getTextLabel: some View {
        hText(value, style: .title3)
            .foregroundColor(foregroundColor)
    }

    @hColorBuilder
    private var foregroundColor: some hColor {
        if isEnabled {
            hTextColorNew.primary
        } else {
            hTextColorNew.secondary
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

        @State var value: String = " 2"

        VStack {
            hFloatingField(value: value, placeholder: "ni", error: nil) {

            }
        }
    }
}
