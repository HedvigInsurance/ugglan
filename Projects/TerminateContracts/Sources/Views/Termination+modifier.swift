import ChangeTier
import Foundation
import hCoreUI
import SwiftUI

public extension View {
    func handleTerminateInsurance(
        vm: TerminateInsuranceViewModel,
        onDismiss: @escaping (DismissTerminationAction) -> Void
    ) -> some View {
        modifier(TerminateInsurance(vm: vm, onDismiss: onDismiss))
    }
}

struct TerminateInsurance: ViewModifier {
    @ObservedObject var vm: TerminateInsuranceViewModel

    @State var isFlowPresented: (DismissTerminationAction) -> Void = { _ in }

    let onDismiss: (DismissTerminationAction) -> Void
    func body(content: Content) -> some View {
        content
            .modally(
                item: $vm.flowNavigationVm,
                options: .constant(.alwaysOpenOnTop)
            ) { item in
                TerminationFlowNavigation(vm: item) { type in
                    onDismiss(type)
                }
            }
            .modally(item: $vm.changeTierInput) { item in
                ChangeTierNavigation(input: item)
            }
    }
}
