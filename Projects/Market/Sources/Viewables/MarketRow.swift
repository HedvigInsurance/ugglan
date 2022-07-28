import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct MarketRowView: View {
    @PresentableStore var store: MarketStore
    
    @ViewBuilder
    public func marketRow(_ market: Market) -> some View {
        Button {
            store.send(.presentMarketPicker(currentMarket: store.state.market))
        } label: {

        }
        .buttonStyle(MarketRowButtonStyle(market: market))
    }
    
    var body: some View {
        PresentableStoreLens(
            MarketStore.self,
            getter: { state in
                state.market
            },
            setter: { _ in
                nil
            }
        ) { market, _ in
            marketRow(market)
        }

    }
}

struct MarketRowButtonStyle: ButtonStyle {
    let market: Market

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 16) {
            Image(uiImage: market.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                
            VStack(alignment: .leading) {
                hText(L10n.MarketLanguageScreen.marketLabel, style: .headline)
                    
                hText(market.title, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            }
            
            Spacer()
            
            Image(uiImage: hCoreUIAssets.chevronRight.image)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
        }
        .padding(.horizontal, 16)
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.25))
    }
}

struct MarketRow_Previews: PreviewProvider {
    static var previews: some View {
        MarketRowView()
    }
}
