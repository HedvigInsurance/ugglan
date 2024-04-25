import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ListScreen: View {
    @StateObject var vm = ListScreenViewModel()
    //    @PresentableStore var store: TravelInsuranceStore
    @EnvironmentObject var router: Router

    let canAddTravelInsurance: Bool
    let infoButtonPlacement: ToolbarItemPlacement

    public init(
        canAddTravelInsurance: Bool,
        infoButtonPlacement: ToolbarItemPlacement
    ) {
        self.canAddTravelInsurance = canAddTravelInsurance
        self.infoButtonPlacement = infoButtonPlacement
    }
    public var body: some View {
        hForm {
            if vm.list.isEmpty {
                VStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.blueElement)
                    hText(L10n.TravelCertificate.emptyListMessage)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
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
                        //                        store.send(.navigation(.openDetails(for: travelCertificate)))
                    }
                }
                .withoutHorizontalPadding
            }
        }
        .hFormContentPosition(vm.list.isEmpty ? .center : .top)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 16) {
                    InfoCard(text: L10n.TravelCertificate.startDateInfo(45), type: .info)
                    if canAddTravelInsurance {
                        hButton.LargeButton(type: .secondary) {
                            createNewPressed()
                        } content: {
                            hText(L10n.TravelCertificate.createNewCertificate)
                        }
                        .hButtonIsLoading(vm.isCreateNewLoading)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .loading($vm.isLoading, $vm.error)
        .toolbar {
            ToolbarItem(
                placement: infoButtonPlacement
            ) {
                InfoViewHolder(
                    title: L10n.TravelCertificate.Info.title,
                    description: L10n.TravelCertificate.Info.subtitle,
                    type: .navigation
                )
                .foregroundColor(hTextColor.primary)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    func createNewPressed() {
        Task { @MainActor in
            withAnimation {
                vm.isCreateNewLoading = true
            }
            do {
                let specifications = try await vm.service.getSpecifications()
                router.push(TravelInsuranceSpecificationNavigationModel.init(specification: specifications))

            } catch _ {

            }
            withAnimation {
                vm.isCreateNewLoading = false
            }
        }
    }
}

class ListScreenViewModel: ObservableObject {
    @Inject var service: TravelInsuranceClient

    @Published var list: [TravelCertificateModel] = []
    @Published var error: String?
    @Published var isLoading = false
    @Published var isCreateNewLoading: Bool = false

    init() {
        Task {
            await getTravelCertificateList()
        }
    }

    @MainActor
    private func getTravelCertificateList() async {
        isLoading = true
        do {
            let list = try await self.service.getList()
            self.list = list
        } catch _ {
            self.error = L10n.General.errorBody
        }
        isLoading = false
    }
}

struct LoadingViewWithContent: ViewModifier {
    @Binding var isLoading: Bool
    @Binding var error: String?
    func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading {
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else if let error = error {
                GenericErrorView(
                    description: error,
                    buttons: .init()
                )
                .hWithoutTitle
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                content.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

extension View {
    func loading(_ isLoading: Binding<Bool>, _ error: Binding<String?>) -> some View {
        modifier(LoadingViewWithContent(isLoading: isLoading, error: error))
    }
}
