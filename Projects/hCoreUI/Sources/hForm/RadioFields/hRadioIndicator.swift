import SwiftUI
import hCore

public struct hRadioIndicator: View {
    @Environment(\.isEnabled) private var isEnabled

    private let isSelected: Bool

    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }

    public var body: some View {
        Circle()
            .strokeBorder(hBorderColor.secondary, lineWidth: isSelected ? 0 : 2)
            .background(
                Circle()
                    .foregroundColor(fillColor)
                    .mask {
                        Rectangle()
                            .overlay {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                    }
                    .opacity(isSelected ? 1 : 0)
            )
            .frame(width: 24, height: 24)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    /// The disc fades via layer opacity, not from clear — a colour interpolated from
    /// transparent passes through a muddy dark green on the way in.
    @hColorBuilder
    private var fillColor: some hColor {
        if isEnabled {
            hSignalColor.Green.element
        } else {
            hFillColor.Translucent.disabled
        }
    }
}

@available(iOS 17.0, *)
#Preview("States") {
    VStack(spacing: .padding16) {
        HStack(spacing: .padding16) {
            hRadioIndicator(isSelected: false)
            hRadioIndicator(isSelected: true)
        }
        HStack(spacing: .padding16) {
            hRadioIndicator(isSelected: false)
            hRadioIndicator(isSelected: true)
        }
        .disabled(true)
    }
    .padding(.padding32)
    .background(hSurfaceColor.Translucent.primary)
}
