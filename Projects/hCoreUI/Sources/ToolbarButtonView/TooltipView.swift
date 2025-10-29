import Foundation
import SwiftUI
import hCore

extension View {
    public func showTooltip(
        type: ToolbarOptionType,
        placement: ListToolBarPlacement
    ) -> some View {
        modifier(TooltipViewModifier(type: type, placement: placement))
    }
}

struct TooltipViewModifier: ViewModifier {
    let type: ToolbarOptionType
    let placement: ListToolBarPlacement
    @StateObject private var toolTipManager = ToolTipManager.shared
    @State var showTooltip = false
    @State var xOffset: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .background {
                if showTooltip {
                    TooltipView(
                        type: type,
                        placement: placement
                    )
                }
            }
            .onChange(of: toolTipManager.displayedTooltip) { newValue in
                withAnimation {
                    showTooltip = newValue == type
                }
            }
            .onAppear {
                Task {
                    try await Task.sleep(nanoseconds: 200_000_000)
                    toolTipManager.checkIfDisplayIsNeeded(type)
                    showTooltip = toolTipManager.displayedTooltip == type
                }
            }
            .onDisappear {
                toolTipManager.removeForType(type: type)
            }
    }
}

/// A SwiftUI view that displays a tooltip with a triangle pointer and custom content.
struct TooltipView: View {
    // MARK: - Properties

    let type: ToolbarOptionType
    let timeInterval: TimeInterval
    let placement: ListToolBarPlacement
    private let triangleWidth: CGFloat = 12
    private let trianglePadding: CGFloat = .padding16

    @State private var isTooltipVisible: Bool = false
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var autoHideTask: Task<Void, Never>?
    @StateObject private var toolTipManager = ToolTipManager.shared

    // MARK: - Init

    init(type: ToolbarOptionType, placement: ListToolBarPlacement) {
        self.type = type
        timeInterval = type.timeIntervalForShowingAgain ?? .days(numberOfDays: 30)
        self.placement = placement
    }

    // MARK: - Body

    var body: some View {
        VStack {
            if isTooltipVisible {
                VStack(spacing: 0) {
                    tooltipTriangle
                    tooltipContent
                }
                .fixedSize()
                .transition(
                    .scale(scale: 0, anchor: UnitPoint(x: 0.5, y: 1))
                        .combined(with: .opacity)
                )
                .offset(x: xOffset, y: yOffset)
                .onAppear(perform: startAutoHideTimer)
            }
        }
        .background {
            // GeometryReader for offset calculation (invisible)
            tooltipContent
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { updateOffsets(proxy: proxy) }
                            .onChange(of: proxy.size) { _ in updateOffsets(proxy: proxy) }
                    }
                }
                .opacity(0)
        }
        .onAppear(perform: showTooltipWithDelay)
        .onDisappear {
            autoHideTask?.cancel()
        }
    }

    // MARK: - Tooltip Triangle

    private var tooltipTriangle: some View {
        HStack {
            if placement == .trailing { Spacer() }
            Triangle()
                .fill(type.tooltipBackgroundColor)
                .frame(width: triangleWidth, height: 6)
                .padding(.horizontal, trianglePadding)
            if placement == .leading { Spacer() }
        }
    }

    // MARK: - Tooltip Content

    private var tooltipContent: some View {
        hText(type.textToShow ?? "", style: .label)
            .padding(.horizontal, .padding12)
            .padding(.top, 6.5)
            .padding(.bottom, 7.5)
            .foregroundColor(type.tooltipTextColor)
            .background(type.tooltipBackgroundColor)
            .cornerRadius(.cornerRadiusS)
    }

    // MARK: - Offset Calculation

    private func updateOffsets(proxy: GeometryProxy) {
        let imageSize = type.imageSize
        if placement == .trailing {
            xOffset = -(proxy.size.width - imageSize) / 2 + (44 - imageSize) / 2
        } else {
            xOffset = (proxy.size.width - imageSize) / 2 - (44 - imageSize) / 2
        }
        yOffset = imageSize + (40 - imageSize) / 2
    }

    // MARK: - Tooltip Animation & Timer

    private func showTooltipWithDelay() {
        Task {
            withAnimation(.defaultSpring.delay(type.delay)) {
                isTooltipVisible = true
            }
        }
    }

    private func startAutoHideTimer() {
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled else { return }
            if #available(iOS 17.0, *) {
                withAnimation(.defaultSpring) {
                    isTooltipVisible = false
                } completion: {
                    toolTipManager.removeTooltip(type)
                }
            } else {
                withAnimation(.defaultSpring) {
                    isTooltipVisible = false
                }
                toolTipManager.removeTooltip(type)
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
        TooltipView(type: .travelCertificate, placement: .trailing)
    }
}

@MainActor
class ToolTipManager: ObservableObject {
    static let shared = ToolTipManager()

    private init() {}

    @Published fileprivate var displayedTooltip: ToolbarOptionType?
    @Published private var toolTipsToShow: Set<ToolbarOptionType> = Set()

    func checkIfDisplayIsNeeded(_ tooltip: ToolbarOptionType) {
        if tooltip.shouldShowTooltip(for: tooltip.timeIntervalForShowingAgain ?? .days(numberOfDays: 30)) {
            toolTipsToShow.insert(tooltip)
            Task {
                try await Task.sleep(nanoseconds: 500_000_000)
                if let first = Array(toolTipsToShow).sorted(by: { $0.priority < $1.priority }).first {
                    presentTooltip(first)
                }
            }
        }
    }

    private func presentTooltip(_ tooltip: ToolbarOptionType) {
        if toolTipsToShow.contains(tooltip) {
            if displayedTooltip == nil {
                displayedTooltip = tooltip
            }
        }
    }

    fileprivate func removeTooltip(_ tooltip: ToolbarOptionType) {
        displayedTooltip = nil
        removeForType(type: tooltip)
        tooltip.onShow()
        if let first = toolTipsToShow.first {
            presentTooltip(first)
        }
    }

    fileprivate func removeForType(type: ToolbarOptionType) {
        toolTipsToShow.remove(type)
        displayedTooltip = nil
    }
}
