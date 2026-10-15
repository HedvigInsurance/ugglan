import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ForeverView: View {
    @Environment(ForeverNavigationViewModel.self) var foreverNavigationVm
    @State var scrollTo: Int = -1
    @State var spacing: CGFloat = 0
    @State var totalHeight: CGFloat = 0
    @State private var isInfoViewPresented = false
    @Environment(\.hSecondaryToolbarPlacement) private var infoButtonPlacement
    @State var discountCodeHeight: CGFloat = 0 {
        didSet {
            recalculateHeight()
        }
    }

    @State var headerHeight: CGFloat = 0 {
        didSet {
            recalculateHeight()
        }
    }

    public init() {}

    public var body: some View {
        @Bindable var foreverNavigationVm = foreverNavigationVm
        successView
            .loading($foreverNavigationVm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        Task {
                            await foreverNavigationVm.fetchForeverData()
                        }
                    }),
                    dismissButton: nil
                )
            )
            .onAppear {
                Task {
                    await foreverNavigationVm.fetchForeverData()
                }
            }
            .toolbar {
                ToolbarItem(id: "foreverInfoButton", placement: infoButtonPlacement) {
                    SwiftUI.Button {
                        isInfoViewPresented = true
                    } label: {
                        hCoreUIAssets.infoOutlined.view
                            .foregroundColor(hTextColor.Opaque.primary)
                    }
                    .accessibilityLabel(L10n.voiceoverMoreInfo)
                }
            }
            .detent(
                presented: $isInfoViewPresented,
                options: .constant(.withoutGrabber)
            ) {
                if let discountAmount = foreverNavigationVm.foreverData?.monthlyDiscountPerReferral {
                    InfoView(
                        infoViewModel: .init(
                            title: L10n.ReferralsInfoSheet.headline,
                            description: L10n.ReferralsInfoSheet.body(discountAmount.formattedAmount)
                        )
                    )
                }
            }
    }

    private var successView: some View {
        ScrollViewReader { value in
            hForm {
                VStack(spacing: 0) {
                    headerView
                    Spacing(height: Float(spacing))
                    discountCodeSectionView
                    InvitationTable(foreverData: foreverNavigationVm.foreverData).id(2)
                }
            }
            .hSetScrollBounce(to: true)
            .onChange(of: scrollTo) { _, newValue in
                if newValue != 0 {
                    withAnimation {
                        value.scrollTo(newValue, anchor: .top)
                    }
                    scrollTo = 0
                }
            }
            .onPullToRefresh {
                Task { @MainActor in
                    await foreverNavigationVm.fetchForeverData()
                }
            }
        }
        .background(
            GeometryReader(content: { proxy in
                Color.clear
                    .onAppear {
                        totalHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size) { _, size in
                        totalHeight = size.height
                    }
            })
        )
    }

    private var headerView: some View {
        HeaderView(foreverNavigationVm: foreverNavigationVm) {
            scrollTo = 2
        }
        .id(0)
        .padding(.bottom, .padding16)
        .background(
            GeometryReader(content: { proxy in
                Color.clear
                    .onAppear {
                        headerHeight = proxy.size.height.rounded()
                    }
                    .onChange(of: proxy.size) { _, size in
                        headerHeight = size.height.rounded()
                    }
            })
        )
    }

    private var discountCodeSectionView: some View {
        DiscountCodeSectionView().id(1)
            .background(
                GeometryReader(content: { proxy in
                    Color.clear
                        .onAppear {
                            discountCodeHeight = proxy.size.height.rounded()
                        }
                        .onChange(of: proxy.size.height.rounded()) { _, size in
                            discountCodeHeight = size
                        }
                })
            )
    }

    private func recalculateHeight() {
        spacing = max(totalHeight - discountCodeHeight - headerHeight, 0)
    }
}

#Preview {
    let vm = ForeverNavigationViewModel()
    vm.viewState = .success
    Localization.Locale.currentLocale.send(.en_SE)
    return ForeverView()
        .onAppear {
            Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
        }
        .environment(vm)
}
