import PresentableStore
import SwiftUI
import hCoreUI

struct TypeOfBuildingPickerView: View {
    var currentlySelected: ExtraBuildingType?
    @Binding var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel

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
                            var movingFlowVm = movingFlowNavigationVm.movingFlowVm
                            movingFlowVm?.extraBuildingTypes.append(object)
                            movingFlowNavigationVm.movingFlowVm = movingFlowVm
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
    TypeOfBuildingPickerView(currentlySelected: nil, isBuildingTypePickerPresented: .constant(nil))
}
