import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PickLanguage: View {
    let onSave: ((String) -> Void)?
    let onCancel: (() -> Void)?
    @PresentableStore var store: MarketStore

    @State var currentLocale: Localization.Locale = .currentLocale.value
    @State var code: String? = Localization.Locale.currentLocale.value.lprojCode

    public init() {
        onSave = nil
        onCancel = nil
    }

    public init(
        onSave: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                if onSave == nil {
                    hSection {
                        hText(L10n.LanguagePickerModal.text, style: .body1)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                hSection {
                    VStack(spacing: 4) {
                        ForEach(Localization.Locale.allCases, id: \.lprojCode) { locale in
                            hRadioField(
                                id: locale.lprojCode,
                                leftView: {
                                    HStack(spacing: 16) {
                                        Image(uiImage: locale.icon)
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
                VStack(spacing: 8) {
                    if let onSave {
                        hButton.LargeButton(type: .primary) {
                            Localization.Locale.currentLocale.send(currentLocale)
                            onSave(currentLocale.code)
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                    }
                    if let onCancel {
                        hButton.LargeButton(type: .ghost) {
                            onCancel()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                    }
                }
            }
            .padding(.vertical, .padding16)
            .sectionContainerStyle(.transparent)
            .hWithoutDivider
        }
        .onChange(of: code) { newValue in
            if let locale = Localization.Locale.allCases.first(where: { $0.lprojCode == newValue }) {
                if onSave == nil {
                    Localization.Locale.currentLocale.send(locale)
                }
                currentLocale = locale
            }
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.Opaque.primary
        } else {
            hSurfaceColor.Opaque.primary
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.Opaque.primary
        } else {
            hBorderColor.secondary
        }
    }
}
