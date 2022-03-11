import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
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
            hTintColor.red
        } else if focused {
            hLabelColor.primary
        } else {
            hSeparatorColor.separator
        }
    }

    var body: some View {
        HStack {
            ForEach(Array(codeArray.enumerated()), id: \.offset) { offset, digit in
                let focused = code.count == offset
                let hasValue = digit != ""

                if offset == 3 {
                    hText("-").foregroundColor(hLabelColor.tertiary)
                }

                VStack {
                    VStack {
                        hText(digit, style: .title1)
                            .animation(nil)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60, alignment: .center)
                            .contentShape(Rectangle())
                    }
                    .scaleEffect(hasValue ? 1 : 0.5)
                    .animation(.interpolatingSpring(stiffness: 400, damping: 20))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .strokeBorder(digitStroke(focused: focused), lineWidth: 1)
                        .animation(.easeInOut)
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
