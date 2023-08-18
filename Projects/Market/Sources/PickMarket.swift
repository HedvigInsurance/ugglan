import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct PickMarket: View {
    var currentMarket: Market
    @PresentableStore var store: MarketStore
    @State var code: String?

    let onSave: ((Market) -> Void)?
    let onCancel: (() -> Void)?

    @State var selectedMarket: Market

    public init(
        currentMarket: Market,
        onSave: ((Market) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.currentMarket = currentMarket
        self.onSave = onSave
        self.onCancel = onCancel
        self.code = currentMarket.id
        self.selectedMarket = currentMarket
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
                    ForEach(Market.activatedMarkets, id: \.title) { market in
                        hRadioField(
                            id: market.id,
                            content: {
                                HStack(spacing: 16) {
                                    Image(uiImage: market.icon)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    hText(market.title, style: .title3)
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
                            onSave(selectedMarket)
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
            if let marketValue = Market.allCases.first(where: { $0.id == newValue }) {
                if let onSave = onSave {
                    selectedMarket = marketValue
                }
            }
        }
    }
}

extension PickMarket {
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
        .configureTitle(L10n.MarketLanguageScreen.marketLabel)
        .withDismissButton
    }
}
