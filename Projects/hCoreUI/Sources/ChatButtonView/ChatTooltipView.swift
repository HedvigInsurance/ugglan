import Foundation
import SwiftUI
import hCore

struct TooltipView: View {
    @Binding var displayTooltip: Bool
    let type: ToolbarOptionType
    let timeInterval: TimeInterval

    func canShowTooltip() -> Bool {
        if type.showAsTooltip {
            return type.shouldShowTooltip(for: timeInterval)
        }
        return false
    }

    var body: some View {
        VStack {
            if displayTooltip {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Triangle()
                            .fill(hFillColor.Opaque.secondary)
                            .frame(width: 12, height: 6)
                            .padding(.trailing, .padding16)
                    }

                    hText(type.textToShow ?? "")
                        .padding(.horizontal)
                        .padding(.vertical, .padding10)
                        .foregroundColor(hTextColor.Opaque.negative)
                        .background(hFillColor.Opaque.secondary)
                        .cornerRadius(.cornerRadiusS)
                        .colorScheme(.light)
                }
                .transition(.scale(scale: 0, anchor: UnitPoint(x: 0.90, y: 0)).combined(with: .opacity))
            }
        }
        .onAppear {
            if canShowTooltip() {
                withAnimation(.spring().delay(type.delay)) {
                    displayTooltip = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + type.delay + 4) {
                    withAnimation(.spring()) {
                        displayTooltip = false
                    }
                }
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: .init(x: rect.maxX * 0.33, y: rect.maxY * 0.5))

        path.addQuadCurve(
            to: .init(x: rect.maxX * 0.67, y: rect.maxY * 0.5),
            control: .init(x: rect.maxX * 0.5, y: rect.maxY * 0.2)
        )

        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))

        return path
    }
}

#Preview{
    VStack {
        Triangle().fill(Color.red)
            .frame(width: 120, height: 60)
            .background(Color.blue)
        Spacer()
    }
}
