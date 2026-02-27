import SwiftUI

public struct hRadioOptionSelectedView<T>: View where T: Equatable {
    @Binding var selectedValue: T?
    @Environment(\.isEnabled) var enabled
    @Environment(\.hUseCheckbox) var useCheckbox
    let value: T

    public init(selectedValue: Binding<T?>, value: T) {
        _selectedValue = selectedValue
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
        .accessibilityAddTraits(selectedValue == value ? .isSelected : [])
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
                        hCoreUIAssets.checkmark.view
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
                lineWidth: selectedValue == value ? 0 : 2
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
            if isSelected {
                hFillColor.Translucent.disabled
            } else {
                hSurfaceColor.Opaque.primary
            }
        } else if isSelected {
            hSignalColor.Green.element
        } else {
            hBackgroundColor.clear
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

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var value: String? = "id"
    @Previewable @State var error: String?
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
