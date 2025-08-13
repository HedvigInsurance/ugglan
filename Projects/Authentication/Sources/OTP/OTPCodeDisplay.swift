import SwiftUI
import hCore
import hCoreUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size _: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

struct OTPCodeDisplay: View {
    var code: String
    var showRedBorders: Bool

    var codeArray: [String] {
        (0...5)
            .map { offset in
                if code.count > offset {
                    return String(code[code.index(code.startIndex, offsetBy: offset)])
                }

                return ""
            }
    }

    @hColorBuilder func digitStroke(focused: Bool) -> some hColor {
        if showRedBorders {
            hSignalColor.Red.text
        } else if focused {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Opaque.tertiary
        }
    }

    var body: some View {
        HStack {
            ForEach(Array(codeArray.enumerated()), id: \.offset) { offset, digit in
                let focused = code.count == offset
                let hasValue = digit != ""

                if offset == 3 {
                    hText("-").foregroundColor(hTextColor.Opaque.tertiary)
                }

                VStack {
                    VStack {
                        hText(digit, style: .displayXSLong)
                            .animation(nil, value: UUID())
                            .frame(maxWidth: .infinity)
                            .frame(height: 60, alignment: .center)
                            .contentShape(Rectangle())
                    }
                    .scaleEffect(hasValue ? 1 : 0.5)
                    .animation(.interpolatingSpring(stiffness: 400, damping: 20), value: UUID())
                }
                .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadiusL)
                        .strokeBorder(digitStroke(focused: focused), lineWidth: 1)
                        .animation(.easeInOut, value: UUID())
                )
            }
        }
        .modifier(
            ShakeEffect(
                shakesPerUnit: showRedBorders ? 3 : 0,
                animatableData: showRedBorders ? 1 : 0
            )
        )
    }
}
