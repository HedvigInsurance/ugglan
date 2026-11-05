import Chat
import Payment
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
public class HelpCenterNavigationViewModel {
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

private enum HelpCenterDetentRouterType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .startView:
            return .init(describing: HelpCenterStartView.self)
        }
    }

    case startView
}

private struct PaymentMethodsFromQuickActions: ViewModifier {
    @Bindable var vm: QuickActionsViewModel

    func body(content: Content) -> some View {
        content.handlePaymentMethods(presented: $vm.isPaymentsPresented)
    }
}

public struct HelpCenterNavigation<Content: View>: View {
    let helpCenterVm: HelpCenterNavigationViewModel

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
            .modifier(PaymentMethodsFromQuickActions(vm: helpCenterVm.quickActionsVm))
        }
        .ignoresSafeArea()
        .handleQuickActions(with: helpCenterVm.quickActionsVm, redirect: redirect)
    }
}

#Preview {
    HelpCenterNavigation(helpCenterVm: .init(), redirect: { _ in })
}
