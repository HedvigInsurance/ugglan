import PowerOfAttorneyCore
import SwiftUI
import hCore
import hCoreUI

public struct PowerOfAttorneyListScreen: View {
    @State private var vm = PowerOfAttorneyListViewModel()
    @State private var isAddPowerOfAttorneyPresented = false

    public init() {}

    public var body: some View {
        content
            .loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: { [vm] in
                        Task { await vm.fetchPowerOfAttorneys() }
                    }),
                    dismissButton: nil
                )
            )
            .onAppear { [vm] in
                Task { await vm.fetchPowerOfAttorneys() }
            }
            .detent(presented: $isAddPowerOfAttorneyPresented, presentationStyle: .detent(style: [.large])) {
                PowerOfAttorneyNavigation()
            }
            .onChange(of: isAddPowerOfAttorneyPresented) { [vm] _, isPresented in
                // Refresh the list when the add flow closes, a new power of attorney may have been signed
                if !isPresented {
                    Task { await vm.fetchPowerOfAttorneys() }
                }
            }
    }

    private var content: some View {
        hForm {
            if vm.isEmpty {
                StateView(
                    type: .empty,
                    // TODO: Localize via Lokalise
                    title: "No power of attorney",
                    // TODO: Localize via Lokalise
                    bodyText: "You haven't shared or received a power of attorney"
                )
                .hStateViewButtonConfig(nil)
            } else {
                VStack(spacing: .padding16) {
                    if !vm.powerOfAttorneys.isEmpty {
                        hSection(vm.powerOfAttorneys) { powerOfAttorney in
                            PowerOfAttorneyRow(
                                powerOfAttorney: powerOfAttorney,
                                isRevoking: vm.revokingIds.contains(powerOfAttorney.id)
                            ) { [vm] in
                                Task { await vm.revoke(powerOfAttorney) }
                            }
                        }
                        // TODO: Localize via Lokalise
                        .withHeader(title: "Access granted to")
                        .sectionContainerStyle(.opaque)
                    }
                    if !vm.receivedPowerOfAttorneys.isEmpty {
                        hSection(vm.receivedPowerOfAttorneys) { powerOfAttorney in
                            ReceivedPowerOfAttorneyRow(powerOfAttorney: powerOfAttorney)
                        }
                        // TODO: Localize via Lokalise
                        .withHeader(title: "Switch to")
                        .sectionContainerStyle(.opaque)
                    }
                }
            }
        }
        .hFormAlwaysAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    // TODO: Localize via Lokalise
                    content: .init(title: "Grant access")
                ) {
                    isAddPowerOfAttorneyPresented = true
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)
        }
        .hFormContentPosition(vm.isEmpty ? .center : .top)
        .hSetScrollBounce(to: true)
        .onPullToRefresh { [vm] in
            await vm.fetchPowerOfAttorneys()
        }
    }
}

private struct PowerOfAttorneyRow: View {
    let powerOfAttorney: PowerOfAttorney
    let isRevoking: Bool
    let onRevoke: () -> Void
    // Tapping the row opens the share popover anchored to the row itself
    @State private var sharePresenter = ShareSheetPopoverPresenter()
    @State private var isRevokeAlertPresented = false

