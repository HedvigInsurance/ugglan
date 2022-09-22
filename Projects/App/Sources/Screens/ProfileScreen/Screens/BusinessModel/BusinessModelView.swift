import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

struct BusinessModelView: View {
    @PresentableStore var store: UgglanStore

    var body: some View {
        hForm {
            Image(uiImage: Asset.milkywire.image)
                .resizable()
                .padding(.horizontal, 48)
                .padding(.vertical, 20)

            hSection {
                hText(L10n.businessModelCardTitle, style: .headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.horizontal, .top], 24)

                Spacer()
                    .frame(height: 5)

                hText(L10n.businessModelCardText, style: .body)
                    .foregroundColor(hLabelColor.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.horizontal, .bottom], 24)
            }
            .sectionContainerStyle(.transparent)

            Button {
                store.send(.aboutBusinessModel)
            } label: {
                HStack {
                    Image(uiImage: hCoreUIAssets.infoSmall.image)
                    hText(L10n.businessModelInfoButtonLabel, style: .headline)
                }
                .foregroundColor(hLabelColor.primary)
            }
            .padding(.horizontal)

        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .charity))
    }
}

extension BusinessModelView {
    public var journey: some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: self,
            options: [.embedInNavigationController]
        ) { action in
            if case .aboutBusinessModel = action {
                AboutBusinessModelView().journey
            }
        }
        .inlineTitle()
        .configureTitle(L10n.businessModelTitle)
    }
}

struct BusinessModelView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessModelView()
    }
}
