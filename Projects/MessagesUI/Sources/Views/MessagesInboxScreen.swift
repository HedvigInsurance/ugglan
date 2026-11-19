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
            let sections = vm.sections
            if sections.isEmpty {
                StateView(type: .empty, title: vm.emptyStateTitle, bodyText: nil)
                    .padding(.vertical, .padding64)
            } else {
                VStack(alignment: .leading, spacing: .padding24) {
                    section(title: L10n.MessagesInbox.sectionUnread, messages: sections.unread)
                    section(title: L10n.MessagesInbox.sectionEarlier, messages: sections.earlier)
                }
            }
        }
    }

    @ViewBuilder
    private func section(title: String, messages: [InboxMessage]) -> some View {
        if !messages.isEmpty {
            VStack(alignment: .leading, spacing: .padding12) {
                hText(title, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .padding(.horizontal, .padding16 + .padding4)
                    .accessibilityAddTraits(.isHeader)
                MessagesCard {
                    VStack(spacing: 0) {
                        ForEach(messages) { message in
                            MessageRow(message: message) {
                                vm.open(message)
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
                        hText(message.category, style: .body1)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        trailingLabel
                    }
                    hText(message.subject, style: .body1)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    hText(message.preview, style: .label)
                        .foregroundColor(hTextColor.Translucent.primary)
                        .lineLimit(2)
                        .padding(.top, .padding8)
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

    @ViewBuilder
    private var trailingLabel: some View {
        if message.isRead {
            hText(message.listDateLabel, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
        } else {
            hText(L10n.MessagesInbox.newMessage, style: .label)
                .foregroundColor(hSignalColor.Blue.text)
                .padding(.vertical, .padding3)
                .padding(.horizontal, .padding6)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusXS)
                        .fill(hHighlightColor.Blue.fillTwo)
                }
        }
    }

    private var accessibilityText: String {
        let parts: [String?] = [
            message.isRead ? nil : L10n.MessagesInbox.sectionUnread,
            message.category,
            message.subject,
            message.preview,
            message.isRead ? message.listDateLabel : nil,
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

/// Skeleton of one section while the inbox loads.
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