    var body: some View {
        hRow {
            HStack(alignment: .top, spacing: .padding8) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(powerOfAttorney.name)
                    HStack(spacing: .padding4) {
                        hText(powerOfAttorney.ssn, style: .label)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                }
                Spacer()
                HStack {
                    hPill(text: powerOfAttorney.level.displayName, color: .blue)
                        .hFieldSize(.small)
                    Button {
                        isRevokeAlertPresented = true
                    } label: {
                        hCoreUIAssets.trash.view
                            .resizable()
                            .frame(width: .padding16, height: .padding16)
                            .foregroundColor(hTextColor.Opaque.white)
                            // Square as tall as the pill next to it
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.padding4)
                            .background(hSignalColor.Red.element)
                            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusS))
                    }
                    .disabled(isRevoking)
                    // TODO: Localize via Lokalise
                    .accessibilityLabel("Revoke")
                    .fixedSize(horizontal: true, vertical: true)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityHidden(powerOfAttorney.shareUrl != nil)
        }
        .onTap(if: powerOfAttorney.shareUrl != nil) { [sharePresenter, shareUrl = powerOfAttorney.shareUrl] in
            if let shareUrl {
                sharePresenter.present(url: shareUrl)
            }
        }
        .shareSheetPopoverAnchor(sharePresenter)
        // TODO: Localize via Lokalise
        .accessibilityHint(powerOfAttorney.shareUrl != nil ? "Shares the power of attorney link" : "")
        // TODO: Localize via Lokalise
        .accessibilityAction(named: "Revoke") {
            if !isRevoking {
                isRevokeAlertPresented = true
            }
        }
        // TODO: Localize via Lokalise
        .alert("Revoke power of attorney?", isPresented: $isRevokeAlertPresented) {
            Button(L10n.generalCancelButton, role: .cancel) {}
            // TODO: Localize via Lokalise
            Button("Revoke", role: .destructive) {
                onRevoke()
            }
        } message: {
            // TODO: Localize via Lokalise
            Text("\(powerOfAttorney.name) will no longer be able to log in with this power of attorney.")
        }
    }
}

private struct ReceivedPowerOfAttorneyRow: View {
    let powerOfAttorney: ReceivedPowerOfAttorney

    var body: some View {
        hRow {
            HStack(alignment: .top, spacing: .padding8) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(powerOfAttorney.name)
                }
                Spacer()
                hPill(text: powerOfAttorney.level.displayName, color: .blue)
                    .hFieldSize(.small)
                hCoreUIAssets.arrowNorthEast.view
            }
            .accessibilityElement(children: .combine)
        }
        .onTap(if: powerOfAttorney.loginUrl != nil) { [loginUrl = powerOfAttorney.loginUrl] in
            // Same flow as opening a shared power of attorney link: asks to log out, then opens the BankID login
            if let loginUrl {
                NotificationCenter.default.post(name: .openDeepLink, object: loginUrl)
            }
        }
        // TODO: Localize via Lokalise
        .accessibilityHint(powerOfAttorney.loginUrl != nil ? "Logs in with the power of attorney" : "")
    }
}

@MainActor
@Observable
final class PowerOfAttorneyListViewModel {
    var powerOfAttorneys: [PowerOfAttorney] = []
    var receivedPowerOfAttorneys: [ReceivedPowerOfAttorney] = []
    var viewState: ProcessingState = .loading
    /// Ids of the powers of attorney being revoked, their revoke buttons are disabled
    var revokingIds = Set<String>()
    @ObservationIgnored private let service = PowerOfAttorneyService()
    @ObservationIgnored private var hasLoaded = false

    var isEmpty: Bool {
        powerOfAttorneys.isEmpty && receivedPowerOfAttorneys.isEmpty
    }

    func fetchPowerOfAttorneys() async {
        // Only show the full screen loader on the first load, refreshes keep the current list visible.
        if !hasLoaded {
            withAnimation { viewState = .loading }
        }
        do {
            async let powerOfAttorneys = service.getPowerOfAttorneys()
            async let receivedPowerOfAttorneys = service.getReceivedPowerOfAttorneys()
            let (granted, received) = try await (powerOfAttorneys, receivedPowerOfAttorneys)
            hasLoaded = true
            withAnimation {
                self.powerOfAttorneys = granted
                self.receivedPowerOfAttorneys = received
                viewState = .success
            }
        } catch {
            withAnimation { viewState = .error(errorMessage: error.localizedDescription) }
        }
    }

    func revoke(_ powerOfAttorney: PowerOfAttorney) async {
        guard revokingIds.insert(powerOfAttorney.id).inserted else { return }
        defer { revokingIds.remove(powerOfAttorney.id) }
        do {
            try await service.revokePowerOfAttorney(id: powerOfAttorney.id)
            withAnimation {
                powerOfAttorneys.removeAll { $0.id == powerOfAttorney.id }
            }
        } catch {
            // Keep the list visible, a failed revoke only needs a message
            Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PowerOfAttorneyClient in PowerOfAttorneyClientDemo() })
    return PowerOfAttorneyListScreen()
}
