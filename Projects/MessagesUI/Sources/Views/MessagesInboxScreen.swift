import AppStateContainer
import MessagesCore
import SwiftUI
import hCore
import hCoreUI

struct MessagesInboxScreen: View {
    @State private var vm = MessagesInboxViewModel()
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        MessagesScreenLayout(title: L10n.MessagesInbox.title) {
            ToolbarItem(placement: .topBarTrailing) {
                MessagesFilterToolbarButton(kind: .type, vm: vm)
            }
            if #available(iOS 26.0, *) {
                // Keeps the two filters as separate glass circles instead of one shared capsule.
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            ToolbarItem(placement: .topBarTrailing) {
                MessagesFilterToolbarButton(kind: .date, vm: vm)
            }
        } content: {
            content
                .padding(.bottom, .padding32)
        }
        .task { await vm.load() }
        .sheet(isPresented: $vm.isFilterSheetPresented) {
            MessagesFilterSheet(selection: vm.filter) { vm.filter = $0 }
        }
        .sheet(isPresented: $vm.isDateSheetPresented) {
            MessagesDateFilterSheet(selection: vm.dateRange) { vm.applyDateRange($0) }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .notLoaded, .loading:
            MessagesLoadingView()
        case let .failed(errorMessage):
            GenericErrorView(description: errorMessage, formPosition: nil)
                .hStateViewButtonConfig(
                    .init(actionButton: .init { Task { await vm.load() } })
                )
                .padding(.vertical, .padding64)
        case .loaded:
            let messages = vm.list.messages
            if messages.isEmpty {
                StateView(type: .empty, title: vm.emptyStateTitle, bodyText: nil)
                    .padding(.vertical, .padding64)
            } else {
                MessagesCard {
                    VStack(spacing: 0) {
                        ForEach(messages) { message in
                            MessageRow(message: message) {
                                router.push(MessagesRouterAction.message(id: message.id))
                            }
                            if message.id != messages.last?.id {
                                MessageRowDivider()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MessageRow: View {
    let message: InboxMessage
    let onTap: () -> Void

    var body: some View {
        SwiftUI.Button(action: onTap) {
            HStack(alignment: .top, spacing: .padding12) {
                HedvigAvatar()
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: .padding8) {
                        hText(message.channel.title, style: .body1)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        hText(message.listDateLabel, style: .label)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    if let subject = message.subject {
                        hText(subject, style: .body1)
                            .foregroundColor(hTextColor.Translucent.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let preview = message.preview {
                        hText(preview, style: .label)
                            .foregroundColor(hTextColor.Translucent.primary)
                            .lineLimit(2)
                            .padding(.top, .padding8)
                    }
                }
                .multilineTextAlignment(.leading)
            }
            .padding(.padding16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityText: String {
        let parts: [String?] = [
            message.channel.title,
            message.subject,
            message.preview,
            message.listDateLabel,
        ]
        return parts.compactMap { $0 }.joined(separator: ", ")
    }
}

/// Inset to start under the text, not under the avatar.
private struct MessageRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(hBorderColor.primary)
            .frame(height: 1)
            .padding(.leading, .padding16 + .padding40 + .padding12)
            .padding(.trailing, .padding16)
            .accessibilityHidden(true)
    }
}

/// Skeleton of the list while the inbox loads.
private struct MessagesLoadingView: View {
    private let placeholder = MessagesClientDemo.sampleMessages().first

    var body: some View {
        if let placeholder {
            MessagesCard {
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { index in
                        MessageRow(message: placeholder, onTap: {})
                        if index < 2 { MessageRowDivider() }
                    }
                }
            }
            .redacted(reason: .placeholder)
            .modifier(Shimmer())
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

@MainActor private func setUpPreview() {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> MessagesClient in MessagesClientDemo() })
}

#Preview("Light") {
    setUpPreview()
    return hNavigationStack(router: NavigationRouter(), tracking: "MessagesPreview") {
        MessagesInboxScreen()
            .messagesRouterDestinations()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    setUpPreview()
    return hNavigationStack(router: NavigationRouter(), tracking: "MessagesPreview") {
        MessagesInboxScreen()
            .messagesRouterDestinations()
    }
    .preferredColorScheme(.dark)
}
