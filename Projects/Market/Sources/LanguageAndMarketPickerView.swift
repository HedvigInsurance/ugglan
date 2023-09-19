import SwiftUI
import hCore
import hCoreUI
import Presentation

enum LanguageAndMarketPicker: String, CaseIterable, Identifiable {
    case market
    case language
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .market:
            return L10n.MarketPickerModal.title
        case .language:
            return L10n.LanguagePickerModal.title
        }
    }
    
    var index: Int {
        return LanguageAndMarketPicker.allCases.firstIndex(of: self) ?? 0
    }
    
    func move(_ otherPanel: LanguageAndMarketPicker) -> AnyTransition {
        return otherPanel.index < self.index ? .move(edge: .trailing) : .move(edge: .leading)
    }
}

class TabControllerContextMarket: ObservableObject {
    private typealias Views = LanguageAndMarketPicker
    
    @Published var selected = Views.market {
        didSet {
            if previous != selected {
                insertion = selected.move(previous)
                removal = previous.move(selected)
                
                withAnimation {
                    trigger = selected
                    previous = selected
                }
            }
        }
    }
    
    @Published var trigger = Views.market
    @Published var previous = Views.market
    var insertion: AnyTransition = .move(edge: .leading)
    var removal: AnyTransition = .move(edge: .trailing)
}

public struct LanguageAndMarketPickerView: View {
    @EnvironmentObject var context: TabControllerContextMarket
    @State private var selectedView = LanguageAndMarketPicker.market
    let marketView: PickMarket
    let languageView: PickLanguage
    
    public init(
    ) {
        marketView = PickMarket(
            onSave: { selectedMarket in
                let store: MarketStore = globalPresentableStoreContainer.get()
                store.send(.selectMarket(market: selectedMarket))
                store.send(.dismissPicker)
            }
        )
        languageView = PickLanguage(
            onSave: { selectedLanguage in
                let store: MarketStore = globalPresentableStoreContainer.get()
                store.send(.selectLanguage(language: selectedLanguage))
            }, onCancel: {
                let store: MarketStore = globalPresentableStoreContainer.get()
                store.send(.dismissPicker)
            })
        
        let font = Fonts.fontFor(style: .standardSmall)
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brandNew(.secondaryText),
                    NSAttributedString.Key.font: font,
                ],
                for: .normal
            )
        
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brandNew(.primaryText(false)),
                    NSAttributedString.Key.font: font,
                ],
                for: .selected
            )
    }
    
    @ViewBuilder
    func viewFor(view: LanguageAndMarketPicker) -> some View {
        switch view {
        case .market:
            marketView
        case .language:
            languageView
        }
    }
    
    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    Picker("View", selection: $context.selected) {
                        ForEach(LanguageAndMarketPicker.allCases) { view in
                            hText(view.title, style: .standardSmall).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .sectionContainerStyle(.transparent)
                
                ForEach(LanguageAndMarketPicker.allCases) { panel in
                    if context.trigger == panel {
                        viewFor(view: panel)
                            .transition(.asymmetric(insertion: context.insertion, removal: context.removal))
                            .animation(.interpolatingSpring(stiffness: 300, damping: 70).speed(2))
                    }
                }
                .padding(.top, 8)
                hText(L10n.profileAboutAppVersion + " " + Bundle.main.appVersion, style: .caption1)
                    .foregroundColor(hTextColorNew.tertiary)
            }
        }
        .presentableStoreLensAnimation(.default)
    }
}

extension LanguageAndMarketPickerView {
    public func journey() -> some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: self.environmentObject(TabControllerContextMarket()),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar]
        ) { action in
            if case .dismissPicker = action  {
                PopJourney()
            }
        }
    }
}
