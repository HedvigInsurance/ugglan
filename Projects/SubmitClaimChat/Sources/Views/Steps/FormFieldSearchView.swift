import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct FormFieldSearchView: View {
    @StateObject private var vm: FormFieldSearchViewModel
    private let onSelected: (SingleSelectValue, _ searchInput: String) -> Void
    @EnvironmentObject var router: NavigationRouter

    init(model: FormFieldSearchModel, onSelected: @escaping (SingleSelectValue, _ searchInput: String) -> Void) {
        self._vm = StateObject(
            wrappedValue: .init(
                stepId: model.stepId,
                fieldId: model.id,
                suggestedQuery: model.suggestedQuery,
                modalTitle: model.modalTitle,
                modalSubtitle: model.modalSubtitle
            )
        )
        self.onSelected = onSelected
    }
    var body: some View {
        hForm {
            suggestionView
            if isProcessingLoading && vm.searchResults.isEmpty {
                DotsActivityIndicator(.standard)
                    .useDarkColor
                    .padding(.vertical, .padding16)
            }

            if case .error(let errorMessage) = vm.processingState {
                errorView(message: errorMessage)
            } else if vm.searchText.count < 2 {
                placeholderView
            } else if vm.noResults {
                emptyResults
            } else {
                resultsView
            }
        }
        .hFormAlwaysAttachToBottom {
            hSection {
                hCancelButton(.secondary) {
                    vm.searchController.dismiss(animated: false)
                    router.dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(
            isProcessingError
                || vm.searchText.count < 2 ? .center : .top
        )
        .animation(.default, value: vm.searchResults)
        .animation(.default, value: vm.processingState)
        .animation(.default, value: vm.noResults)
        .animation(.default, value: vm.suggestedQuery)
        .animation(.default, value: vm.searchController.searchBar.text)
        .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
            guard let vm else { return }
            vc.navigationItem.searchController = vm.searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
            vc.definesPresentationContext = false
            vm.activateSearch()
        }
        .dismissKeyboard()
    }
    private func errorView(message: String) -> some View {
        GenericErrorView(
            description: message,
            formPosition: nil
        )
    }

    private var placeholderView: some View {
        hSection {
            VStack(spacing: 0) {
                hText(vm.modalTitle)
                hText(vm.modalSubtitle)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .sectionContainerStyle(.transparent)
    }

    private var emptyResults: some View {
        hSection {
            VStack(spacing: .padding8) {
                VStack(spacing: 0) {
                    hText(L10n.claimChatFieldSearchNothingFound)
                }
            }
        }
        .multilineTextAlignment(.center)
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var suggestionView: some View {
        if let suggestedQuery = vm.suggestedQuery, !isProcessingLoading {
            Button {
                vm.searchController.searchBar.text = suggestedQuery
            } label: {
                HStack(spacing: .padding4) {
                    hText(L10n.claimChatFieldSearchSuggestion)
                        .foregroundColor(hTextColor.Translucent.secondary)
                    hText(suggestedQuery)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .underline()
                    hText("?")
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .padding(.bottom, .padding32)
        }
    }

    private var resultsView: some View {
        VStack(spacing: .padding6) {
            ForEach(vm.searchResults, id: \.value) { [weak vm] item in
                SingleSelectValueView(item: item) {
                    guard let vm else { return }
                    vm.searchController.dismiss(animated: false)
                    router.dismiss()
                    onSelected(item, vm.searchController.searchBar.text ?? "")
                }
                .accessibilityHint(L10n.voiceoverDoubleClickTo + " " + L10n.generalSelectButton)
            }
        }
        .padding(.bottom, .padding6)
    }

    // Computed helpers for pattern-matching ProcessingState
    private var isProcessingLoading: Bool {
        if case .loading = vm.processingState { return true }
        return false
    }

    private var isProcessingError: Bool {
        if case .error = vm.processingState { return true }
        return false
    }
}
@available(iOS 17.0, *)
#Preview {
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })
    return FormFieldSearchView(
        model: .init(
            id: "id",
            stepId: "stepId",
            title: "title",
            suggestedQuery: "iph",
            modalTitle: "Search for your item",
            modalSubtitle: "Start searching for the item relevant to your claim"
        ),
        onSelected: { _, _ in }
    )
    .navigationTitle("title")
    .embededInNavigation(tracking: "")
}
