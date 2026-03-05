import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct FormFieldSearchView: View {
    @StateObject private var vm: FormFieldSearchViewModel
    private let onSelected: ((SingleSelectValue, _ searchInput: String) -> Void)?
    @EnvironmentObject var router: Router

    init(model: SearchFieldModel, onSelected: @escaping (SingleSelectValue, _ searchInput: String) -> Void) {
        self._vm = StateObject(
            wrappedValue: .init(stepId: model.stepId, fieldId: model.id, suggestedQuery: model.suggestedQuery)
        )
        self.onSelected = onSelected
    }
    var body: some View {
        hForm {
            if isProcessingLoading && vm.searchResults.isEmpty {
                DotsActivityIndicator(.standard)
                    .useDarkColor
                    .padding(.vertical, .padding16)
            }
            if case .error(let errorMessage) = vm.processingState {
                errorView(message: errorMessage)
            } else if vm.searchText.count < 2 {
                notSearchState
            } else if vm.noResults {
                emptyResults
            } else {
                resultsView
            }
        }
        .hFormAlwaysAttachToBottom {
            hSection {
                hCancelButton(type: .secondary) {
                    router.dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(
            isProcessingError || vm.noResults
                || vm.searchText.count < 2 ? .center : .top
        )
        .animation(.default, value: vm.searchResults)
        .animation(.default, value: vm.processingState)
        .animation(.default, value: vm.selectedValue)
        .animation(.default, value: vm.isDebouncing)
        .animation(.default, value: vm.noResults)
        .animation(.default, value: vm.searchController.searchBar.text)
        .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
            guard let vm else { return }
            vc.navigationItem.searchController = vm.searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
            vc.definesPresentationContext = false
            vm.activateSearch()
        }
    }
    private func errorView(message: String) -> some View {
        GenericErrorView(
            description: message,
            formPosition: nil
        )
    }

    private var notSearchState: some View {
        hSection {
            VStack(spacing: 0) {
                hText("Fill in more details about your item")
                hText("Start searching for the item relevant to your claim")
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .sectionContainerStyle(.transparent)
    }

    private var emptyResults: some View {
        hSection {
            VStack(spacing: 0) {
                hText("No results")
                hText("Check your input or try searching with different keywords")
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .sectionContainerStyle(.transparent)
    }

    private var resultsView: some View {
        VStack(spacing: .padding4) {
            ForEach(vm.searchResults, id: \.title) { [unowned vm] result in
                hSection {
                    hRow {
                        hFieldTextContent<SingleSelectValue>(
                            item: .init(title: result.title, subTitle: result.subtitle),
                            fieldSize: .medium,
                            itemDisplayName: nil,
                            leftViewWithItem: nil,
                            leftView: nil,
                            cellView: nil
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelected?(result, vm.searchController.searchBar.text ?? "")
                        }
                    }
                    .withChevronAccessory
                    .hRowContentAlignment(.center)
                }
            }
        }
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

#Preview {
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })
    return FormFieldSearchView(
        model: .init(id: "id", stepId: "stepId", title: "title", suggestedQuery: "Iphone"),
        onSelected: { _, _ in }
    )
    .embededInNavigation(tracking: "")
}
