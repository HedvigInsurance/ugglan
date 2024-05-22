import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct LanguageAndMarketPickerView: View {
    @StateObject private var vm = LanguageAndMarketPickerViewModel()
    @EnvironmentObject var router: Router

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    Picker("View", selection: $vm.selected) {
                        ForEach(LanguageAndMarketPicker.allCases) { view in
                            hText(view.title, style: .standardSmall).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .sectionContainerStyle(.transparent)

                ForEach(LanguageAndMarketPicker.allCases) { panel in
                    if vm.selected == panel {
                        viewFor(view: panel)
                            .transition(.asymmetric(insertion: vm.insertion, removal: vm.removal))
                            .animation(.easeInOut(duration: 0.4))
                    }
                }
                .padding(.top, 8)

            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hText(L10n.profileAboutAppVersion + " " + Bundle.main.appVersion, style: .caption1)
                        .foregroundColor(hTextColor.tertiary)

                    hButton.LargeButton(type: .primary) {
                        vm.save()
                        router.dismiss()
                    } content: {
                        hText(L10n.generalSaveButton)
                    }
                    hButton.LargeButton(type: .ghost) {
                        router.dismiss()
                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .padding(.top, 8)
            .hWithoutDivider
        }
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

    private var marketView: some View {
        hSection {
            VStack(spacing: 4) {
                ForEach(Market.activatedMarkets, id: \.title) { market in
                    hRadioField(
                        id: market.rawValue,
                        content: {
                            HStack(spacing: 16) {
                                Image(uiImage: market.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                hText(market.title, style: .title3)
                                    .foregroundColor(hTextColor.primary)
                            }
                        },
                        selected: $vm.selectedMarketCode
                    )
                }
            }
        }
    }

    private var languageView: some View {
        hSection {
            VStack(spacing: 4) {
                ForEach(vm.selectedMarket.languages, id: \.lprojCode) { locale in
                    hRadioField(
                        id: locale.rawValue,
                        content: {
                            HStack(spacing: 16) {
                                Image(uiImage: locale.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                hText(locale.displayName, style: .title3)
                                    .foregroundColor(hTextColor.primary)
                            }
                        },
                        selected: $vm.selectedLocaleCode
                    )
                }
            }
        }
    }
}

struct LanguageAndMarketPickerView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageAndMarketPickerView()
    }
}

class LanguageAndMarketPickerViewModel: ObservableObject {
    @Published var selectedLocale = Localization.Locale.currentLocale
    @Published var selectedLocaleCode: String? = Localization.Locale.currentLocale.value.rawValue

    @Published var selectedMarket: Market
    @Published var selectedMarketCode: String?

    @Published var trigger = LanguageAndMarketPicker.language
    @Published var previous = LanguageAndMarketPicker.language

    @Published var insertion: AnyTransition = .move(edge: .leading)
    @Published var removal: AnyTransition = .move(edge: .trailing)
    var cancellables = Set<AnyCancellable>()

    @Published var selected: LanguageAndMarketPicker = .market {
        willSet {
            if previous != selected {
                insertion = previous.move(selected)
                removal = selected.move(previous)

                withAnimation {
                    trigger = selected
                    previous = selected
                }
            }
        }
    }

    init() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        selectedMarket = store.state.market
        selectedMarketCode = store.state.market.rawValue
        $selectedLocaleCode.sink { [weak self] selectedLocaleCode in
            if let selectedLocaleCode, let locale = Localization.Locale(rawValue: selectedLocaleCode) {
                self?.selectedLocale.value = locale
            }
        }
        .store(in: &cancellables)
        $selectedMarketCode.sink { [weak self] selectedMarketCode in
            if let selectedMarketCode, let market = Market(rawValue: selectedMarketCode) {
                self?.selectedMarket = market
                if let currentSelectedLocale = market.languages.first(where: {
                    $0 == Localization.Locale.currentLocale.value
                }
                ) {
                    self?.selectedLocaleCode = currentSelectedLocale.rawValue
                } else {
                    self?.selectedLocaleCode = market.preferredLanguage.rawValue

                }
            }
        }
        .store(in: &cancellables)
    }

    func save() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        store.send(.selectMarket(market: selectedMarket))
        store.send(.selectLanguage(language: selectedLocale.value.rawValue))
    }
}

enum LanguageAndMarketPicker: Int, CaseIterable, Identifiable {
    case market
    case language

    var id: Int { self.rawValue }

    var title: String {
        switch self {
        case .market:
            return L10n.MarketPickerModal.title
        case .language:
            return L10n.LanguagePickerModal.title
        }
    }

    func move(_ otherPanel: LanguageAndMarketPicker) -> AnyTransition {
        return otherPanel.rawValue < self.rawValue ? .move(edge: .trailing) : .move(edge: .leading)
    }
}
