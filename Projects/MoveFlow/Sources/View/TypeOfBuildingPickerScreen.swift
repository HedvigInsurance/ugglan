import PresentableStore
import SwiftUI
import hCoreUI

struct TypeOfBuildingPickerScreen: View {
    var currentlySelected: ExtraBuildingType?
    @ObservedObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @ObservedObject var addExtraBuidlingViewModel: MovingFlowAddExtraBuildingViewModel
    let itemPickerConfig: ItemConfig<ExtraBuildingType>
    public init(
        currentlySelected: ExtraBuildingType?,
        movingFlowNavigationVm: MovingFlowNavigationViewModel,
        addExtraBuidlingViewModel: MovingFlowAddExtraBuildingViewModel
    ) {
        self.movingFlowNavigationVm = movingFlowNavigationVm
        self.currentlySelected = currentlySelected
        self.addExtraBuidlingViewModel = addExtraBuidlingViewModel
        self.itemPickerConfig = .init(
            items: {
                return movingFlowNavigationVm.movingFlowVm?.extraBuildingTypes
                    .compactMap({ (object: $0, displayName: .init(title: $0.translatedValue)) }) ?? []
            }(),
            preSelectedItems: {
                if let currentlySelected {
                    return [currentlySelected]
                }
                return []
            },
            onSelected: { selected in
                if let selected = selected.first {
                    movingFlowNavigationVm.isBuildingTypePickerPresented = nil
                    if let object = selected.0 {
                        addExtraBuidlingViewModel.buildingType = object
                    }
                }
            },
            onCancel: {
                movingFlowNavigationVm.isBuildingTypePickerPresented = nil
            },
            singleSelect: true,
            useAlwaysAttachedToBottom: true
        )
    }

    var body: some View {
        ItemPickerScreen<ExtraBuildingType>(
            config: itemPickerConfig
        )
    }
}

#Preview {
    TypeOfBuildingPickerScreen(
        currentlySelected: nil,
        movingFlowNavigationVm: .init(),
        addExtraBuidlingViewModel: .init()
    )
}
