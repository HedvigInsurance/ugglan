import SwiftUI
import hCoreUI

struct TypeOfBuildingPickerScreen: View {
    @ObservedObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @ObservedObject var addExtraBuidlingViewModel: MovingFlowAddExtraBuildingViewModel
    let itemPickerConfig: ItemConfig<ExtraBuildingType>
    init(
        currentlySelected: ExtraBuildingType?,
        movingFlowNavigationVm: MovingFlowNavigationViewModel,
        addExtraBuidlingViewModel: MovingFlowAddExtraBuildingViewModel
    ) {
        self.movingFlowNavigationVm = movingFlowNavigationVm
        self.addExtraBuidlingViewModel = addExtraBuidlingViewModel
        itemPickerConfig = .init(
            items: movingFlowNavigationVm.moveConfigurationModel?.extraBuildingTypes
                .compactMap { (object: $0, displayName: .init(title: $0.translatedValue)) } ?? [],
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
            }
        )
    }

    var body: some View {
        ItemPickerScreen<ExtraBuildingType>(
            config: itemPickerConfig
        )
        .hItemPickerAttributes([.singleSelect, .alwaysAttachToBottom])
        .hFormContentPosition(.compact)
    }
}

#Preview {
    TypeOfBuildingPickerScreen(
        currentlySelected: nil,
        movingFlowNavigationVm: .init(),
        addExtraBuidlingViewModel: .init()
    )
}
