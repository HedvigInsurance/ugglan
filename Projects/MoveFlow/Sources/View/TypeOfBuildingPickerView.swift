import StoreContainer
import SwiftUI
import hCoreUI

struct TypeOfBuildingPickerView: View {
    var currentlySelected: ExtraBuildingType?
    @Binding var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

    public init(
        currentlySelected: ExtraBuildingType?,
        isBuildingTypePickerPresented: Binding<ExtraBuildingTypeNavigationModel?>
    ) {
        self.currentlySelected = currentlySelected
        self._isBuildingTypePickerPresented = isBuildingTypePickerPresented
    }

    var body: some View {
        ItemPickerScreen<ExtraBuildingType>(
            config: .init(
                items: {
                    let store: MoveFlowStore = globalPresentableStoreContainer.get()
                    return store.state.movingFlowModel?.extraBuildingTypes
                        .compactMap({ (object: $0, displayName: .init(title: $0.translatedValue)) }) ?? []
                }(),
                preSelectedItems: {
                    if let currentlySelected {
                        return [currentlySelected]
                    }
                    return []
                },
                onSelected: { selected in
                    let store: MoveFlowStore = globalPresentableStoreContainer.get()
                    if let selected = selected.first {
                        isBuildingTypePickerPresented = nil
                        if let object = selected.0 {
                            store.send(.setExtraBuildingType(with: object))
                        }
                    }
                },
                onCancel: {
                    isBuildingTypePickerPresented = nil
                },
                singleSelect: true
            )
        )
    }
}

#Preview{
    TypeOfBuildingPickerView(currentlySelected: nil, isBuildingTypePickerPresented: .constant(nil))
}
