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

extension TooltipDirection {
    /// Next to a system toolbar column there is no room under the buttons, so tooltips open
    /// sideways, away from the column and into the content: a column on the right puts them on
    /// the buttons' left, a column on the left puts them on the right.
    public init(awayFrom systemToolbarEdge: HorizontalEdge?) {
        guard let systemToolbarEdge else {
            self = .below
            return
        }
        self = systemToolbarEdge == .trailing ? .leading : .trailing
    }
}

private struct TooltipDirectionKey: EnvironmentKey {
    static let defaultValue: TooltipDirection = .below
}

extension EnvironmentValues {
    /// Which way the toolbar buttons below this point open their tooltips. Set by
    /// `resolveTooltipDirection()`, so no screen has to work the direction out for itself.
    public var tooltipDirection: TooltipDirection {
        get { self[TooltipDirectionKey.self] }
        set { self[TooltipDirectionKey.self] = newValue }
    }
}

/// Reports the horizontal screen edge a system toolbar column takes up, and nil wherever the
/// toolbar is not a column down the side of the screen.
private struct SystemToolbarEdgeReader: ViewModifier {
    @State private var systemToolbarEdge: HorizontalEdge?
    let onChange: (HorizontalEdge?) -> Void

    func body(content: Content) -> some View {
        content
            .onGeometryChange(
                for: HorizontalEdge?.self,
                of: { proxy in
                    // A regular iPhone in landscape insets both sides alike, around the sensor
                    // housing and the edge across from it. A system toolbar column insets only
                    // the side it is on, folded or unfolded, so the one-sided inset is the column.
                    let insets = proxy.safeAreaInsets
                    guard insets.leading.isFinite, insets.trailing.isFinite else { return nil }
                    let difference = insets.trailing - insets.leading
                    if difference > 1 { return .trailing }
                    if difference < -1 { return .leading }
                    return nil
                }
            ) {
                systemToolbarEdge = $0
            }
            .onAppear { onChange(systemToolbarEdge) }
            .onChange(of: systemToolbarEdge) { onChange($0) }
    }
}

/// Measures the screen once and hands every toolbar button under it the same direction.
private struct ResolvedTooltipDirection: ViewModifier {
    @State private var direction: TooltipDirection = .below

    func body(content: Content) -> some View {
        content
            .onSystemToolbarEdgeChange { direction = .init(awayFrom: $0) }
            // Outside the content's own `.toolbar`, so its items inherit the value too.
            .environment(\.tooltipDirection, direction)
    }
}

extension View {
    public func showTooltip(
        type: ToolbarOptionType,
        placement: ListToolBarPlacement,
        direction: TooltipDirection = .below
    ) -> some View {
        modifier(TooltipViewModifier(type: type, placement: placement, direction: direction))
    }

    /// Calls back with the screen edge occupied by a system toolbar column, as on iPhone Duo,
    /// and with nil wherever the toolbar is a normal bar along the top.
    public func onSystemToolbarEdgeChange(perform action: @escaping (HorizontalEdge?) -> Void) -> some View {
        modifier(SystemToolbarEdgeReader(onChange: action))
    }

    /// Points the tooltips of every toolbar button in this subtree away from a system toolbar
    /// column. Applied wherever a screen sets its toolbar, so the buttons need no direction of
    /// their own; override a single button with `.environment(\.tooltipDirection, _)`.
    public func resolveTooltipDirection() -> some View {
        modifier(ResolvedTooltipDirection())
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
    /// The size the placement assumes for the button the tooltip hangs off. The view the
    /// tooltip is a background of is only as big as the icon, while the button a member sees
    /// and taps is this much.
    private let anchorSize: CGFloat = 44

    @State private var isTooltipVisible: Bool = false
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
        // The button's own frame, which the tooltip hangs off of.
        Color.clear
            .allowsHitTesting(false)
            .overlay {
                if isTooltipVisible {
                    tooltipBody
                        .fixedSize()
                        .transition(
                            .scale(scale: 0, anchor: transitionAnchor)
                                .combined(with: .opacity)
                        )
                        // A zero-width frame at the button's centre pins the tooltip's near edge
                        // there, whatever its width, so it sits in place from its first frame and
                        // only ever grows away from the button. Measuring the width to compute an
                        // offset instead gets it wrong until the tooltip has drawn once, and the
                        // tooltip visibly slides over from that first guess.
                        .frame(width: 0, alignment: pinnedEdge)
                        .offset(offset)
                        .onAppear(perform: startAutoHideTimer)
                }
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

    // MARK: - Placement

    /// The tooltip's edge that is pinned to the button's centre.
    private var pinnedEdge: Alignment {
        switch direction {
        case .below:
            // The edge whose triangle points at the button.
            placement == .trailing ? .trailing : .leading
        case .leading:
            .trailing
        case .trailing:
            .leading
        }
    }

    /// Moves the pinned edge from the button's centre to where it belongs. Constant, because
    /// it depends only on the button and the triangle, never on the tooltip's own size.
    private var offset: CGSize {
        let halfButton = anchorSize / 2
        switch direction {
        case .below:
            // Out to the button's edge, which leaves the triangle — inset by the same half
            // button — over the button's centre.
            return CGSize(
                width: placement == .trailing ? halfButton : -halfButton,
                height: type.offsetForToolTip + (40 - type.offsetForToolTip) / 2
            )
        case .leading:
            // Out to the button's edge, so the triangle's tip touches it.
            return CGSize(width: -halfButton, height: 0)
        case .trailing:
            return CGSize(width: halfButton, height: 0)
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

/// Stands in for the toolbar button the tooltip hangs off, at the size the placement assumes.
private struct TooltipAnchorPreview: View {
    let placement: ListToolBarPlacement
    let direction: TooltipDirection

    var body: some View {
        Circle()
            .fill(hFillColor.Opaque.secondary)
            .frame(width: 44, height: 44)
            .background {
                TooltipView(type: .travelCertificate, placement: placement, direction: direction)
            }
    }
}

#Preview("Below") {
    VStack(spacing: 120) {
        TooltipAnchorPreview(placement: .leading, direction: .below)
            .frame(maxWidth: .infinity, alignment: .leading)
        TooltipAnchorPreview(placement: .trailing, direction: .below)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding(.horizontal, .padding16)
}

#Preview("Sideways") {
    VStack(spacing: 80) {
        TooltipAnchorPreview(placement: .trailing, direction: .leading)
            .frame(maxWidth: .infinity, alignment: .trailing)
        TooltipAnchorPreview(placement: .leading, direction: .trailing)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, .padding16)
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
