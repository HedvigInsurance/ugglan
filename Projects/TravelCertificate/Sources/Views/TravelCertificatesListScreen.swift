import Addons
import Contracts
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct TravelCertificatesListScreen: View {
    @StateObject var vm = TravelCertificatesListScreenViewModel()
    @EnvironmentObject var travelCertificateNavigationVm: TravelCertificateNavigationViewModel

    let infoButtonPlacement: ListToolBarPlacement

    public init(
        infoButtonPlacement: ListToolBarPlacement
    ) {
        self.infoButtonPlacement = infoButtonPlacement
    }

    public var body: some View {
        hForm {
            if vm.list.isEmpty, !vm.isLoading {
                VStack(spacing: .padding16) {
                    hCoreUIAssets.infoFilled.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)

                    hText(L10n.TravelCertificate.emptyListMessage)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, .padding24)
            } else {
                hSection(vm.list) { travelCertificate in
                    hRow {
                        hText(travelCertificate.date.displayDateDDMMMFormat)
                        Spacer()
                        hText(
                            travelCertificate.valid
                                ? L10n.TravelCertificate.active : L10n.TravelCertificate.expired
                        )
                    }
                    .withChevronAccessory
                    .foregroundColor(travelCertificate.textColor)
                    .onTapGesture {
                        travelCertificateNavigationVm.isDocumentPresented = travelCertificate
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)
                }
                .hWithoutHorizontalPadding([.section])
            }
        }
        .hFormContentPosition(vm.list.isEmpty ? .center : .top)
        .hSetScrollBounce(to: true)
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    addonView
                    createNewButton
                }
            }
        }
        .loading($vm.isLoading, $vm.error)
        .applyInfoButton(
            withPlacement: infoButtonPlacement,
            action: {
                travelCertificateNavigationVm.isInfoViewPresented = true
            }
        )
        .sectionContainerStyle(.transparent)
        .onAppear {
            Task {
                await vm.fetchTravelCertificateList()
            }
        }
        .onPullToRefresh {
            await vm.fetchTravelCertificateList()
        }
        .onChange(of: travelCertificateNavigationVm.isStartDateScreenPresented) { value in
            if value == nil {
                Task {
                    await vm.fetchTravelCertificateList()
                }
            }
        }
    }

    @ViewBuilder
    private var addonView: some View {
        if let banner = vm.addonBanner {
            AddonCardView(
                openAddon: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let addonConfigs = contractStore.getAddonConfigsFor(contractIds: banner.contractIds)
                    travelCertificateNavigationVm.isAddonPresented = .init(
                        addonSource: .travelCertificates,
                        contractConfigs: addonConfigs
                    )
                },
                addon: banner
            )
            .hButtonIsLoading(travelCertificateNavigationVm.isAddonPresented != nil)
        }
    }

    @ViewBuilder
    private var createNewButton: some View {
        if vm.canCreateTravelInsurance {
            hButton(
                .large,
                .secondary,
                content: .init(title: L10n.TravelCertificate.createNewCertificate),
                {
                    createNewPressed()
                }
            )
            .hButtonIsLoading(vm.isCreateNewLoading)
        }
    }

    func createNewPressed() {
        Task { @MainActor in
            withAnimation {
                vm.isCreateNewLoading = true
            }
            do {
                let specifications = try await vm.service.getSpecifications()
                travelCertificateNavigationVm.isStartDateScreenPresented = .init(specification: specifications)
            } catch _ {}
            withAnimation {
                vm.isCreateNewLoading = false
            }
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func applyInfoButton(
        withPlacement: ListToolBarPlacement,
        action: @escaping () -> Void
    ) -> some View {
        switch withPlacement {
        case .leading:
            setToolbarLeading {
                ToolbarButtonView(types: .constant([ToolbarOptionType.travelCertificate]), placement: .leading) { _ in
                    action()
                }
                .accessibilityValue(L10n.Toast.readMore)
            }
        case .trailing:
            setToolbarTrailing {
                ToolbarButtonView(types: .constant([ToolbarOptionType.travelCertificate]), placement: .trailing) { _ in
                    action()
                }
                .accessibilityValue(L10n.Toast.readMore)
            }
        }
    }
}

@MainActor
class TravelCertificatesListScreenViewModel: ObservableObject {
    var service = TravelInsuranceService()
    @Published var list: [TravelCertificateModel] = []
    @Published var canCreateTravelInsurance: Bool = false
    @Published var error: String?
    @Published var isLoading = false
    @Published var isCreateNewLoading: Bool = false
    @Published var addonBanner: AddonBanner?
    private var addonAddedObserver: NSObjectProtocol?

    init() {
        addonAddedObserver = NotificationCenter.default.addObserver(forName: .addonsChanged, object: nil, queue: nil) {
            [weak self] _ in
            Task {
                await self?.fetchTravelCertificateList()
            }
        }
    }

    deinit {
        Task { @MainActor [weak self] in
            if let addonAddedObserver = self?.addonAddedObserver {
                NotificationCenter.default.removeObserver(addonAddedObserver)
            }
        }
    }

    @MainActor
    func fetchTravelCertificateList() async {
        if list.isEmpty {
            isLoading = true
        }
        do {
            let (list, canCreateTravelInsurance, banner) = try await service.getList(source: .travelCertificates)
            withAnimation {
                self.list = list
                self.canCreateTravelInsurance = canCreateTravelInsurance
                self.addonBanner = banner
            }
        } catch _ {
            self.error = L10n.General.errorBody
        }
        isLoading = false
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in TravelInsuranceClientDemo() })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    return TravelCertificatesListScreen(infoButtonPlacement: .trailing)
}
