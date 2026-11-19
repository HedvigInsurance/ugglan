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
            if vm.powerOfAttorneys.isEmpty {
                StateView(
                    type: .empty,
                    // TODO: Localize via Lokalise
                    title: "No power of attorney",
                    // TODO: Localize via Lokalise
                    bodyText: "You haven't shared a power of attorney with anyone"
                )
                .hStateViewButtonConfig(nil)
            } else {
                if !vm.powerOfAttorneys.isEmpty {
                    hSection(vm.powerOfAttorneys) { powerOfAttorney in
                        PowerOfAttorneyRow(powerOfAttorney: powerOfAttorney)
                    }
                    .sectionContainerStyle(.transparent)
                    .hWithoutHorizontalPadding([.row, .divider])
                }
            }
        }
        .hFormAlwaysAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    // TODO: Localize via Lokalise
                    content: .init(title: "Add power of attorney")
                ) {
                    isAddPowerOfAttorneyPresented = true
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)
        }
        .hFormContentPosition(vm.powerOfAttorneys.isEmpty ? .center : .top)
        .hSetScrollBounce(to: true)
        .onPullToRefresh { [vm] in
            await vm.fetchPowerOfAttorneys()
        }
    }
}

private struct PowerOfAttorneyRow: View {
    let powerOfAttorney: PowerOfAttorney
    // Shared with the share button, so tapping anywhere on the row opens the share popover anchored to the button
    @State private var sharePresenter = ShareSheetPopoverPresenter()

    var body: some View {
        hRow {
            VStack(spacing: .padding4) {
                HStack(alignment: .top, spacing: .padding8) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(powerOfAttorney.name)
                        hText(powerOfAttorney.ssn, style: .label)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    Spacer()
                    hPill(text: powerOfAttorney.level.displayName, color: .blue)
                        .hFieldSize(.small)
                }
                if let shareUrl = powerOfAttorney.shareUrl {
                    // TODO: Localize "Share" via Lokalise
                    PopoverShareButton(
                        url: shareUrl,
                        title: "Share",
                        size: .small,
                        type: .secondary,
                        presenter: sharePresenter
                    )
                    .hButtonTakeFullWidth(true)
                    // The whole row is the share button for VoiceOver, so the inner button isn't a separate element
                    .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
        }
        .onTap(if: powerOfAttorney.shareUrl != nil) { [sharePresenter, shareUrl = powerOfAttorney.shareUrl] in
            if let shareUrl {
                sharePresenter.present(url: shareUrl)
            }
        }
        // TODO: Localize via Lokalise
        .accessibilityHint(powerOfAttorney.shareUrl != nil ? "Shares the power of attorney link" : "")
    }
}

@MainActor
@Observable
final class PowerOfAttorneyListViewModel {
    var powerOfAttorneys: [PowerOfAttorney] = []
    var viewState: ProcessingState = .loading
    @ObservationIgnored private let service = PowerOfAttorneyService()
    @ObservationIgnored private var hasLoaded = false

    func fetchPowerOfAttorneys() async {
        // Only show the full screen loader on the first load, refreshes keep the current list visible.
        if !hasLoaded {
            withAnimation { viewState = .loading }
        }
        do {
            let powerOfAttorneys = try await service.getPowerOfAttorneys()
            hasLoaded = true
            withAnimation {
                self.powerOfAttorneys = powerOfAttorneys
                viewState = .success
            }
        } catch {
            withAnimation { viewState = .error(errorMessage: error.localizedDescription) }
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PowerOfAttorneyClient in PowerOfAttorneyClientDemo() })
    return PowerOfAttorneyListScreen()
}
