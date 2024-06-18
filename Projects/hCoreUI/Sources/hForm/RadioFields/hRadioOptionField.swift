import SwiftUI
import hCore

//public struct hRadioOptionField: View {
//    private var placeholder: String
//    @Binding private var value: String?
//    @State private var animate = false
//    private var useAnimation: Bool
//    @Binding var error: String?
//    private var listOfOptions: [String]
//
//    public var shouldMoveLabel: Binding<Bool> {
//        Binding(
//            get: { true },
//            set: { _ in }
//        )
//    }
//
//    public init(
//        value: Binding<String?>?,
//        placeholder: String? = nil,
//        error: Binding<String?>? = nil,
//        useAnimation: Bool = false,
//        listOfOptions: [String]? = [L10n.General.yes, L10n.General.no]
//    ) {
//        self.placeholder = placeholder ?? ""
//        self._value = value ?? Binding.constant(nil)
//        self._error = error ?? Binding.constant(nil)
//        self.useAnimation = useAnimation
//        self.listOfOptions = listOfOptions ?? []
//    }
//
//    public var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            hFieldLabel(
//                placeholder: placeholder,
//                animate: $animate,
//                error: $error,
//                shouldMoveLabel: shouldMoveLabel
//            )
//            .padding(.bottom, 13)
//
//            HStack(spacing: 16) {
//                getCheckBox(texts: listOfOptions)
//                Spacer()
//            }
//        }
//        .padding(.vertical, .padding16)
//        .addFieldBackground(animate: $animate, error: $error)
//    }
//
//    func getCheckBox(texts: [String]) -> some View {
//        ForEach(texts, id: \.self) { text in
//            HStack(spacing: 8) {
//                Text(text)
//                hRadioOptionSelectedView(selectedValue: $value, value: text)
//            }
//            .onTapGesture {
//                ImpactGenerator.soft()
//                withAnimation(.none) {
//                    self.value = text
//                }
//                if useAnimation {
//                    self.animate = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        self.animate = false
//                    }
//                }
//            }
//        }
//    }
//}

struct hRadioOptionSelectedView: View {
    @Binding var selectedValue: String?
    @Environment(\.isEnabled) var enabled
    @Environment(\.hUseCheckbox) var useCheckbox
    let value: String

    init(selectedValue: Binding<String?>, value: String) {
        self._selectedValue = selectedValue
        self.value = value
    }

    var body: some View {
        Group {
            if useCheckbox {
                squareComponent
            } else {
                circleComponent
            }
        }
        .frame(width: 24, height: 24)
    }

    var squareComponent: some View {
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(
                hRadioOptionSelectedView.getBorderColor(
                    isSelected: selectedValue == value,
                    enabled: enabled
                ),
                lineWidth: (selectedValue == value || !enabled) ? 0 : 1.5
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(
                            hRadioOptionSelectedView.getFillColor(
                                isSelected: selectedValue == value,
                                enabled: enabled
                            )
                        )
                    if selectedValue == value {
                        Image(uiImage: hCoreUIAssets.checkmark.image)
                            .foregroundColor(hTextColor.Opaque.negative)
                    }
                }
                .compositingGroup()
            )
    }

    var circleComponent: some View {
        Circle()
            .strokeBorder(
                hRadioOptionSelectedView.getBorderColor(
                    isSelected: selectedValue == value,
                    enabled: enabled
                ),
                lineWidth: selectedValue == value ? 0 : 1.5
            )
            .background(
                ZStack {
                    Circle()
                        .foregroundColor(
                            hRadioOptionSelectedView.getFillColor(
                                isSelected: selectedValue == value,
                                enabled: enabled
                            )
                        )
                    Circle().fill()
                        .frame(width: 8, height: 8)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
            )
    }

    @hColorBuilder
    static func getFillColor(isSelected: Bool, enabled: Bool) -> some hColor {
        if !enabled {
            hFillColor.Translucent.disabled
        } else if isSelected {
            hSignalColor.Green.element
        } else {
            hSurfaceColor.Opaque.primary
        }
    }

    @hColorBuilder
    static func getBorderColor(isSelected: Bool, enabled: Bool) -> some hColor {
        if !enabled {
            hFillColor.Translucent.disabled
        } else if isSelected {
            hSignalColor.Green.element
        } else {
            hBorderColor.secondary
        }
    }
}

struct hRadioOptionField_Previews: PreviewProvider {
    @State static var value: String? = "id"
    @State static var error: String?
    static var previews: some View {
        VStack {
            hRadioField(
                id: "id",
                customContent: {
                    hText("id")
                },
                selected: $value,
                error: $error,
                useAnimation: true
            )
            hRadioField(
                id: "id2",
                customContent: {
                    hText("id2")
                },
                selected: $value,
                error: $error,
                useAnimation: true
            )
        }
        .disabled(true)
    }
}
