import Foundation
import SwiftUI
import hCore

struct TooltipView: View {
    @Binding var displayTooltip: Bool
    let type: ToolbarOptionType
    let timeInterval: TimeInterval

    var userDefaultsKey: String { "tooltip_\(type.tooltipId)_past_date" }

    func canShowTooltip() -> Bool {
        if type == .chat {
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    setDefaultsTime()
                    return true
                }

                return false
            }

            setDefaultsTime()
            return true
        }
        return false
    }

    func setDefaultsTime() {
        UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
    }

    var body: some View {
        VStack {
            if displayTooltip {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Triangle()
                            .fill(hSignalColorNew.blueFill)
                            .frame(width: 18, height: 8)
                            .padding(.trailing, 24)
                    }
                    hText(L10n.HomeTab.chatHintText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .foregroundColor(hSignalColorNew.blueText)
                        .background(hSignalColorNew.blueFill)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
                        .colorScheme(.light)
                }
                .transition(.scale(scale: 0, anchor: UnitPoint(x: 1, y: 0)).combined(with: .opacity))
            }
        }
        .onAppear {
            if canShowTooltip() {
                withAnimation(.spring().delay(1.5)) {
                    displayTooltip = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
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

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}
