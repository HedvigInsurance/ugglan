import PresentableStore
import SwiftUI
import hCoreUI

struct TypeOfBuildingPickerView: View {
    var currentlySelected: ExtraBuildingType?
    @Binding var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @ObservedObject var addExtraBuidlingViewModel: MovingFlowAddExtraBuildingViewModel

    public init(
        currentlySelected: ExtraBuildingType?,
        isBuildingTypePickerPresented: Binding<ExtraBuildingTypeNavigationModel?>,
        addExtraBuidlingViewModel: MovingFlowAddExtraBuildingViewModel
    ) {
        self.currentlySelected = currentlySelected
        self._isBuildingTypePickerPresented = isBuildingTypePickerPresented
        self.addExtraBuidlingViewModel = addExtraBuidlingViewModel
    }

    var body: some View {
        ItemPickerScreen<ExtraBuildingType>(
            config: .init(
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
                        isBuildingTypePickerPresented = nil
                        if let object = selected.0 {
                            addExtraBuidlingViewModel.buildingType = object
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

#Preview {
    TypeOfBuildingPickerView(
        currentlySelected: nil,
        isBuildingTypePickerPresented: .constant(nil),
        addExtraBuidlingViewModel: .init()
    )
}
