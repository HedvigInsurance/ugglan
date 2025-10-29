import SwiftUI
import hCore
import hCoreUI

public struct LanguagePickerView: View {
    let onSave: () -> Void
    let onCancel: () -> Void

    @State var currentLocale: Localization.Locale = .currentLocale.value
    @State var code: String? = Localization.Locale.currentLocale.value.lprojCode

    public init(
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                hSection {
                    VStack(spacing: .padding4) {
                        ForEach(Localization.Locale.allCases, id: \.lprojCode) { locale in
                            hRadioField(
                                id: locale.lprojCode,
                                leftView: {
                                    HStack(spacing: .padding16) {
                                        locale.icon
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        hText(locale.displayName, style: .heading2)
                                            .foregroundColor(hTextColor.Opaque.primary)
                                    }
                                    .asAnyView
                                },
                                selected: $code
                            )
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.generalSaveButton)
                    ) {
                        Localization.Locale.currentLocale.send(currentLocale)
                        onSave()
                    }
                    hCancelButton {
                        onCancel()
                    }
                }
            }
            .padding(.top, .padding16)
            .sectionContainerStyle(.transparent)
            .hWithoutDivider
        }
        .onChange(of: code) { newValue in
            if let locale = Localization.Locale.allCases.first(where: { $0.lprojCode == newValue }) {
                currentLocale = locale
            }
        }
    }
}

#Preview {
    LanguagePickerView(onSave: {}, onCancel: {})
}
