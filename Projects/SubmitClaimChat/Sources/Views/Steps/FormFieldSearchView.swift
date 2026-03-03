import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct FormFieldSearchView: View {
    @StateObject private var vm: FormFieldSearchViewModel
    private let onSelected: ((SingleSelectValue) -> Void)?
    @EnvironmentObject var router: Router

    init(model: SearchFieldModel, onSelected: @escaping (SingleSelectValue) -> Void) {
        self._vm = StateObject(wrappedValue: .init(stepId: model.stepId, fieldId: model.id))
        self.onSelected = onSelected
    }

    var body: some View {
        hForm {
            if let errorMessage = vm.errorMessage {
                errorView(message: errorMessage)
            } else if !vm.searchInProgress {
                notSearchState
            } else if vm.searchResults.isEmpty {
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
        .hFormContentPosition(!vm.searchInProgress || vm.errorMessage != nil ? .center : .top)
        .animation(.default, value: vm.searchInProgress)
        .animation(.default, value: vm.searchResults)
        .animation(.default, value: vm.errorMessage)
        .animation(.default, value: vm.selectedValue)
        .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
            guard let vm else { return }
            vc.navigationItem.searchController = vm.searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
            vc.definesPresentationContext = true
        }
    }
    private func errorView(message: String) -> some View {
        GenericErrorView(
            description: message,
            formPosition: nil
        )
        .transition(.opacity)
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
        .transition(.opacity)
    }

    private var emptyResults: some View {
        hText("No results")
            .transition(.opacity)
    }

    private var resultsView: some View {
        VStack(spacing: .padding4) {
            ForEach(vm.searchResults, id: \.title) { result in
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
                            onSelected?(result)
                        }
                    }
                    .withChevronAccessory
                    .hRowContentAlignment(.center)
                }
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })
    return FormFieldSearchView(
        model: .init(id: "id", stepId: "stepId", title: "title"),
        onSelected: { _ in }
    )
    .embededInNavigation(tracking: "")
}
