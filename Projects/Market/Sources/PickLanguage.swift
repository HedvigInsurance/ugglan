import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct PickLanguage: View {
    let currentMarket: Market
    let onSave: (() -> Void)?
    let onCancel: (() -> Void)?
    @PresentableStore var store: MarketStore

    @State var currentLocale: Localization.Locale = .currentLocale
    @State var code: String? = Localization.Locale.currentLocale.lprojCode

    public init(
        currentMarket: Market
    ) {
        self.currentMarket = currentMarket
        onSave = nil
        onCancel = nil
    }

    public init(
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        let store: MarketStore = globalPresentableStoreContainer.get()
        currentMarket = store.state.market
        self.onSave = onSave
        self.onCancel = onCancel
    }

    public var body: some View {
        hForm {
            if onSave == nil {
                hText(L10n.LanguagePickerModal.text, style: .body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }
            hSection {
                VStack(spacing: 4) {
                    ForEach(currentMarket.languages, id: \.lprojCode) { locale in
                        hRadioField(
                            id: locale.lprojCode,
                            content: {
                                HStack(spacing: 16) {
                                    Image(uiImage: locale.icon)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    hText(locale.displayName, style: .title3)
                                        .foregroundColor(hTextColorNew.primary)
                                }
                            },
                            selected: $code
                        )
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    if let onSave {
                        hButton.LargeButtonPrimary {
                            Localization.Locale.currentLocale = currentLocale
                            onSave()
                        } content: {
                            hText(L10n.generalSaveButton)
                        }
                    }
                    if let onCancel {
                        hButton.LargeButtonGhost {
                            onCancel()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
            .sectionContainerStyle(.transparent)
            .hWithoutDivider
        }
        .onChange(of: code) { newValue in
            if let locale = Localization.Locale.allCases.first(where: { $0.lprojCode == newValue }) {
                if onSave == nil {
                    Localization.Locale.currentLocale = locale
                } else {
                    currentLocale = locale
                }
            }
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hFillColorNew.opaqueOne
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColorNew.primary
        } else {
            hBorderColorNew.opaqueTwo
        }
    }
}

extension PickLanguage {
    public var journey: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .selectMarket = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.MarketLanguageScreen.chooseLanguageLabel)
    }
}
