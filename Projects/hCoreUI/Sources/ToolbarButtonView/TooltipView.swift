import Foundation
import SwiftUI
import hCore

extension View {
    public func showTooltip(
        type: ToolbarOptionType,
        placement: ListToolBarPlacement
    ) -> some View {
        return self.modifier(TooltipViewModifier(type: type, placement: placement))
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
                    self.showTooltip = newValue == type
                }
            }
            .onAppear {
                toolTipManager.checkIfDisplayIsNeeded(type)
                self.showTooltip = toolTipManager.displayedTooltip == type
            }
            .onDisappear {
                toolTipManager.removeForType(type: type)
            }
    }
}

struct TooltipView: View {
    let type: ToolbarOptionType
    let timeInterval: TimeInterval
    let placement: ListToolBarPlacement
    private let triangleWidth: CGFloat = 12
    private let trianglePadding: CGFloat = .padding16
    @State var internalShowTooltip: Bool = false
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @StateObject private var toolTipManager = ToolTipManager.shared
    init(type: ToolbarOptionType, placement: ListToolBarPlacement) {
        self.type = type
        self.timeInterval = type.timeIntervalForShowingAgain ?? .days(numberOfDays: 30)
        self.placement = placement
    }

    var body: some View {
        VStack {
            if internalShowTooltip == true {
                VStack(spacing: 0) {
                    HStack {
                        if placement == .trailing {
                            Spacer()
                        }
                        Triangle()
                            .fill(type.tooltipBackgroundColor)
                            .frame(width: triangleWidth, height: 6)
                            .padding(.horizontal, trianglePadding)
                        if placement == .leading {
                            Spacer()
                        }
                    }
                    content
                }
                .fixedSize()
                .transition(.scale(scale: 0, anchor: UnitPoint(x: 0.5, y: 1)).combined(with: .opacity))
                .offset(x: xOffset, y: yOffset)
                .onAppear {
                    Task {
                        try await Task.sleep(nanoseconds: 4_000_000_000)

                        if #available(iOS 17.0, *) {
                            withAnimation(.defaultSpring) {
                                internalShowTooltip = false
                            } completion: {
                                toolTipManager.removeTooltip(type)
                            }
                        } else {
                            withAnimation(.defaultSpring) {
                                internalShowTooltip = false
                            }
                            toolTipManager.removeTooltip(type)
                        }
                    }
                }
            }
        }
        .background {
            content
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                let imageSize = type.imageSize
                                if placement == .trailing {
                                    xOffset = -(proxy.size.width - imageSize) / 2 + (44 - imageSize) / 2
                                } else {
                                    xOffset = (proxy.size.width - imageSize) / 2 - (44 - imageSize) / 2
                                }
                                yOffset = imageSize + (40 - imageSize) / 2
                            }
                            .onChange(of: proxy.size) { value in
                                let imageSize = type.imageSize
                                if placement == .trailing {
                                    xOffset = -(value.width - imageSize) / 2 + (44 - imageSize) / 2
                                } else {
                                    xOffset = (value.width - imageSize) / 2 - (44 - imageSize) / 2
                                }
                                yOffset = imageSize + (40 - imageSize) / 2
                            }
                    }
                }
                .opacity(0)
        }
        .onAppear {
            Task {
                withAnimation(.defaultSpring.delay(type.delay)) {
                    internalShowTooltip = true
                }
            }
        }
    }

    var content: some View {
        hText(type.textToShow ?? "", style: .label)
            .padding(.horizontal, .padding12)
            .padding(.top, 6.5)
            .padding(.bottom, 7.5)
            .foregroundColor(type.tooltipTextColor)
            .background(type.tooltipBackgroundColor)
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
        TooltipView(type: .travelCertificate, placement: .trailing)
    }
}

@MainActor
class ToolTipManager: ObservableObject {

    static let shared = ToolTipManager()

    private init() {
    }
    @Published fileprivate var displayedTooltip: ToolbarOptionType?
    @Published private var toolTipsToShow: Set<ToolbarOptionType> = Set()

    func checkIfDisplayIsNeeded(_ tooltip: ToolbarOptionType) {
        if tooltip.shouldShowTooltip(for: tooltip.timeIntervalForShowingAgain ?? .days(numberOfDays: 30)) {
            toolTipsToShow.insert(tooltip)
            Task {
                try await Task.sleep(nanoseconds: 500_000_000)
                if let first = Array(toolTipsToShow).sorted(by: { $0.rawValue < $1.rawValue }).first {
                    presentTooltip(first)
                }
            }
        }
    }

    private func presentTooltip(_ tooltip: ToolbarOptionType) {
        if toolTipsToShow.contains(tooltip) {
            if self.displayedTooltip == nil {
                self.displayedTooltip = tooltip
            }
        }
    }

