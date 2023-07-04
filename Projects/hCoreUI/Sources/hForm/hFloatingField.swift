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
                    getTextLabel
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, value.isEmpty ? 0 : 10 - HFontTextStyleNew.title3.uifontLineHeightDifference + 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addFieldBackground(animate: $animate, error: $error)
        .onTapGesture {
            onTap()
            self.startAnimation()
        }
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

struct hFloatingField_Previews: PreviewProvider {
    static var previews: some View {

        @State var value: String = ""

        VStack {
            hFloatingField(value: value, placeholder: "ni", error: nil) {

            }
        }
    }
}
