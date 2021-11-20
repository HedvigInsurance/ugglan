import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

enum InsuranceWrapper {
    case external(EmbarkPassage.Action.AsEmbarkExternalInsuranceProviderAction)
    case previous(EmbarkPassage.Action.AsEmbarkPreviousInsuranceProviderAction)

    var embarkLinkFragment: GraphQL.EmbarkLinkFragment {
        switch self {
        case let .external(data): return data.externalInsuranceProviderData.next.fragments.embarkLinkFragment
        case let .previous(data): return data.previousInsuranceProviderData.next.fragments.embarkLinkFragment
        }
    }

    var key: String {
        switch self {
        case .external: return "previousInsurer"
        case let .previous(data): return data.previousInsuranceProviderData.storeKey
        }
    }

    var isExternal: Bool {
        switch self {
        case .external:
            return true
        case .previous:
            return true
        }
    }

    var locale: Localization.Locale? {
        Localization.Locale.currentLocale
    }
}

class InsuranceProviderPickerDataSource: NSObject, UIPickerViewDataSource {
    public init(providers: [GraphQL.InsuranceProviderFragment]) { self.providers = providers }

    let providers: [GraphQL.InsuranceProviderFragment]

    func numberOfComponents(in _: UIPickerView) -> Int { 1 }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int { providers.count }
}

class InsuranceProviderPickerDelegate: NSObject, UIPickerViewDelegate {
    @ReadWriteState var selectedProvider: GraphQL.InsuranceProviderFragment?

    public init(providers: [GraphQL.InsuranceProviderFragment]) { self.providers = providers }

    let providers: [GraphQL.InsuranceProviderFragment]

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? { providers[row].name }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedProvider = providers[row]
    }
}

struct InsuranceProviderAction {
    let state: EmbarkState
    let data: InsuranceWrapper
    @Inject var client: ApolloClient
    @ReadWriteState private var selectedProvider: GraphQL.InsuranceProviderFragment?
}

extension InsuranceProviderAction: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
        let bag = DisposeBag()

        let outerContainer = UIStackView()
        outerContainer.axis = .vertical
        outerContainer.spacing = 16

        let view = UIView()
        view.backgroundColor = .brand(.secondaryBackground())
        view.layer.cornerRadius = .defaultCornerRadius
        bag += view.applyShadow { _ -> UIView.ShadowProperties in .embark }
        outerContainer.addArrangedSubview(view)

        let contentContainer = UIStackView()
        contentContainer.axis = .vertical
        contentContainer.spacing = 21
        contentContainer.edgeInsets = UIEdgeInsets(top: 21, left: 15, bottom: 21, right: 15)
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

        let rowView = RowView(title: L10n.InsuranceProvider.currentInsurer)
        contentContainer.addArrangedSubview(rowView)

        let rowValueLabel = UILabel(value: "", style: .brand(.body(color: .secondary)))
        rowView.append(rowValueLabel)

        bag += $selectedProvider.compactMap { $0?.name }.bindTo(rowValueLabel, \.value)

        let divider = Divider(backgroundColor: .brand(.primaryBorderColor))
        bag += contentContainer.addArranged(divider)

        let pickerView = UIPickerView()
        pickerView.backgroundColor = .brand(.secondaryBackground())
        contentContainer.addArrangedSubview(pickerView)

        if let locale = data.locale {
            bag += client.fetch(query: GraphQL.InsuranceProvidersQuery(locale: locale.asGraphQLLocale()))
                .valueSignal.compactMap { $0.insuranceProviders }
                .onValue { providers in
                    let providers = [
                        [
                            Environment.current == .staging && data.isExternal
                                ? GraphQL.InsuranceProviderFragment(
                                    name: "DEMO",
                                    id: "DEMO",
                                    externalCollectionId: "demo",
                                    hasExternalCapabilities: true
                                ) : nil
                        ]
                        .compactMap { $0 },
                        providers.map { $0.fragments.insuranceProviderFragment },
                        [
                            .init(
                                name: L10n.externalInsuranceProviderOtherOption,
                                id: "other",
                                hasExternalCapabilities: false
                            )
                        ],
                    ]
                    .flatMap { $0 }

                    let dataSource = InsuranceProviderPickerDataSource(providers: providers)
                    bag.hold(dataSource)
                    pickerView.dataSource = dataSource

                    let delegate = InsuranceProviderPickerDelegate(providers: providers)
                    bag.hold(delegate)
                    pickerView.delegate = delegate
                    bag += delegate.$selectedProvider.atOnce().bindTo($selectedProvider)

                    func findSelectedProvider(provider: GraphQL.InsuranceProviderFragment) -> Bool {
                        provider.name == self.state.store.getPrefillValue(key: self.data.key)
                    }

                    let selectedProviderIndex = providers.firstIndex(where: findSelectedProvider)
                    delegate.selectedProvider =
                        providers.first(where: findSelectedProvider) ?? providers.first

                    pickerView.reloadAllComponents()
                    pickerView.selectRow(selectedProviderIndex ?? 0, inComponent: 0, animated: true)
                }
        }

        return (
            outerContainer,
            Signal { callback in
                let button = Button(
                    title: data.embarkLinkFragment.label,
                    type: .standard(
                        backgroundColor: .brand(.secondaryButtonBackgroundColor),
                        textColor: .brand(.secondaryButtonTextColor)
                    ),
                    isEnabled: true
                )

                bag += button.onTapSignal.withLatestFrom($selectedProvider.plain())
                    .compactMap { _, provider in provider }
                    .onValue { provider in
                        if let passageName = self.state.passageNameSignal.value {
                            self.state.store.setValue(
                                key: "\(passageName)Result",
                                value: provider.name
                            )
                        }

                        guard data.isExternal else {
                            self.state.store.setValue(
                                key: self.data.key,
                                value: provider.id
                            )
                            callback(self.data.embarkLinkFragment)
                            return
                        }

                        if provider.hasExternalCapabilities {
                            let externalCollectionID = provider.externalCollectionId ?? ""
                            let providerID =
                                "\(Localization.Locale.currentLocale.market.rawValue)-\(externalCollectionID)"

                            state.externalRedirectSignal.value = .dataCollection(
                                providerID: providerID.lowercased(),
                                providerDisplayName: provider.name
                            ) { id, personalNumber in
                                if let id = id {
                                    state.store.setValue(key: "dataCollectionId", value: id.uuidString)
                                    state.store.setValue(key: "\(data.key)_dataCollectionId", value: id.uuidString)
                                }

                                if let personalNumber = personalNumber {
                                    state.store.setValue(key: "personalNumber", value: personalNumber)
                                }

                                bag += Signal(after: 0.3)
                                    .onValue { _ in
                                        callback(self.data.embarkLinkFragment)
                                    }
                            }
                        } else if provider.name != L10n.externalInsuranceProviderOtherOption {
                            self.state.store.setValue(
                                key: self.data.key,
                                value: provider.id
                            )
                            callback(self.data.embarkLinkFragment)
                        } else {
                            outerContainer.viewController?
                                .present(
                                    Alert(
                                        title: L10n
                                            .externalInsuranceProviderAlertTitle,
                                        message: L10n
                                            .externalInsuranceProviderAlertMessage,
                                        actions: [
                                            Alert.Action(
                                                title: L10n.alertOk,
                                                action: { true }
                                            )
                                        ]
                                    )
                                )
                                .onValue { _ in callback(self.data.embarkLinkFragment) }
                        }
                    }

                bag += outerContainer.addArranged(button)

                return bag
            }
        )
    }
}
