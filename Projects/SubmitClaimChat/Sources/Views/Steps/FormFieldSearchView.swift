import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct FormFieldSearchView: View {
    @ObservedObject var viewModel: FormFieldSearchViewModel
    let onSelected: (SingleSelectValue) -> Void
    let onCancel: () -> Void

    var body: some View {
        content
            .introspect(.viewController, on: .iOS(.v13...)) { [weak viewModel] vc in
                guard let viewModel else { return }
                vc.navigationItem.searchController = viewModel.searchController
                vc.navigationItem.hidesSearchBarWhenScrolling = false
                vc.definesPresentationContext = true
            }
    }

    @ViewBuilder
    private var content: some View {
        //        if viewModel.isLoading {
        //            loadingView
        //        } else if !viewModel.searchResults.isEmpty {
        //            resultsView
        //        } else if viewModel.searchInProgress {
        //            emptyStateView
        //        } else {
        //            initialView
        //        }
        if !viewModel.searchResults.isEmpty {
            resultsView
        } else if viewModel.searchInProgress {
            emptyStateView
        } else {
            initialView
        }
    }

    private var resultsView: some View {
        ItemPickerScreen<SingleSelectValue>(
            config: .init(
                items: viewModel.searchResults.map {
                    ($0, ItemModel(title: $0.title, subTitle: $0.subtitle))
                },
                preSelectedItems: { [] },
                onSelected: { values in
                    if let selected = values.first?.0 {
                        onSelected(selected)
                    }
                },
                onCancel: onCancel,
                returnValueOnSelection: false
            )
        )
        .hItemPickerAttributes([.singleSelect, .alwaysAttachToBottom])
    }

    private var emptyStateView: some View {
        hForm {
            hSection {
                HStack {
                    Spacer()
                    // TODO: Add proper L10n key for "No results found"
                    hText("No results found")
                        .foregroundColor(hTextColor.Translucent.secondary)
                    Spacer()
                }
                .padding(.padding16)
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAlwaysAttachToBottom {
            bottomButtons(confirmEnabled: false)
        }
    }

    private var initialView: some View {
        hForm {}
            .hFormAlwaysAttachToBottom {
                bottomButtons(confirmEnabled: false)
            }
    }

    private func bottomButtons(confirmEnabled: Bool) -> some View {
        hSection {
            VStack(spacing: .padding16) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.generalSaveButton)
                ) {}
                .disabled(!confirmEnabled)
                hCancelButton {
                    onCancel()
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, .padding16)
    }
}
