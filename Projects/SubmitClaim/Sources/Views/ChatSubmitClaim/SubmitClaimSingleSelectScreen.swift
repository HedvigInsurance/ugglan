import SwiftUI
import hCore
import hCoreUI

struct SingleSelectValue: Hashable {
    let title: String
    let value: String
}

struct SubmitClaimSingleSelectScreen: View {
    @State var selectedItem: String?
    @ObservedObject var viewModel: SubmitClaimChatViewModel
    let itemPickerConfig: ItemConfig<SingleSelectValue>

    init(
        viewModel: SubmitClaimChatViewModel,
        values: [SingleSelectValue]
    ) {
        self.viewModel = viewModel

        itemPickerConfig = .init(
            items: values.compactMap { (object: $0, displayName: .init(title: $0.title)) },
            preSelectedItems: {

                if let value = values.first(where: { $0 == viewModel.selectedValue }) {
                    return [value]
                }
                return []
            },
            onSelected: { selectedValue in
                if let object = selectedValue.first?.0 {
                    viewModel.selectedValue = object
                }
                viewModel.isSelectItemPresented = nil
            },
            onCancel: {
                viewModel.isSelectItemPresented = nil
            }
        )
    }

    var body: some View {
        ItemPickerScreen<SingleSelectValue>(
            config: itemPickerConfig
        )
        .hItemPickerAttributes([.singleSelect])
        .hFormContentPosition(.compact)
        .navigationTitle(viewModel.currentStep?.text ?? "")
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })
    return LocationView(claimsNavigationVm: .init(), router: .init())
}
