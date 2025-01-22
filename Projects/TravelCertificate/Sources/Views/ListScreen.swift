import Addons
import Contracts
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct ListScreen: View {
    @StateObject var vm = ListScreenViewModel()
    @EnvironmentObject var router: Router
    @EnvironmentObject var travelCertificateNavigationVm: TravelCertificateNavigationViewModel

    let infoButtonPlacement: ListToolBarPlacement

    public init(
        infoButtonPlacement: ListToolBarPlacement
    ) {
        self.infoButtonPlacement = infoButtonPlacement
    }

    public var body: some View {
        hForm {
            if vm.list.isEmpty && !vm.isLoading {
                VStack(spacing: .padding16) {
                    Image(uiImage: hCoreUIAssets.infoFilled.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)
                        .accessibilityHidden(true)
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
                }
                .hSectionWithoutHorizontalPadding
            }
        }
        .hFormContentPosition(vm.list.isEmpty ? .center : .top)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 16) {
                    if Dependencies.featureFlags().isAddonsEnabled, let banner = vm.addonBannerModel {
                        AddonCardView(
                            openAddon: {
                                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                                let addonContracts = banner.contractIds.compactMap({
                                    contractStore.state.contractForId($0)
                                })

                                let addonConfigs: [AddonConfig] = addonContracts.map({
                                    .init(
                                        contractId: $0.id,
                                        exposureName: $0.exposureDisplayName,
                                        displayName: $0.currentAgreement?.productVariant.displayName ?? ""
                                    )
                                })
                                travelCertificateNavigationVm.isAddonPresented = .init(
                                    contractConfigs: addonConfigs
                                )
                            },
                            addon: banner
                        )
                    }
                    if vm.canCreateTravelInsurance {
                        hButton.LargeButton(type: .secondary) {
                            createNewPressed()
                        } content: {
                            hText(L10n.TravelCertificate.createNewCertificate)
                        }
                        .hButtonIsLoading(vm.isCreateNewLoading)
                    }
                }
                .padding(.vertical, .padding16)
            }
        }
        .loading($vm.isLoading, $vm.error)
        .applyInfoButton(withPlacement: infoButtonPlacement) {
            InfoViewHolder(
                title: L10n.TravelCertificate.Info.title,
                description: L10n.TravelCertificate.Info.subtitle,
                type: .navigation
            )
            .foregroundColor(hTextColor.Opaque.primary)
        }
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

    func createNewPressed() {
        Task { @MainActor in
            withAnimation {
                vm.isCreateNewLoading = true
            }
            do {
                let specifications = try await vm.service.getSpecifications()
                travelCertificateNavigationVm.isStartDateScreenPresented = .init(specification: specifications)
            } catch _ {

            }
            withAnimation {
                vm.isCreateNewLoading = false
            }
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func applyInfoButton<Content: View>(
        withPlacement: ListToolBarPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        switch withPlacement {
        case .leading:
            self.setToolbarLeading {
                content()
            }
        case .trailing:
            self.setToolbarTrailing {
                content()
            }
        }
    }
}

@MainActor
class ListScreenViewModel: ObservableObject {
    var service = TravelInsuranceService()
    @Published var list: [TravelCertificateModel] = []
    @Published var canCreateTravelInsurance: Bool = false
    @Published var error: String?
    @Published var isLoading = false
    @Published var isCreateNewLoading: Bool = false
    @Published var addonBannerModel: AddonBannerModel?
    private var addonAddedObserver: NSObjectProtocol?

    init() {
        addonAddedObserver = NotificationCenter.default.addObserver(forName: .addonAdded, object: nil, queue: nil) {
            [weak self] notification in
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
            let (list, canCreateTravelInsurance, banner) = try await self.service.getList(source: .appUpsellUpgrade)
            withAnimation {
                self.list = list
                self.canCreateTravelInsurance = canCreateTravelInsurance
                self.addonBannerModel = banner
            }
        } catch _ {
            self.error = L10n.General.errorBody
        }
        isLoading = false
    }
}

#Preview {
    ListScreen(infoButtonPlacement: .trailing)
        .environmentObject(TravelCertificateNavigationViewModel())
}
