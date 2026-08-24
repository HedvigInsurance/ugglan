import Chat
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class HelpCenterNavigationViewModel: ObservableObject {
    // Set by the deep-link handler before/after the help-center modal opens.
    // Consumed by `HelpCenterNavigation` via .task(id:) so the push runs after
    // the NavigationStack has mounted and registered its destination modifiers.
    @Published public var pendingPuppyGuideRoute: PuppyGuideRoute?
    public let quickActionsVm = QuickActionsViewModel()
    public let router = NavigationRouter()

    public init() {}
}

public enum HelpCenterNavigationRouterType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: InboxView.self)
    }

    case inbox
}

public enum PuppyGuideRoute: Hashable, TrackingViewNameProtocol {
    case list
    case article(storyName: String)

    public var nameForTracking: String {
        switch self {
        case .list: return "PuppyGuideList"
        case .article: return "PuppyGuideArticle"
        }
    }
}

private enum HelpCenterDetentRouterType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .startView:
            return .init(describing: HelpCenterStartView.self)
        }
    }

    case startView
}

public struct HelpCenterNavigation<Content: View>: View {
    @ObservedObject var helpCenterVm: HelpCenterNavigationViewModel
    @ViewBuilder var redirect: (_ type: HelpCenterRedirectType) -> Content

    public init(
        helpCenterVm: HelpCenterNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: HelpCenterRedirectType) -> Content
    ) {
        self.helpCenterVm = helpCenterVm
        self.redirect = redirect
    }

    public var body: some View {
        hNavigationStack(
            router: helpCenterVm.router,
            options: .extendedNavigationWidth,
            tracking: HelpCenterDetentRouterType.startView
        ) {
            HelpCenterStartView(
                onQuickAction: { quickAction in
                    helpCenterVm.quickActionsVm.perform(quickAction)
                }
            )
            .navigationTitle(L10n.hcTitle)
            .withDismissButton()
            .routerDestination(for: FAQModel.self) { question in
                HelpCenterQuestionView(question: question, router: helpCenterVm.router)
            }
            .routerDestination(for: FaqTopic.self) { topic in
                HelpCenterTopicView(topic: topic, router: helpCenterVm.router)
            }
            .routerDestination(for: HelpCenterNavigationRouterType.self) { _ in
                InboxView()
                    .navigationTitle(L10n.chatConversationInbox)
            }
            .routerDestination(for: PuppyGuideRoute.self) { [router = helpCenterVm.router] route in
                switch route {
                case .list:
                    PuppyGuideListHost(router: router)
                        .ignoresSafeArea()
                case let .article(storyName):
                    PuppyArticleHost(storyName: storyName, router: router)
                        .ignoresSafeArea()
                }
            }
            .task(id: helpCenterVm.pendingPuppyGuideRoute) { [weak helpCenterVm] in
                guard let helpCenterVm, let route = helpCenterVm.pendingPuppyGuideRoute else { return }
                helpCenterVm.router.popToRoot()
                helpCenterVm.router.push(route)
                helpCenterVm.pendingPuppyGuideRoute = nil
            }
        }
        .ignoresSafeArea()
        .handleQuickActions(with: helpCenterVm.quickActionsVm, redirect: redirect)
    }
}

#Preview {
    HelpCenterNavigation(helpCenterVm: .init(), redirect: { _ in })
}
