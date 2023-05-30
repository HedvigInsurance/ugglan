import Combine
import Foundation
import Introspect
import SwiftUI
import hCore

public struct hFloatingField: View {
    @Environment(\.hTextFieldError) var errorMessage

    private var masking: Masking
    private var placeholder: String
    @State private var animate = false

    var value: String

    public init(
        masking: Masking,
        value: String,
        placeholder: String? = nil
    ) {

        self.masking = masking
        self.placeholder = placeholder ?? ""
        self.value = value
    }

    public var body: some View {
        VStack(spacing: 0) {
            if value != "" {
                Group {
                    getPlaceHolderLabel
                        .padding(.bottom, 1)
                        .padding(.top, 10)
                    getTextLabel
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(getColor())
                .animation(.easeInOut(duration: 0.4), value: animate)
                .clipShape(Squircle.default())
                .padding(.horizontal, 16)
                if let errorMessage = errorMessage {
                    HStack {
                        Image(uiImage: hCoreUIAssets.circularExclamationPoint.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(hTintColor.red)
                        hText(errorMessage, style: .footnote)
                            .padding(.top, 7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(hTintColor.red)
                    }
                }
            } else {
                getPlaceHolderLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(getColor())
                    .animation(.easeInOut(duration: 0.4), value: animate)
                    .clipShape(Squircle.default())
            }
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
            .modifier(hFontModifierNew(style: value != "" ? .footnote : .title3))
            .foregroundColor(hLabelColorNew.secondary)
    }

    private var getTextLabel: some View {
        hTextNew(value, style: .title3)
            .foregroundColor(hLabelColorNew.primary)
    }

    private func startAnimation() {
        self.animate = true
    }

    class hFloatingTextFieldModel: ObservableObject {
        var cancellables = Set<AnyCancellable>()
    }
}
