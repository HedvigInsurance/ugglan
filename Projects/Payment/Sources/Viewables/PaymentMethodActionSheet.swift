import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodActionSheet<Hero: View>: View {
    @StateObject private var vm: PaymentActionViewModel
    @Environment(\.dismiss) private var dismiss

    private let title: hTitle
    private let subTitle: hTitle?
    private let showsPrimaryLabel: Bool?
    private let confirmTitle: String
    private let hero: Hero
    private let onSuccess: () -> Void

    init(
        vm: PaymentActionViewModel,
        title: hTitle,
        subTitle: hTitle? = nil,
        showsPrimaryLabel: Bool? = nil,
        confirmTitle: String,
        @ViewBuilder hero: () -> Hero,
        onSuccess: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.title = title
        self.subTitle = subTitle
        self.showsPrimaryLabel = showsPrimaryLabel
        self.confirmTitle = confirmTitle
        self.hero = hero()
        self.onSuccess = onSuccess
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    hero
                    PaymentMethodRow(vm.method, accessory: .none, showsPrimaryLabel: showsPrimaryLabel)
                    VStack(spacing: .padding8) {
                        if let errorMessage = vm.errorMessage {
                            PaymentErrorLabel(message: errorMessage)
                        }
                        confirmButton
                        hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormTitle(title: title, subTitle: subTitle)
        .hFormContentPosition(.compact)
        .disabled(vm.isLoading)
    }

    private var confirmButton: some View {
        hButton(.large, .primary, content: .init(title: confirmTitle)) {
            if await vm.perform() {
                onSuccess()
            }
        }
        .hButtonIsLoading(vm.isLoading)
    }
}
