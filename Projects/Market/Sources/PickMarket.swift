import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct PickMarket: View {
    @PresentableStore var store: MarketStore
    @State var code: String? = ""
    @State var selectedMarket: Market?
    
    let onSave: (Market) -> Void
    
    public init(
        onSave: @escaping (Market) -> Void
    ) {
        self.onSave = onSave
    }
    
    public var body: some View {
        hForm {
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
        .onAppear {
            code = store.state.market.id
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primary) {
                        if let selectedMarket = selectedMarket {
                            onSave(selectedMarket)
                        }
                    } content: {
                        hText(L10n.generalSaveButton)
                    }
                    hButton.LargeButton(type: .ghost) {
                        store.send(.dismissPicker)
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                    
                }
            }
            .padding(.top, 8)
            .sectionContainerStyle(.transparent)
            .hWithoutDivider
        }
        .onChange(of: code) { newValue in
            if let marketValue = Market.allCases.first(where: { $0.id == newValue }) {
                selectedMarket = marketValue
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
            } else if case .dismissPicker = action {
                PopJourney()
            }
        }
    }
}
