import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

extension Market {
    @JourneyBuilder
    public static var languageAndMarketPicker: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: LanguageAndMarketPickerView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .dismissPicker = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.loginMarketPickerPreferences)
    }
}

struct LanguageAndMarketPickerView: View {
    @StateObject private var vm = LanguageAndMarketPickerViewModel()
    var body: some View {
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
                        .foregroundColor(hTextColorNew.tertiary)

                    hButton.LargeButton(type: .primary) {
                        vm.save()
                    } content: {
                        hText(L10n.generalSaveButton)
                    }
                    hButton.LargeButton(type: .ghost) {
                        vm.dismiss()
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
                                    .foregroundColor(hTextColorNew.primary)
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
                                    .foregroundColor(hTextColorNew.primary)
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
    @Published var selectedLocaleCode: String? = Localization.Locale.currentLocale.rawValue

    @Published var selectedMarket: Market
    @Published var selectedMarketCode: String?

    @Published var trigger = LanguageAndMarketPicker.market
    @Published var previous = LanguageAndMarketPicker.market

    var insertion: AnyTransition = .move(edge: .leading)
    var removal: AnyTransition = .move(edge: .trailing)
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
                self?.selectedLocale = locale
            }
        }
        .store(in: &cancellables)
        $selectedMarketCode.sink { [weak self] selectedMarketCode in
            if let selectedMarketCode, let market = Market(rawValue: selectedMarketCode) {
                self?.selectedMarket = market
                if let currentSelectedLocale = market.languages.first(where: { $0 == Localization.Locale.currentLocale }
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
        store.send(.selectLanguage(language: selectedLocale.rawValue))
        dismiss()
    }
    func dismiss() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        store.send(.dismissPicker)
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
