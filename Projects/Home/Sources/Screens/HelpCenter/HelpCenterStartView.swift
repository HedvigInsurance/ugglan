import AppStateContainer
import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct HelpCenterStartView: View {
    @State var vm = HelpCenterStartViewModel()
    @State private var puppyGuideDisplay: PuppyGuideEntryPlacement?
    @State private var puppyGuideCancellable: AnyCancellable?
    let onQuickAction: (QuickAction) -> Void
    @Environment(NavigationRouter.self) var router
    @InjectObservableObject var featureFlags: FeatureFlags

    public init(
        onQuickAction: @escaping (QuickAction) -> Void
    ) {
        self.onQuickAction = onQuickAction
    }

    private var showsFullPuppyGuideCard: Bool {
        featureFlags.isPuppyGuideEnabled && puppyGuideDisplay == .fullCard
    }

    private var showsPuppyGuideQuickActionRow: Bool {
        featureFlags.isPuppyGuideEnabled && puppyGuideDisplay == .quickAction
    }

    public var body: some View {
        hForm {
            VStack(spacing: 0) {
                hSection {
                    VStack(alignment: .leading, spacing: 0) {
                        if vm.searchInProgress {
                            VStack(spacing: 40) {
                                displayQuickActions(from: vm.searchResultsQuickActions)
                                if !vm.searchResultsQuestions.isEmpty {
                                    QuestionsItems(
                                        questions: vm.searchResultsQuestions,
                                        questionType: .searchQuestions,
                                        source: .homeView
                                    )
                                }
                            }
                            .padding(.top, 20)
                        } else {
                            ZStack {
                                if showsFullPuppyGuideCard {
                                    puppyGuideEntry
                                        .transition(.opacity)
                                } else {
                                    HStack {
                                        Spacer()
                                        hCoreUIAssets.bigPillowBlack.view
                                            .resizable()
                                            .frame(width: 160, height: 160)
                                            .padding(.bottom, 26)
                                            .padding(.top, 39)
                                        Spacer()
                                    }
                                    .accessibilityHidden(true)
                                    .transition(.opacity)
                                }
                            }
                            .animation(.smooth, value: showsFullPuppyGuideCard)
                            .padding(.top, 24)
                            .padding(.bottom, 48)
                            VStack(alignment: .leading, spacing: .padding8) {
                                hText(L10n.hcHomeViewQuestion)
                                hText(L10n.hcHomeViewAnswer)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            .padding(.bottom, 40)
                            displayQuickActions(
                                from: vm.quickActions,
                                showPuppyGuideRow: showsPuppyGuideQuickActionRow
                            )
                            .padding(.bottom, 40)
                            displayTopics()
                                .padding(.bottom, 40)
                            if let helpCenterModel = vm.helpCenterModel {
                                QuestionsItems(
                                    questions: helpCenterModel.commonQuestions,
                                    questionType: .commonQuestions,
                                    source: .homeView
                                )
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                if !vm.searchInProgress {
                    SupportView(router: router)
                        .padding(.top, .padding40)
                }
            }
        }
        .hFormBottomBackgroundColor(
            vm.searchInProgress
                ? .default : .gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary)
        )
        .dismissKeyboard()
        .introspect(.viewController, on: .iOS(.v17...)) { [weak vm] vc in
            guard let vm else { return }

            if !vm.didSetInitialSearchAppearance {
                vc.navigationItem.hidesSearchBarWhenScrolling = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak vc] in
                    vc?.navigationItem.hidesSearchBarWhenScrolling = true
                }
                vm.didSetInitialSearchAppearance = true
            }

            vc.navigationItem.searchController = vm.searchController
            vc.definesPresentationContext = true
            vm.updateColors()
        }
        // Only resolve the client while the guide is enabled: demo mode, previews and tests disable the flag and
        // don't have to register a PuppyGuideClient.
        .task(id: featureFlags.isPuppyGuideEnabled) {
            puppyGuideCancellable?.cancel()
            puppyGuideCancellable = nil
            guard featureFlags.isPuppyGuideEnabled else { return }
            let client: PuppyGuideClient = Dependencies.shared.resolve()
            puppyGuideCancellable = client.observeEntryPlacement { puppyGuideDisplay = $0 }
        }
        .onDisappear {
            puppyGuideCancellable?.cancel()
            puppyGuideCancellable = nil
        }
    }

    private var puppyGuideEntry: some View {
        CardView {
            ZStack(alignment: .topLeading) {
                hCoreUIAssets.hundarBadarPet.view
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 182)
                    .clipped()
                    .accessibilityHidden(true)
                hPill(text: L10n.puppyGuideLabel, color: .pink)
                    .hFieldSize(.small)
                    .padding(.padding16)
            }
            VStack(alignment: .leading, spacing: .padding16) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.puppyGuideTitle)
                    hText(L10n.puppyGuideSubtitle)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .accessibilityElement(children: .combine)
                hButton(.medium, .ghost, content: hButtonContent(title: L10n.puppyGuideGoButton)) {
                    router.push(PuppyGuideRoute.list)
                }
                .hButtonWithBorder
                .hButtonTakeFullWidth(true)
            }
            .padding(.padding16)
        }
        .hWithoutHorizontalPadding([.section])
        .onTapGesture { router.push(PuppyGuideRoute.list) }
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    func displayQuickActions(from quickActions: [QuickAction], showPuppyGuideRow: Bool = false) -> some View {
        if !quickActions.isEmpty || showPuppyGuideRow {
            VStack(alignment: .leading, spacing: .padding4) {
                HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                    .padding(.bottom, .padding4)

                ForEach(quickActions, id: \.displayTitle) { [onQuickAction] quickAction in
                    QuickActionView(quickAction: quickAction) {
                        onQuickAction(quickAction)
                    }
                }
                if showPuppyGuideRow {
                    PuppyGuideQuickActionRow {
                        router.push(PuppyGuideRoute.list)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func displayTopics() -> some View {
        if let helpCenterModel = vm.helpCenterModel {
            VStack(alignment: .leading, spacing: .padding8) {
                HelpCenterPill(title: L10n.hcCommonTopicsTitle, color: .yellow)
                topicsItems(topics: helpCenterModel.topics)
            }
        }
    }

    private func topicsItems(topics: [FaqTopic]) -> some View {
        VStack(spacing: .padding4) {
            ForEach(topics, id: \.self) { item in
                hSection {
                    hRow {
                        hText(item.title)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        router.push(item)
                    }
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.opaque)
            }
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return HelpCenterStartView(
        onQuickAction: { _ in
        }
    )
    .environment(NavigationRouter())
}
