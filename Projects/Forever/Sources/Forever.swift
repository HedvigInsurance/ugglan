import Foundation
import hCore
import hCoreUI
import SwiftUI

public struct ForeverView: View {
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel
    @State var scrollTo: Int = -1
    @State var spacing: CGFloat = 0
    @State var totalHeight: CGFloat = 0
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
        successView
            .loading($foreverNavigationVm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        Task {
                            try await foreverNavigationVm.fetchForeverData()
                        }
                    }),
                    dismissButton: nil
                )
            )
            .onAppear {
                Task {
                    try await foreverNavigationVm.fetchForeverData()
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
            .onChange(of: scrollTo) { newValue in
                if newValue != 0 {
                    withAnimation {
                        value.scrollTo(newValue, anchor: .top)
                    }
                    scrollTo = 0
                }
            }
        }
        .modifier(ForeverViewModifier(totalHeight: $totalHeight))
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
                    .onChange(of: proxy.size) { size in
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
                        .onChange(of: proxy.size.height.rounded()) { size in
                            discountCodeHeight = size
                        }
                })
            )
    }

    private func recalculateHeight() {
        spacing = max(totalHeight - discountCodeHeight - headerHeight, 0)
    }
}

struct ForeverViewModifier: ViewModifier {
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel
    @Binding var totalHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    if let discountAmount = foreverNavigationVm.foreverData?.monthlyDiscountPerReferral {
                        InfoViewHolder(
                            title: L10n.ReferralsInfoSheet.headline,
                            description: L10n.ReferralsInfoSheet.body(discountAmount.formattedAmount),
                            type: .navigation
                        )
                        .foregroundColor(hTextColor.Opaque.primary)
                    }
                }
            }
            .onPullToRefresh {
                Task { @MainActor in
                    try await foreverNavigationVm.fetchForeverData()
                }
            }
            .background(
                GeometryReader(content: { proxy in
                    Color.clear
                        .onAppear {
                            totalHeight = proxy.size.height
                        }
                        .onChange(of: proxy.size) { size in
                            totalHeight = size.height
                        }
                })
            )
    }
}

struct ForeverView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ForeverNavigationViewModel()
        vm.viewState = .success
        Localization.Locale.currentLocale.send(.en_SE)
        return ForeverView()
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
            }
            .environmentObject(vm)
    }
}
