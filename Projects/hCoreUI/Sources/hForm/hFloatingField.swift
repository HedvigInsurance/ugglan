import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingField: View {
    @Environment(\.hTextFieldError) var errorMessage

    private var placeholder: String
    @State private var animate = false
    private var value: String
    private let onTap: () -> Void
    public init(
        value: String,
        placeholder: String? = nil,
        onTap: @escaping () -> Void
    ) {

        self.placeholder = placeholder ?? ""
        self.onTap = onTap
        self.value = value
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                getPlaceHolderLabel
                if !value.isEmpty {
                    getTextLabel
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, value.isEmpty ? 16 : 10)
            .frame(height: 72)
            .background(getColor())
            .animation(.easeInOut(duration: 0.4), value: animate)
            .clipShape(Squircle.default())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            onTap()
            self.startAnimation()
        }
    }

    @hColorBuilder
    private func getColor() -> some hColor {
        if animate {
            hBackgroundColorNew.inputBackgroundActive
        } else {
            hBackgroundColorNew.inputBackground
        }
    }

    private var getPlaceHolderLabel: some View {
        Text(placeholder)
            .modifier(hFontModifierNew(style: !value.isEmpty ? .footnote : .title3))
            .foregroundColor(hLabelColorNew.secondary)
    }

    private var getTextLabel: some View {
        hTextNew(value, style: .title3)
            .foregroundColor(hLabelColorNew.primary)
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
