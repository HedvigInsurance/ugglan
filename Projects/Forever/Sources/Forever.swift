import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ForeverView: View {
    let multiplier = HFontTextStyle.body1.multiplier
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel
    @StateObject var foreverVm = ForeverViewModel()
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
            .loading($foreverVm.viewState)
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        Task {
                            let data = try await foreverVm.fetchForeverData()
                            if let data {
                                foreverNavigationVm.foreverData = data
                            }
                        }
                    }),
                    dismissButton: nil
                )
            )
            .onAppear {
                Task {
                    let data = try await foreverVm.fetchForeverData()
                    if let data {
                        foreverNavigationVm.foreverData = data
                    }
                }
            }
    }

    private var successView: some View {
        ScrollViewReader { value in
            hForm {
                VStack(spacing: 0) {
                    HeaderView {
                        scrollTo = 2
                    }
                    .id(0)
                    .padding(.bottom, .padding16)
                    .background(
                        GeometryReader(content: { proxy in
                            Color.clear
                                .onAppear {
                                    print(proxy.size)
                                    headerHeight = proxy.size.height
                                }
                                .onChange(of: proxy.size) { size in
                                    print(proxy.size)
                                    headerHeight = size.height
                                }
                        })
                    )
                    Spacing(height: Float(multiplier != 1 ? .padding8 * multiplier : spacing))
                    DiscountCodeSectionView().id(1)
                        .background(
                            GeometryReader(content: { proxy in
                                Color.clear
                                    .onAppear {
                                        print(proxy.size)
                                        discountCodeHeight = proxy.size.height
                                    }
                                    .onChange(of: proxy.size) { size in
                                        print(proxy.size)
                                        discountCodeHeight = size.height
                                    }
                            })
                        )
                    InvitationTable().id(2)
                }
            }
            .onChange(of: scrollTo) { newValue in
                if newValue != 0 {
                    withAnimation {
                        value.scrollTo(newValue, anchor: .top)
                    }
                    scrollTo = 0
                }
            }
        }
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
                let data = try await foreverVm.fetchForeverData()
                if let data {
                    foreverNavigationVm.foreverData = data
                }
            }
        }
        .background(
            GeometryReader(content: { proxy in
                Color.clear
                    .onAppear {
                        print(proxy.size)
                        totalHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size) { size in
                        print(proxy.size)
                        totalHeight = size.height
                    }
            })
        )
        .onAppear {
            Task {
                let data = try await foreverVm.fetchForeverData()
                if let data {
                    foreverNavigationVm.foreverData = data
                }
            }
        }
    }

    private func recalculateHeight() {
        spacing = max(totalHeight - discountCodeHeight - headerHeight, 0)
    }
}

@MainActor
public class ForeverViewModel: ObservableObject {
    @Inject var foreverService: ForeverClient
    @Published var viewState: ProcessingState = .loading

    func fetchForeverData() async throws -> ForeverData? {
        withAnimation {
            viewState = .loading
        }

        do {
            let data = try await self.foreverService.getMemberReferralInformation()
            withAnimation {
                viewState = .success
            }
            return data
        } catch let exception {
            withAnimation {
                viewState = .error(errorMessage: exception.localizedDescription)
            }
        }

        return nil
    }
}

struct ForeverView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return ForeverView()
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
            }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
