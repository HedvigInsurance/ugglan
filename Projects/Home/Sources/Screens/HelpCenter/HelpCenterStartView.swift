import AppStateContainer
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct HelpCenterStartView: View {
    @State var vm = HelpCenterStartViewModel()
    let onQuickAction: (QuickAction) -> Void
    @Environment(NavigationRouter.self) var router

    public init(
        onQuickAction: @escaping (QuickAction) -> Void
    ) {
        self.onQuickAction = onQuickAction
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
                            .padding(.top, 24)
                            .padding(.bottom, 48)
                            VStack(alignment: .leading, spacing: .padding8) {
                                hText(L10n.hcHomeViewQuestion)
                                hText(L10n.hcHomeViewAnswer)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            .padding(.bottom, 40)
                            displayQuickActions(from: vm.quickActions)
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
    }

    @ViewBuilder
    func displayQuickActions(from quickActions: [QuickAction]) -> some View {
        if !quickActions.isEmpty {
            VStack(alignment: .leading, spacing: .padding4) {
                HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                    .padding(.bottom, .padding4)

                ForEach(quickActions, id: \.displayTitle) { [onQuickAction] quickAction in
                    QuickActionView(quickAction: quickAction) {
                        onQuickAction(quickAction)
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
