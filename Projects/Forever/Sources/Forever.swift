import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ForeverView: View {
    @PresentableStore var store: ForeverStore
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
        LoadingViewWithContent(ForeverStore.self, [.fetchForeverData], [.fetch]) {
            ScrollViewReader { value in
                hForm {
                    VStack(spacing: 0) {
                        HeaderView {
                            scrollTo = 2
                        }
                        .id(0)
                        .padding(.bottom, 16)
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
                        Spacing(height: Float(spacing))
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
            .onAppear {
                store.send(.fetch)
            }
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    PresentableStoreLens(
                        ForeverStore.self,
                        getter: { state in
                            state.foreverData?.monthlyDiscountPerReferral
                        }
                    ) { discountAmount in
                        if let discountAmount {
                            InfoViewHolder(
                                title: L10n.ReferralsInfoSheet.headline,
                                description: L10n.ReferralsInfoSheet.body(discountAmount.formattedAmount),
                                type: .navigation
                            )
                            .foregroundColor(hTextColor.primary)
                        }
                    }
                }
            }
            .onPullToRefresh {
                await store.sendAsync(.fetch)
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
    }

    private func recalculateHeight() {
        spacing = max(totalHeight - discountCodeHeight - headerHeight, 0)
    }
}

struct ForeverView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return ForeverView()
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverService in ForeverServiceDemo() })
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
