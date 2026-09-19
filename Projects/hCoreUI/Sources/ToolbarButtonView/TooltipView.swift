import Foundation
import SwiftUI
import hCore

/// Where a toolbar button's tooltip sits relative to the button.
public enum TooltipDirection: Sendable {
    /// Under the button, pointing up at it. The default for a bar along the top of the screen.
    case below
    /// On the button's leading side, pointing at it from there. For a bar next to a system
    /// toolbar column on the trailing side of the screen, where there is no room underneath and
    /// the tooltip has to open away from the column.
    case leading
    /// On the button's trailing side, pointing at it from there: the mirror, for a system
    /// toolbar column on the leading side of the screen.
    case trailing
}

extension View {
    public func showTooltip(
        type: ToolbarOptionType,
        placement: ListToolBarPlacement,
        direction: TooltipDirection = .below
    ) -> some View {
        modifier(TooltipViewModifier(type: type, placement: placement, direction: direction))
    }
}

struct TooltipViewModifier: ViewModifier {
    let type: ToolbarOptionType
    let placement: ListToolBarPlacement
    let direction: TooltipDirection
    @StateObject private var toolTipManager = ToolTipManager.shared
    @State var showTooltip = false
    @State var xOffset: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .background {
                if showTooltip {
                    TooltipView(
                        type: type,
                        placement: placement,
                        direction: direction
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
                    await delay(0.2)
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
    let placement: ListToolBarPlacement
    let direction: TooltipDirection

    /// The triangle's base, along the tooltip's edge.
    private let triangleWidth: CGFloat = 12
    /// How far the triangle's tip reaches out from the tooltip's edge.
    private let triangleHeight: CGFloat = 6
    private let trianglePadding: CGFloat = .padding16
    /// The width the offset math assumes for the button the tooltip is anchored to.
    private let anchorSize: CGFloat = 44

    @State private var isTooltipVisible: Bool = false
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var autoHideTask: Task<Void, Never>?
    @StateObject private var toolTipManager = ToolTipManager.shared

    // MARK: - Init

    init(type: ToolbarOptionType, placement: ListToolBarPlacement, direction: TooltipDirection = .below) {
        self.type = type
        self.placement = placement
        self.direction = direction
    }

    // MARK: - Body

    var body: some View {
        VStack {
            if isTooltipVisible {
                tooltipBody
                    .fixedSize()
                    .transition(
                        .scale(scale: 0, anchor: transitionAnchor)
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

    // MARK: - Tooltip Layout

    @ViewBuilder private var tooltipBody: some View {
        switch direction {
        case .below:
            VStack(spacing: 0) {
                tooltipTriangle
                tooltipContent
            }
        case .leading:
            // The triangle sits on the edge that faces the button.
            HStack(spacing: 0) {
                tooltipContent
                sideTriangle(pointing: .trailing)
            }
        case .trailing:
            HStack(spacing: 0) {
                sideTriangle(pointing: .leading)
                tooltipContent
            }
        }
    }

    /// The tooltip grows out of its triangle.
    private var transitionAnchor: UnitPoint {
        switch direction {
        case .below:
            UnitPoint(x: 0.5, y: 1)
        case .leading:
            UnitPoint(x: 1, y: 0.5)
        case .trailing:
            UnitPoint(x: 0, y: 0.5)
        }
    }

    // MARK: - Tooltip Triangle

    private var tooltipTriangle: some View {
        HStack {
            if placement == .trailing { Spacer() }
            Triangle()
                .fill(type.tooltipBackgroundColor)
                .frame(width: triangleWidth, height: triangleHeight)
                .padding(.horizontal, trianglePadding)
            if placement == .leading { Spacer() }
        }
    }

    private func sideTriangle(pointing edge: Edge) -> some View {
        Triangle(pointing: edge)
            .fill(type.tooltipBackgroundColor)
            .frame(width: triangleHeight, height: triangleWidth)
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
        switch direction {
        case .below:
            let imageSize = type.imageSize
            if placement == .trailing {
                xOffset = -(proxy.size.width - imageSize) / 2 + (anchorSize - imageSize) / 2
            } else {
                xOffset = (proxy.size.width - imageSize) / 2 - (anchorSize - imageSize) / 2
            }
            yOffset = type.offsetForToolTip + (40 - type.offsetForToolTip) / 2
        case .leading, .trailing:
            // The tooltip is centred on the button, so move it sideways by half of each until
            // the triangle's tip touches the button's edge. `proxy` measures the text box alone.
            let tooltipWidth = proxy.size.width + triangleHeight
            let distance = (tooltipWidth + anchorSize) / 2
            xOffset = direction == .leading ? -distance : distance
            yOffset = 0
        }
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
            await delay(4)
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

/// A soft-tipped pointer whose base lies along one edge of its frame and whose tip points
/// toward the opposite edge.
struct Triangle: Shape {
    var pointing: Edge = .top

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: point(along: 0, out: 0, in: rect))

        path.addLine(to: point(along: 0.33, out: 0.5, in: rect))

        path.addQuadCurve(
            to: point(along: 0.67, out: 0.5, in: rect),
            control: point(along: 0.5, out: 0.8, in: rect)
        )

        path.addLine(to: point(along: 1, out: 0, in: rect))

        return path
    }

    /// Maps a position measured along the base (0...1) and out from the base toward the tip
    /// (0...1) into the rect, for whichever edge the tip points at.
    private func point(along: CGFloat, out: CGFloat, in rect: CGRect) -> CGPoint {
        switch pointing {
        case .top:
            CGPoint(x: rect.minX + along * rect.width, y: rect.maxY - out * rect.height)
        case .bottom:
            CGPoint(x: rect.minX + along * rect.width, y: rect.minY + out * rect.height)
        case .leading:
            CGPoint(x: rect.maxX - out * rect.width, y: rect.minY + along * rect.height)
        case .trailing:
            CGPoint(x: rect.minX + out * rect.width, y: rect.minY + along * rect.height)
        }
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

#Preview("Sideways") {
    HStack(spacing: 200) {
        TooltipView(type: .travelCertificate, placement: .trailing, direction: .leading)
        TooltipView(type: .travelCertificate, placement: .trailing, direction: .trailing)
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
                await delay(0.5)
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
