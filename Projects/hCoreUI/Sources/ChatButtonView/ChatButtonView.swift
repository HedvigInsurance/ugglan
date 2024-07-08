import Foundation
import SwiftUI
import hCore

extension hForm {
    public func setHomeNavigationBars(
        with options: Binding<[ToolbarOptionType]>,
        action: @escaping (_: ToolbarOptionType) -> Void
    ) -> some View {
        ModifiedContent(content: self, modifier: ToolbarButtonsViewModifier(action: action, types: options))
    }
}

public enum ToolbarOptionType: Codable, Equatable {
    case newOffer
    case firstVet
    case chat
    case chatNotification(lastMessageTimeStamp: Date?)

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
        }
    }

    var tooltipId: String {
        switch self {
        case .newOffer:
            return "newOfferHint"
        case .firstVet:
            return "firstVetHint"
        case .chat:
            return "chatHint"
        case .chatNotification:
            return "chatHintNotification"
        }
    }

    var identifiableId: String {
        switch self {
        case .newOffer:
            return tooltipId
        case .firstVet:
            return tooltipId
        case .chat:
            return tooltipId
        case .chatNotification(let lastMessageTimeStamp):
            return "\(tooltipId)\(lastMessageTimeStamp)"
        }
    }

    var textToShow: String? {
        switch self {
        case .newOffer:
            return nil
        case .firstVet:
            return nil
        case .chat:
            return L10n.HomeTab.chatHintText
        case .chatNotification:
            return L10n.Toast.newMessage
        }
    }

    var showAsTooltip: Bool {
        switch self {
        case .newOffer:
            return false
        case .firstVet:
            return false
        case .chat:
            return true
        case .chatNotification:
            return true
        }
    }

    var timeIntervalForShowingAgain: TimeInterval? {
        switch self {
        case .newOffer:
            return nil
        case .firstVet:
            return nil
        case .chat:
            return .days(numberOfDays: 30)
        case .chatNotification:
            return 5
        }
    }

    var delay: TimeInterval {
        switch self {
        case .newOffer:
            return 0
        case .firstVet:
            return 0
        case .chat:
            return 1.5
        case .chatNotification:
            return 0.5
        }
    }

    func shouldShowTooltip(for timeInterval: TimeInterval) -> Bool {
        switch self {
        case .newOffer:
            return false
        case .firstVet:
            return false
        case .chat:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    onShow()
                    return true
                }

                return false
            }
            onShow()
            return true
        case .chatNotification(let lastMessageTimeStamp):
            guard let lastMessageTimeStamp else { return false }
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                if pastDate < lastMessageTimeStamp {
                    onShow()
                    return true
                }
                return false
            }
            onShow()
            return true
        }
    }

    func onShow() {
        switch self {
        case .newOffer:
            break
        case .firstVet:
            break
        case .chat:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .chatNotification(let lastMessageTimeStamp):
            UserDefaults.standard.setValue(lastMessageTimeStamp, forKey: userDefaultsKey)
        }

    }

    var userDefaultsKey: String {
        "tooltip_\(tooltipId)_past_date"
    }

}

struct ToolbarButtonsView: View {
    @State var displayTooltip = false
    var action: ((_: ToolbarOptionType)) -> Void
    @Binding var types: [ToolbarOptionType]

    init(
        types: Binding<[ToolbarOptionType]>,
        action: @escaping (_: ToolbarOptionType) -> Void
    ) {
        self._types = types
        self.action = action
    }

    var body: some View {
        HStack(spacing: -8) {

            ForEach(Array(types.enumerated()), id: \.element.identifiableId) { index, type in
                VStack {
                    withAnimation(nil) {
                        SwiftUI.Button(action: {
                            withAnimation(.spring()) {
                                displayTooltip = false
                            }
                            action(type)
                        }) {
                            Image(uiImage: type.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                        }
                    }
                }
                .background(
                    VStack {
                        if type.showAsTooltip {
                            TooltipView(
                                displayTooltip: $displayTooltip,
                                type: type,
                                timeInterval: type.timeIntervalForShowingAgain ?? .days(numberOfDays: 30)
                            )
                            .position(x: 26, y: 55)
                            .fixedSize()
                        }
                    }
                )
            }
        }
    }
}

struct ToolbarButtonsViewModifier: ViewModifier {
    let action: (_: ToolbarOptionType) -> Void
    @Binding var types: [ToolbarOptionType]
    func body(content: Content) -> some View {
        content
            .navigationBarItems(
                trailing:
                    ToolbarButtonsView(types: $types, action: action)
            )
    }
}

extension TimeInterval {
    public static func days(numberOfDays: Int) -> TimeInterval {
        Double(numberOfDays) * 24 * 60 * 60
    }

}
