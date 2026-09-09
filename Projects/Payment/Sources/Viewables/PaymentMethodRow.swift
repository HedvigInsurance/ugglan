import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodRow<Value>: View where Value: Hashable {
    private let item: ItemModel
    private let provider: PaymentProvider
    private let content: Content
    private let isDisabled: Bool

    private enum Content {
        /// `isInert` takes no taps, so the row never fires a haptic for an action that isn't there.
        /// Selectable rows use `isDisabled` instead.
        case plain(accessory: hRadioOptionAccessory, showsPrimaryLabel: Bool, isInert: Bool, onTap: () -> Void)
        case selection(value: Value, selection: Binding<Value?>)
    }

    private init(
        item: ItemModel,
        provider: PaymentProvider,
        content: Content,
        isDisabled: Bool = false
    ) {
        self.item = item
        self.provider = provider
        self.content = content
        self.isDisabled = isDisabled
    }

    var body: some View {
        switch content {
        case let .plain(accessory, showsPrimaryLabel, isInert, onTap):
            hRadioOption<Never>(
                item: item,
                accessory: accessory,
                onTap: onTap,
                trailing: {
                    if showsPrimaryLabel {
                        // Styled as a button, but it is a label: taps fall through to the row.
                        hButton(
                            .small,
                            .secondaryAlt,
                            content: .init(title: L10n.paymentPrimaryLabel)
                        ) {}
                        .allowsHitTesting(false)
                        .transition(.opacity.animation(.easeInOut))
                    }
                },
                leading: {
                    provider.image()
                }
            )
            .allowsHitTesting(!isInert)
            .accessibilityRemoveTraits(isInert ? .isButton : [])
        case let .selection(value, selection):
            hRadioOption(value: value, selection: selection, item: item) {
                provider.image()
            }
            .disabled(isDisabled)
        }
    }
}

extension PaymentMethodRow where Value == Never {
    init(
        _ method: ConnectedPaymentMethod,
        accessory: hRadioOptionAccessory = .chevron,
        showsPrimaryLabel: Bool? = nil,
        onTap: @escaping () -> Void = {}
    ) {
        self.init(
            item: method.item,
            provider: method.provider,
            content: .plain(
                accessory: method.isPending ? .none : accessory,
                showsPrimaryLabel: showsPrimaryLabel ?? (method.isDefault && !method.isPending),
                isInert: method.isPending,
                onTap: onTap
            )
        )
    }
}

extension PaymentMethodRow where Value == ConnectedPaymentMethod {
    init(_ method: ConnectedPaymentMethod, selection: Binding<ConnectedPaymentMethod?>) {
        self.init(
            item: method.item,
            provider: method.provider,
            content: method.isDefault
                ? .plain(accessory: .none, showsPrimaryLabel: true, isInert: true, onTap: {})
                : .selection(value: method, selection: selection),
            isDisabled: method.isPending
        )
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
                PaymentMethodRow(trustly, selection: .constant(trustly))
                PaymentMethodRow(swish, selection: .constant(trustly))
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
