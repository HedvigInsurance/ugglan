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
                        HeaderView { scrollTo = 2 }.id(0)
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
                //                store.send(.fetch)
            }
            .navigationBarItems(
                trailing:
                    PresentableStoreLens(
                        ForeverStore.self,
                        getter: { state in
                            state.foreverData?.monthlyDiscountPerReferral
                        }
                    ) { discountAmount in
                        Button(action: {
                            if let discountAmount {
                                store.send(.showInfoSheet(discount: discountAmount.formattedAmount))
                            }
                        }) {
                            Image(uiImage: hCoreUIAssets.infoIcon.image)
                                .foregroundColor(hTextColor.primary)
                        }
                    }
            )
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

extension ForeverView {
    func infoSheetJourney(potentialDiscount: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: InfoView(
                title: L10n.ReferralsInfoSheet.headline,
                description: L10n.ReferralsInfoSheet.body(potentialDiscount),
                onDismiss: {
                    let store: ForeverStore = globalPresentableStoreContainer.get()
                    store.send(.closeInfoSheet)
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        )
        .onAction(ForeverStore.self) { action in
            if case .closeInfoSheet = action {
                DismissJourney()
            }
        }
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
