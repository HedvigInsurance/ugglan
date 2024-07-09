import SwiftUI
import hCore

public struct hRadioOptionSelectedView: View {
    @Binding var selectedValue: String?
    @Environment(\.isEnabled) var enabled
    @Environment(\.hUseCheckbox) var useCheckbox
    let value: String

    public init(selectedValue: Binding<String?>, value: String) {
        self._selectedValue = selectedValue
        self.value = value
    }

    public var body: some View {
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
                leftView: {
                    hText("id")
                        .asAnyView
                },
                selected: $value,
                error: $error,
                useAnimation: true
            )
            hRadioField(
                id: "id2",
                leftView: {
                    hText("id2")
                        .asAnyView
                },
                selected: $value,
                error: $error,
                useAnimation: true
            )
        }
        .disabled(true)
    }
}
