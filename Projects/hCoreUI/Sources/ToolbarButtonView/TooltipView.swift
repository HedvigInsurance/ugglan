import Foundation
import SwiftUI
import hCore

struct TooltipView: View {
    @Binding var displayTooltip: Bool
    let type: ToolbarOptionType
    let timeInterval: TimeInterval
    let placement: ListToolBarPlacement
    private let triangleWidth: CGFloat = 12
    private let trianglePadding: CGFloat = .padding16
    @State var xPosition: CGFloat = 0
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
                        if placement == .trailing {
                            Spacer()
                        }
                        Triangle()
                            .fill(type.tooltipColor)
                            .frame(width: triangleWidth, height: 6)
                            .padding(.horizontal, trianglePadding)
                        if placement == .leading {
                            Spacer()
                        }
                    }
                    content
                }
                .fixedSize()
                .transition(.scale(scale: 0, anchor: UnitPoint(x: xPosition, y: 0)).combined(with: .opacity))
            }
        }
        .background {
            if displayTooltip {
                //used to calculate the anchor of the tooltip
                content
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    let percentageOffset =
                                        (proxy.size.width - (proxy.size.width - triangleWidth / 2 - trianglePadding))
                                        / proxy.size.width
                                    xPosition = placement == .leading ? percentageOffset : 1 - percentageOffset
                                }
                                .onChange(of: proxy.size) { value in
                                    let percentageOffset =
                                        (value.width - (value.width - triangleWidth / 2 - trianglePadding))
                                        / value.width
                                    xPosition = placement == .leading ? percentageOffset : 1 - percentageOffset
                                }
                        }
                    }
                    .opacity(0)
            }
        }
        .onAppear {
            if canShowTooltip() {
                DispatchQueue.main.asyncAfter(deadline: .now() + type.delay) {
                    withAnimation(.defaultSpring) {
                        displayTooltip = true
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + type.delay + 4) {
                    withAnimation(.defaultSpring) {
                        displayTooltip = false
                    }
                }
            }
        }
    }

    var content: some View {
        hText(type.textToShow ?? "", style: .label)
            .padding(.horizontal, .padding12)
            .padding(.top, 6.5)
            .padding(.bottom, 7.5)
            .foregroundColor(hTextColor.Opaque.negative)
            .background(type.tooltipColor)
            .cornerRadius(.cornerRadiusS)
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

#Preview {
    VStack {
        Triangle().fill(Color.red)
            .frame(width: 120, height: 60)
            .background(Color.blue)
        Spacer()
    }
}

#Preview {
    VStack {
        TooltipView(displayTooltip: .constant(true), type: .travelCertificate, timeInterval: 1, placement: .trailing)
    }
}