    fileprivate func removeTooltip(_ tooltip: ToolbarOptionType) {
        if displayedTooltip == tooltip {
            displayedTooltip = nil
            removeForType(type: tooltip)
            tooltip.onShow()
        }
        if let first = toolTipsToShow.first {
            presentTooltip(first)
        }
    }

    fileprivate func removeForType(type: ToolbarOptionType) {
        toolTipsToShow.remove(type)
        displayedTooltip = nil
    }
}
public enum ToolbarOptionType: Int, Hashable, Codable, Equatable, Sendable {
    case newOffer
    case newOfferNotification
    case firstVet
    case chat
    case chatNotification
    case travelCertificate
    case insuranceEvidence

    @MainActor
    var image: UIImage {
        switch self {
        case .newOffer:
            return hCoreUIAssets.campaignQuickNav.image
        case .firstVet:
            return hCoreUIAssets.firstVetQuickNav.image
        case .chat:
            return hCoreUIAssets.inbox.image
        case .chatNotification:
            return hCoreUIAssets.inboxNotification.image
        case .travelCertificate, .insuranceEvidence:
            return hCoreUIAssets.infoOutlined.image
        case .newOfferNotification:
            return hCoreUIAssets.campaignQuickNavNotification.image
        }
    }

    var displayName: String {
        switch self {
        case .newOffer:
            return L10n.InsuranceTab.CrossSells.title
        case .firstVet:
            return L10n.hcQuickActionsFirstvetTitle
        case .chat:
            return L10n.CrossSell.Info.faqChatButton
        case .chatNotification:
            return L10n.Toast.newMessage
        case .travelCertificate, .insuranceEvidence:
            return L10n.InsuranceEvidence.documentTitle
        case .newOfferNotification:
            return L10n.hcQuickActionsFirstvetTitle
        }
    }

    var tooltipId: String {
        switch self {
        case .newOffer:
            return "newOfferHint"
        case .newOfferNotification:
            return "newOfferHintNotification"
        case .firstVet:
            return "firstVetHint"
        case .chat:
            return "chatHint"
        case .chatNotification:
            return "chatHintNotification"
        case .travelCertificate:
            return "travelCertHint"
        case .insuranceEvidence:
            return "insuranceEvidenceHint"
        }
    }

    var identifiableId: String {
        tooltipId
    }

    var textToShow: String? {
        switch self {
        case .newOffer:
            return nil
        case .firstVet:
            return nil
        case .newOfferNotification:
            return L10n.Toast.newOffer
        case .chat:
            return L10n.HomeTab.chatHintText
        case .chatNotification:
            return L10n.Toast.newMessage
        case .travelCertificate, .insuranceEvidence:
            return L10n.Toast.readMore
        }
    }

    var showAsTooltip: Bool {
        switch self {
        case .firstVet, .chat, .newOffer:
            return false
        default:
            return true
        }
    }

    var timeIntervalForShowingAgain: TimeInterval? {
        switch self {
        case .chat:
            return .days(numberOfDays: 30)
        case .chatNotification:
            return 30
        case .travelCertificate, .insuranceEvidence:
            return 60
        case .newOfferNotification:
            return 30
        default:
            return nil
        }
    }

    var delay: TimeInterval {
        switch self {
        case .chat:
            return 1.5
        case .chatNotification, .travelCertificate, .insuranceEvidence:
            return 0.5
        default:
            return 0
        }
    }

    var delayInNanoseconds: UInt64 {
        return UInt64(delay * 1_000_000_000)  // Convert seconds to nanoseconds
    }

    func shouldShowTooltip(for timeInterval: TimeInterval) -> Bool {
        switch self {
        case .chat:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }

                return false
            }
            return true
        case .chatNotification:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }
                return false
            }
            return true
        case .travelCertificate, .insuranceEvidence:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }
                return false
            }
            return true

        case .newOfferNotification, .newOffer:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }
                return false
            }
            return true
        default:
            return false
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return 24
        default:
            return 40
        }
    }

    @hColorBuilder @MainActor
    var tooltipBackgroundColor: some hColor {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            hFillColor.Opaque.primary
        case .newOfferNotification:
            hSignalColor.Green.fill
        default:
            hFillColor.Opaque.secondary
        }
    }

    @hColorBuilder @MainActor
    var tooltipTextColor: some hColor {
        switch self {
        case .newOfferNotification:
            hSignalColor.Green.text
        default:
            hTextColor.Opaque.negative
        }
    }

    var shadowColor: Color {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return Color.clear
        default:
            return .black.opacity(0.15)
        }
    }

    func onShow() {
        switch self {
        case .chat:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .chatNotification:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .travelCertificate, .insuranceEvidence:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .newOfferNotification, .newOffer:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        default:
            break
        }
    }

    var userDefaultsKey: String {
        "tooltip_\(tooltipId)_past_date"
    }

}
