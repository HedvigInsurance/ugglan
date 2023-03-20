import SwiftUI
import hCore
import hCoreUI

//import Combine

public struct DamamagePickerScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var selectedDamages: [NewClaimsInfo] = []
    @State var isSelected: Bool = false

    public init() {}

    public var body: some View {
        hForm {

            hSection {

                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.newClaims
                    }
                ) { claim in

                    let damage = claim.listOfDamage

                    ForEach(damage ?? [], id: \.self) { element in
                        hRow {
                            hText(element.displayValue, style: .body)
                                .foregroundColor(hLabelColor.primary)
                            //                            if isDone {
                            //
                            //                            }
                            //                            Image(systemName: "checkmark")
                        }

                        //                        .withCustomAccessory {
                        //                            //add checkmark image if selected?
                        //
                        //                        }
                        .onTap {
                            //                            element.isDone.toggle()

                            let newDamage = NewClaimsInfo(displayValue: element.displayValue, value: element.value)

                            if !selectedDamages.contains(newDamage) {
                                selectedDamages.append(newDamage)
                            } else {
                                let index = selectedDamages.firstIndex(of: newDamage)

                                if let index = index {
                                    selectedDamages.remove(at: index)
                                }
                            }
                        }
                    }
                }
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled  {
                store.send(.submitDamage(damage: selectedDamages))
            } content: {
                hText(L10n.generalContinueButton)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct DamamagePickerScreen_Previews: PreviewProvider {
    static var previews: some View {
        DamamagePickerScreen()
    }
}
