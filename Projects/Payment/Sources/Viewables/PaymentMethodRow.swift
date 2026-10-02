import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodRow: View {
    private let method: ConnectedPaymentMethod
    private let accessory: hRadioOptionAccessory
    private let showsPrimaryLabel: Bool
    private let isInert: Bool
    private let onTap: () -> Void

    init(
        _ method: ConnectedPaymentMethod,
        accessory: hRadioOptionAccessory = .chevron,
        showsPrimaryLabel: Bool? = nil,
        allowsTapWhenPending: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        let isInert = method.isPending && !allowsTapWhenPending
        self.method = method
        self.accessory = isInert ? .none : accessory
        self.showsPrimaryLabel = showsPrimaryLabel ?? (method.isDefault && !method.isPending)
        self.isInert = isInert
        self.onTap = onTap
    }

    init(primary method: ConnectedPaymentMethod) {
        self.method = method
        self.accessory = .none
        self.showsPrimaryLabel = true
        self.isInert = true
        self.onTap = {}
    }

    var body: some View {
        hRadioOption<Never>(
            item: method.item,
            accessory: accessory,
            onTap: onTap,
            trailing: {
                if showsPrimaryLabel {
                    // Styled as a button, but it is a label: taps fall through to the row.
                    hButton(.small, .secondaryAlt, content: .init(title: L10n.paymentPrimaryLabel)) {}
                        .allowsHitTesting(false)
                        .transition(.opacity.animation(.easeInOut))
                }
            },
            leading: {
                method.provider.image()
            }
        )
        .allowsHitTesting(!isInert)
        .accessibilityRemoveTraits(isInert ? .isButton : [])
    }
}

struct PaymentMethodSelectableRow<Value: Hashable>: View {
    private let item: ItemModel
    private let provider: PaymentProvider
    private let value: Value
    private let selection: Binding<Value?>
    private let isDisabled: Bool

    private init(
        item: ItemModel,
        provider: PaymentProvider,
        value: Value,
        selection: Binding<Value?>,
        isDisabled: Bool
    ) {
        self.item = item
        self.provider = provider
        self.value = value
        self.selection = selection
        self.isDisabled = isDisabled
    }

    var body: some View {
        VStack {
            hRadioOption(value: value, selection: selection, item: item) {
                provider.image()
            }
        }
        .disabled(isDisabled)
    }
}

extension PaymentMethodSelectableRow where Value == ConnectedPaymentMethod {
    init(_ method: ConnectedPaymentMethod, selection: Binding<ConnectedPaymentMethod?>) {
        self.init(
            item: method.item,
            provider: method.provider,
            value: method,
            selection: selection,
            isDisabled: method.isPending
        )
    }
}

extension PaymentMethodSelectableRow where Value == PaymentProvider {
    init(_ provider: PaymentProvider, direction: PaymentDirection, selection: Binding<PaymentProvider?>) {
        self.init(
            item: .init(title: provider.title(for: direction), subTitle: provider.subtitle(for: direction)),
            provider: provider,
            value: provider,
            selection: selection,
            isDisabled: false
        )
    }
}

struct PaymentMethodLockedRow: View {
    private let method: ConnectedPaymentMethod

    init(_ method: ConnectedPaymentMethod) {
        self.method = method
    }

    var body: some View {
        hRadioOption<Never>(
            item: method.item,
            accessory: .none,
            onTap: {},
            trailing: {
                hCoreUIAssets.lock.view
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .accessibilityHidden(true)
            },
            leading: {
                method.provider.image()
                    .opacity(0.4)
            }
        )
        .allowsHitTesting(false)
        .accessibilityRemoveTraits(.isButton)
    }
}

#Preview {
    let trustly = ConnectedPaymentMethod(
        status: .active,
        isDefault: true,
        method: .trustly(bankAccount: .init(account: "account", bank: "bank"))
    )
    let swish = ConnectedPaymentMethod(
        status: .active,
        isDefault: false,
        method: .swish(phoneNumber: "0701231231")
    )
    let pendingSwish = ConnectedPaymentMethod(
        status: .pending,
        isDefault: true,
        method: .swish(phoneNumber: "0701231231")
    )
    Localization.Locale.currentLocale.send(.en_SE)

    return hForm {
        hSection {
            VStack(spacing: .padding8) {
                PaymentMethodRow(trustly)
                PaymentMethodRow(swish, accessory: .none)
                PaymentMethodRow(swish, accessory: .none, showsPrimaryLabel: true)
                PaymentMethodRow(pendingSwish)
                PaymentMethodRow(primary: trustly)
                PaymentMethodSelectableRow(swish, selection: .constant(trustly))
                PaymentMethodLockedRow(swish)
                PaymentMethodSelectableRow(.invoice, direction: .payin, selection: .constant(nil))
                PaymentMethodSelectableRow(.swish, direction: .payout, selection: .constant(nil))
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
